;; Milestones Contract

(define-trait milestone-trait
  (
    (get-milestone (uint uint) (response {
      description: (string-utf8 500),
      funds-required: uint,
      status: (string-ascii 20)
    } uint))
    (get-project-milestone-count (uint) (response uint uint))
  )
)

;; This contract now only defines the trait for milestones
;; The actual implementation is in the crowdfunding contract

