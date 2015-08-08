(in-package :dbfs)

(defgeneric dir-content (path type &key)
  (:documentation "Lists a directory content."))

(defmethod dir-content (path (type (eql :root)) &key)
  (unless path
    (return-from dir-content
      (multiple-value-bind (results _)
          (with-db
            (postmodern:query "
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
AND tableowner = $1
" (second *connection-spec*) :column))
        (declare (ignore _))
        results)))
  (when (table-exists (first path))
    (dir-content (rest path) :table :table (first path))))

(defmethod dir-content (path (type (eql :table)) &key table)
  (unless path
    (return-from dir-content '("structure" "id" "data"))))
