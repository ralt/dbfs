(in-package :dbfs)

(defgeneric read-file (path type &key)
  (:documentation "Reads a single file."))

(defmethod read-file (path (type (eql :root)) &key)
  )
