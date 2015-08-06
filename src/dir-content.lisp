(in-package :dbfs)

(defgeneric dir-content (path type &key)
  (:documentation "Lists a directory content."))

(defmethod dir-content (path (type (eql :root)) &key)
  (multiple-value-bind (results _)
      (with-db
        (postmodern:query (format nil "
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
AND tableowner = '~A'
" (second *connection-spec*)) :column))
    (declare (ignore _))
    results))
