;;;; db.lisp

(in-package #:simple-home-theater-cl)

;; DATABASE
(defvar *db* (list :user (list) :category (list) :content (list) :playlist (list)))
(defun make-comparison-expr (field value)
  `(equal (getf cd ,field) ,value))
(defun make-comparisons-list (fields)
  (loop while fields
	collecting (make-comparison-expr (pop fields) (pop fields))))
(defmacro where (&rest clauses)
  `#'(lambda (cd) (and ,@(make-comparisons-list clauses))))
(defun select (select-fn db) (remove-if-not select-fn db))
(defun prompt-read (prompt)
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))
(defun save-db (filename)
  (with-open-file (out filename
		       :direction :output
		       :if-exists :supersede)
    (with-standard-io-syntax
      (print *db* out))))
(defun load-db (filename)
  (with-open-file (in filename)
    (with-standard-io-syntax
      (setf *db* (read in)))))
(defmacro push-record (table value) `(setf (getf *db* ,table) (push ,value ,table)))
(defmacro dbm (table) `(getf *db* ,table))
(defmacro nextid (table) `(+ (length (dbm ,table)) 1))

(defun make-user (id name password) (list :id id :name name :password password))
(defun get-user-count (user-db) (length (dbm :user)))
(defun create-user (&rest args)
  (push-record (dbm :user)
	       (make-user
		(nextid :user)
		(prompt-read "Username")
		(prompt-read "Password"))))

(defun make-category (id name user-id path)
  (list :id id :name name :user-id user-id :path path))
(defun create-category (user)
  (let ((nc (make-category (nextid :category)
				(prompt-read "Name")
				(getf user :id)
				(prompt-read "File Path"))))
    (push-record (dbm :category) nc)
    nc))

(defun make-content (id category-id file)
  (list :id id :category-id category-id :file file))
(defun create-content (name category)
  (push-record (dbm :content)
	       (make-content (nextid :content)
			     (getf category :id)
			     name)))

(defun make-playlist (id name plylst)
  (list :id id :name name :plylst plylst))
(defun create-playlist (lst)
  (push-record (dbm :playlist)
	       (make-playlist (nextid :playlist)
		(prompt-read "Name") lst)))
