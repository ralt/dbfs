(in-package :dbfs)

(defn table-exists (string -> boolean) (table)
  (multiple-value-bind (_ count)
      (with-db
        (postmodern:query "
SELECT tablename
FROM   pg_catalog.pg_tables
WHERE  schemaname = 'public'
AND    tablename = $1
" table :single))
    (declare (ignore _))
    (> count 0)))

(defn table-primary-key (string -> string) (table)
  (multiple-value-bind (key _)
      (with-db
        (postmodern:query "
SELECT a.attname, format_type(a.atttypid, a.atttypmod) AS data_type
FROM   pg_index i
JOIN   pg_attribute a
ON     a.attrelid = i.indrelid
AND    a.attnum = ANY(i.indkey)
WHERE  i.indrelid = $1::regclass
AND    i.indisprimary
" table :plist))
    (declare (ignore _))
    (if key
        (getf key :attname)
        "")))

(defn table-keys (string -> string -> list) (table key-field)
  (multiple-value-bind (keys _)
      (with-db
        (postmodern:query (format nil "
SELECT ~A
FROM   ~A
" key-field table) :lists))
    (declare (ignore _))
    (mapcar #'write-to-string (mapcar #'first keys))))

(defn table-row (string -> string -> string -> list) (table key-field key)
  (multiple-value-bind (rows _)
      (with-db
        (postmodern:query (format nil "
SELECT *
FROM ~A
WHERE ~A = $1" table key-field) key :plist))
    (declare (ignore _))
    rows))
