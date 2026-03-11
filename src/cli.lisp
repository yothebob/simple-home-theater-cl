;;;; cli.lisp

(in-package #:simple-home-theater-cl)

(setf *user-location* 'start-page)
(setf *cli-map* '((start-page (login-user create-user commands))
		  (cat-page (add-category pick-category))
		  (content-page (add-category pick-category))))

(defun traverse-to (location) (setf *user-location* location))

(defun commands () (second (assoc *user-location* *cli-map*)))
(defmacro action (cmd-str &rest args)
  `(,cmd-str ,args))
