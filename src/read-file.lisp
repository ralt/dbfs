(in-package :dbfs)

(defgeneric read-file (path type &key)
  (:documentation "Reads a single file."))

(defmethod read-file (path (type (eql :root)) &key)
  (when (table-exists (first path))
    (read-file (rest path) :table :table (first path))))

(defmethod read-file (path (type (eql :table)) &key table)
  (let ((file (first path)))
    (cond ((string= file "identifier") (read-file nil :identifier :table table))
          ((string= file "data") (read-file (rest path) :data :table table)))))

(defmethod read-file (path (type (eql :identifier)) &key table)
  (format nil "~A~%" (table-primary-key table)))

(defmethod read-file (path (type (eql :data)) &key table)
  (let ((row (table-row table (table-primary-key table) (first path))))
    (when row
      (format nil "~{~A~%~}"
              (mapcar #'(lambda (field)
                          (format nil "~A: ~A"
                                  (string-downcase (car field))
                                  (cdr field)))
                      row)))))
