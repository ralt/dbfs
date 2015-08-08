(in-package :dbfs)

(defgeneric read-file (path type &key)
  (:documentation "Reads a single file."))

(defmethod read-file (path (type (eql :root)) &key)
  (when (table-exists (first path))
    (read-file (rest path) :table :table (first path))))

(defmethod read-file (path (type (eql :table)) &key table)
  (let ((file (first path)))
    (cond ((string= file "id") (read-file nil :table-id :table table)))))

(defmethod read-file (path (type (eql :table-id)) &key table)
  (format nil "~A~%" (table-primary-key table)))
