(in-package :cl-user)
(defpackage dbfs
  (:use :cl)
  (:export :main
           :disable-debugger))
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

(defvar *db-type* nil)

(defun help ()
  (format t "Usage: dbfs [database type] [folder] [...]~%")
  (format t "~%Example: dbfs mysql /mysql/ localhost username password~%")
  (format t "~%Supported databases: mysql~%")
  0)

(defun main (args)
  (log:debug "fuse-run")
  (when (member "--help" args :test #'string=)
    (return-from main (help)))
  (setf *db-type* (second args))
  (cl-fuse:fuse-run `(,(cat "dbfs-" (second args)) ,(third args) "-oallow_other")
                    :directory-content 'directory-content
                    :directoryp 'directoryp
                    :file-read 'file-read
                    :file-size 'file-size))
