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

(defn table-primary-key (string -> string) (table)
  (multiple-value-bind (key _)
      (with-db
        (postmodern:query "
SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
FROM   pg_index i
JOIN   pg_attribute a ON a.attrelid = i.indrelid
                     AND a.attnum = ANY(i.indkey)
WHERE  i.indrelid = $1::regclass
AND    i.indisprimary
" table :plist))
    (declare (ignore _))
    (if key
        (getf key :attname)
        "")))
