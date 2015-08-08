(in-package :dbfs)

(defgeneric is-directory (split-path type &key)
  (:documentation "Determines if a file is a directory."))

(defmethod is-directory (path (type (eql :root)) &key)
  (cond ((= (length path) 3) nil)
        ((and (= (length path) 2) (string= (cadr path) "identifier")) nil)
        (t t)))
