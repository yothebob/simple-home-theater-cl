;;;; simple-home-theater-cl.asd

(asdf:defsystem #:simple-home-theater-cl
  :description "Describe simple-home-theater-cl here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("tuition" "str")
  :components ((:module "src"
		:components
		((:file "package")
		 (:file "app")
		 (:file "cli")
		 (:file "db")))))
