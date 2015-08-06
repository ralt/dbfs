#|
  This file is a part of mysqlfs project.
  Copyright (c) 2015 Florian Margaine (florian@margaine.com)
|#

#|
  Author: Florian Margaine (florian@margaine.com)
|#

(in-package :cl-user)
(defpackage dbfs-asd
  (:use :cl :asdf))
(in-package :dbfs-asd)

(defsystem dbfs
  :version "0.1"
  :author "Florian Margaine"
  :license "MIT License"
  :depends-on (:cl-fuse-meta-fs :log4cl :postmodern)
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "db")
                 (:file "dir-content")
                 (:file "is-directory")
                 (:file "read-file")
                 (:file "dbfs"))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq))))
