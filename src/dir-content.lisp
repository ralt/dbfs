(in-package :dbfs)

(defgeneric dir-content (path type &key)
  (:documentation "Lists a directory content."))

(defmethod dir-content (path (type (eql :root)) &key)
  (unless path
    (return-from dir-content (tables (second *connection-spec*))))
  (when (table-exists (first path))
    (dir-content (rest path) :table :table (first path))))

(defmethod dir-content (path (type (eql :table)) &key table)
  (unless path
    (return-from dir-content '("structure" "identifier" "data")))
  (cond ((string= (first path) "data") (dir-content (rest path)
                                                    :data
                                                    :table table))
        ((string= (first path) "structure") (dir-content (rest path)
                                                         :structure
                                                         :table table))))

(defmethod dir-content (path (type (eql :data)) &key table)
  (unless path
    (return-from dir-content
      (table-keys table (table-primary-key table)))))

(defmethod dir-content (path (type (eql :structure)) &key table)
  (declare (ignore table))
  (unless path
    (return-from dir-content '("fields"))))
