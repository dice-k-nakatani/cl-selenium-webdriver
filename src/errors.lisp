(in-package :cl-selenium)

(define-condition protocol-error (error)
  ((body :initarg :body :reader protocol-error-body)))

(defun protocol-error-status (error)
  (with-slots (body) error
    (jsown:val body "status")))

(defmethod print-object ((error protocol-error) stream)
  (with-slots (body) error
    (format stream
            "[~a]~%status: ~a~%state: ~a~%~%~a~%"
            (type-of error)
            (jsown:val body "status")
            (jsown:val body "state")
            (jsown:val (jsown:val body "value") "message"))))

(define-condition find-error (error)
  ((value :initarg :value)
   (by :initarg :by)))

(define-condition no-such-element-error (find-error)
  ()
  (:report (lambda (condition stream)
             (with-slots (value by) condition
               (format stream "No such element: ~a (by ~a)" value by)))))

(define-condition stale-element-reference (find-error)
  ()
  (:report (lambda (condition stream)
             (with-slots (value by) condition
               (format stream "Stale element reference: ~a (by ~a)" value by)))))
