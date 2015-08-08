(in-package :dbfs)

(defun cat (&rest args)
  (apply #'concatenate 'string args))

(defun disable-debugger ()
  (labels
      ((exit (c h)
         (declare (ignore h))
         (format t "~A~%" c)
         (sb-ext:exit)))
    (setf *debugger-hook* #'exit)))

(defmacro defn (name types args &rest rest)
  "Type safe defun"
  (let ((types (remove-if
                (lambda (x) (or (equal '-> x) (equal '→ x))) types)))
    `(progn (defun ,name ,args
              ,@(loop for arg in args for type in types
                     collect `(check-type ,arg ,type))
              ,@rest)
            (declaim (ftype (function ,(butlast types) ,@(last types)) ,name)))))

(defn directory-content (list -> list) (split-path)
  (log:debug "directory-content: ~A" split-path)
  (dir-content split-path :root))

(defn directoryp (list -> boolean) (split-path)
  (log:debug "directoryp: ~A" split-path)
  (is-directory split-path :root))

(defn symlink-target (list -> string) (split-path)
  (log:debug "symlink-target: ~A" split-path)
  nil)

(defun file-open (path flags)
  (log:debug "file-open path: ~A" path)
  (log:debug "file-open flags: ~A" flags)
  (if (read-file path :root)
      0
      (- cl-fuse:error-ENOENT)))

(defun file-release (path flags)
  (log:debug "file-release path: ~A" path)
  (log:debug "file-release flags: ~A" flags)
  ;; @todo find out what this is for
  0)

(defun file-read (split-path size offset fh)
  (log:debug "file-read split-path: ~A" split-path)
  (log:debug "file-read size: ~A" size)
  (log:debug "file-read offset: ~A" offset)
  (log:debug "file-read fh: ~A" fh)
  (let* ((file-contents (read-file split-path :root))
         (file-length (length file-contents)))
    (subseq file-contents
            offset
            (if (> file-length (+ offset size))
                (+ offset size)
                file-length))))

(defn file-size (list -> integer) (split-path)
  (log:debug "file-size: ~A" split-path)
  (length (read-file split-path :root)))

(defun file-flush (path fh)
  (log:debug "file-flush path: ~A" path)
  (log:debug "file-flush fh: ~A" fh)
  ;; @todo find out what this is for
  0)

(defun mkdir (path mode)
  (log:debug "mkdir path: ~A" path)
  (log:debug "mkdir mode: ~A" mode)
  ;; @todo implement search
  (- cl-fuse:error-EACCES))

(defun unlink (path)
  (log:debug "unlink: ~A" path)
  (- cl-fuse:error-EACCES))

(defun rmdir (path)
  (log:debug "rmdir: ~A" path)
  ;; @todo implement search
  (- cl-fuse:error-EACCES))

(defun help ()
  (format t "Usage: dbfs <folder> <database type> [other arguments]~%")
  (format t "~%Example: dbfs /db/ postgresql localhost dbname username password~%")
  (format t "~%Supported databases: postgresql~%")
  0)

(defun main (args)
  (log:config :debug)
  (log:debug "fuse-run")
  (when (or (member "--help" args :test #'string=)
            (member "-h" args :test #'string=))
    (return-from main (help)))
  (initialize-db-connection (rest (rest args)))
  (cl-fuse:fuse-run (list "dbfs" ; fs name
                          (second args) ; folder
                          "-oallow_other")
                    :directory-content 'directory-content
                    :directoryp 'directoryp
                    :symlink-target 'symlink-target
                    :symlinkp 'symlink-target
                    :file-open 'file-open
                    :file-release 'file-release
                    :file-read 'file-read
                    :file-size 'file-size
                    :file-write nil
                    :file-write-whole nil
                    :file-writeable-p nil
                    :file-executable-p nil
                    :file-create nil
                    :chmod nil
                    :chown nil
                    :truncate nil
                    :file-flush 'file-flush
                    :mkdir 'mkdir
                    :unlink 'unlink
                    :rmdir 'rmdir
                    :symlink nil
                    :rename nil))
