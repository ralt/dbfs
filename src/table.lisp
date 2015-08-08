(in-package :dbfs)

(defn table-exists (string -> boolean) (table)
  (multiple-value-bind (_ count)
      (with-db
        (postmodern:query "
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
AND tablename = $1
" table :single))
    (declare (ignore _))
    (> count 0)))
