;;;; simple-home-theater-cl.lisp

(in-package #:simple-home-theater-cl)

;; DATABASE
(setq *db* (list :user (list) :category (list) :content (list) :playlist (list)))
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
(defun create-user ()
  (push-record (dbm :user)
	       (make-user
		(nextid :user)
		(prompt-read "Username")
		(prompt-read "Password"))))

(defun make-category (id name user-id path)
  (list :id id :name name :user-id user-id :path path))
(defun create-category (user)
  (push-record (dbm :category)
	       (make-category (nextid :category)
			      (prompt-read "Name")
			      (getf user :id)
			      (prompt-read "File Path"))))

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

;; TODO: add user watch history

;; APP
(defparameter *user* nil)
(defparameter *active-cat* nil) ;; not sure if this is a forever thing, but it use to be only viewing one cat at a time
(defparameter *player* nil)
(setq *player* "mpv")
(defun login-user ()
  (let ((entered-name (prompt-read "Username"))
	(entered-pass (prompt-read "Password")))
    (setq *user* (select (where :name entered-name :password entered-pass) (dbm :user)))))

(defun add-category ()
  (let* ((new-category (create-category *user*))
	 (category-contents (getf new-category :path)))
    (loop for file in (directory category-contents)
	  do (create-content file new-category))))

(defun add-playlist (content-ids-str)
  (let* ((new-pl (create-playlist (mapcar #'parse-integer (uiop:split-string content-ids-str)))))))

(defun get-category-contents ()
  (select (where :category-id (getf *active-cat* :id)) (dbm :content)))

(defun countdown (time-left)
  "Here are some important docs for countdown!"
  (if (eq (% time-left 2) 0) (format *query-io* "~s" time-left))
  (if (eq time-left 0) t
      (progn (sleep 1)
	(countdown (- time-left 1)))))

;; "list playlist" : {"-lpl" : "List playlist","listpl" : ""},
;; "add playlist" : {"-apl" : " add playlist ex:{indexes} -apl name=?"},
;; "append playlist" : {"-atpl" : " add to a playlist ex:{indexes} -atpl name=?"},
;; "search"    : {"search" :"search for multiple names", "-s": ""},
;; "autoplay"  : {"-a" : "autoplay category in index order"},
;; "replay"    : {"-r": "replay given indexes/ playlist"},
;; "shuffle"   : {"-sp" : "shuffle playlist"},
;; "cross_content"   : {"-crossc" : "grab a piece of content from another category ex:{-crossc id=(content_id)}"},
;; "help"      : {"-h" : "", "help" : ""},
;; "exit"      : {"exit" : ""}

(defun play (cmd-str &optional (cd-time 3)) ;; how to play: countdown, play, add to history
  (progn (countdown cd-time)
  (uiop:launch-program (format nil "~s ~s" *player* cmd-str))))
(defun ls (data-list &optional start stop)
  (format t "~{~a~% ~}" data-list)) ;; (ls (get-category-contents))
;; (defun detail (item) (format t "TODO"))
;; (defun search (&rest s-terms) ('TODO))
(defun test--cmd (&rest args)
  (let (fncall)
    (loop for arg in args do
      (progn
	(format *query-io* "~s" arg)
	(force-output *query-io*)))))
