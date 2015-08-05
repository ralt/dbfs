(in-package :dbfs)

(defgeneric dir-content (path type &key)
  (:documentation "Lists a directory content."))

(defmethod dir-content (path (type (eql :root)) &key)
  )
