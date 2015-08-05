(in-package :dbfs)

(defvar *connection-spec* nil)

(defmacro with-db (arg &body body)
  `(clsql:with-database (,@arg *connection-spec* :pool t)
     ,@body))

;;; Supported db types and their init functions.
(defvar *supported-dbs* (make-hash-table :test #'equal))

(defmacro define-db-connection (name args &body body)
  `(setf (gethash (symbol-name ',name) *supported-dbs*)
         #'(lambda ,args
             ,@body)))

;;; args is a list with the following values:
;;; - first is the db type
;;; - rest is the required data for the db to be initialized.
(defun initialize-db-connection (args)
  (apply (gethash (string-upcase (first args)) *supported-dbs*) (rest args)))

(define-db-connection mysql (host dbname username password)
  (setf clsql:*default-database-type* :mysql)
  (setf *connection-spec* (format nil "mysql://~A:~A@~A/~A" username password host dbname)))
