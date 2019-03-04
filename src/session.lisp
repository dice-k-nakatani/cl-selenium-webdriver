(in-package :cl-selenium)

;;(defclass session ()
;;  ((id :initarg :id
;;       :initform (error "Must supply an id")
;;       :reader session-id)))

(defvar *session* nil)

(defun make-session-arg (&rest rest)
  (let ((cap '(:obj)))
    (iterate (((k v)
               (chunk 2 2 (scan rest))))
      (setf (jsown:val cap k) v))
    `(:obj ("desiredCapabilities" . ,cap))))

(defun make-session (obj)
  (let ((response (http-post "/session" obj)))
    (jsown:val response "sessionId")))

;;(defun make-session (&key
;;                       (browser-name :chrome) ; TODO: autodetect?
;;                       browser-version
;;                       platform-name
;;                       platform-version
;;                       accept-ssl-certs
;;                       additional-capabilities)
;;  (let ((response (http-post "/session"
;;                             `(;;:session-id nil
;;                               :desired-capabilities  ((browser-name . ,browser-name)
;;                                                       (browser-version . ,browser-version)
;;                                                       (platform-name . ,platform-name)
;;                                                       (platform-version . ,platform-version)
;;                                                       (accept-ssl-certs . ,accept-ssl-certs)
;;                                                       ,@additional-capabilities)))))
;;    ;; TODO: find/write json -> clos
;;    (make-instance 'session
;;                   :id (assoc-value response :session-id))))

(defun delete-session (session)
  (http-delete-check (session-path session "")))

;; TODO: make eldoc-friendly
(defun use-session(session)
  (setf *session* session))



(defmacro with-session ((&rest capabilities) &body body)
  (with-gensyms (session)
    `(let (,session)
       (unwind-protect
            (progn
              (setf ,session (make-session ,@capabilities))
              (let ((*session* ,session))
                ,@body))
         (when ,session
           (delete-session ,session))))))

(defun start-interactive-session (&rest capabilities)
  (when *session*
    (delete-session *session*))
  (setf *session* (apply #'make-session  capabilities)))

(defun stop-interactive-session ()
  (when *session*
    (delete-session *session*)
    (setf *session* nil)))

(defun session-path (session fmt &rest args)
  (format nil "/session/~a~a" session (apply #'format nil fmt args)))
