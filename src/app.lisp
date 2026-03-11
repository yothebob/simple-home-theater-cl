;;;; app.lisp
(in-package #:simple-home-theater-cl)
;; TODO: add user watch history
(defparameter *user* nil)
(defparameter *active-cat* nil) ;; not sure if this is a forever thing, but it use to be only viewing one cat at a time
(defparameter *player* nil)
(defparameter *player* "mpv")
(defun login-user (&rest args)
  (let ((entered-name (prompt-read "Username"))
	(entered-pass (prompt-read "Password")))
    (setq *user* (select (where :name entered-name :password entered-pass) (dbm :user))))
  (traverse-to 'cat-page))

(defun pick-category ()
  (let ((user-categories (select (where :user-id (getf *user* :id)) (dbm :category)))
	cat-input)
    (progn
      (ls user-categories)
      (setq cat-input (read-line *query-io*))
      (setq *active-cat* (select (where :id (int cat-input))))
      (traverse-to 'content-page))))

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

(defun append-playlist (pl &rest idxs)
  (setf (getf pl :plylst) (merge 'list (getf pl :plylst) idxs #'<)))

;; "cross_content"   : {"-crossc" : "grab a piece of content from another category ex:{-crossc id=(content_id)}"},
;; "help"      : {"-h" : "", "help" : ""},
;; "exit"      : {"exit" : ""}

(defun search-content (cat &rest sterms)
  (select #'(lambda (x) (str:s-member sterms x :test #'str:containsp)) (get-category-contents)))

(defun autoplay (&optional (cd-time 3))
  (dolist (c (get-category-contents))
    (play c :cd-time cd-time)))

(defun play (cmd-str &optional (cd-time 3)) ;; how to play: countdown, play, add to history
  (progn (countdown cd-time)
  (uiop:launch-program (format nil "~s ~s" *player* cmd-str))))
(defun ls (data-list &optional start stop)
  (format *query-io* "~{~a~% ~}" data-list)) ;; (ls (get-category-contents))
(defun replay (&optional (cd-time 3) &rest contents)
  (loop (dolist (c contents)
	  (play c cd-time))))
(defun nshuffle (sequence)
  (loop for i from (length sequence) downto 2
        do (rotatef (elt sequence (random i))
                    (elt sequence (1- i))))
  sequence)
;; (defun detail (item) (format t "TODO"))

