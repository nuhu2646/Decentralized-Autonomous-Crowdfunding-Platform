;; Crowdfunding Contract

(define-map projects uint {
    creator: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    funding-goal: uint,
    current-funds: uint,
    deadline: uint,
    status: (string-ascii 20)
})

(define-map project-backers {project-id: uint, backer: principal} uint)

(define-map project-milestones {project-id: uint, milestone-id: uint} {
    description: (string-utf8 500),
    funds-required: uint,
    status: (string-ascii 20)
})

(define-map project-milestone-count uint uint)

(define-data-var project-id-nonce uint u0)

(define-public (create-project (title (string-utf8 100)) (description (string-utf8 500)) (funding-goal uint) (deadline uint))
    (let
        ((new-project-id (+ (var-get project-id-nonce) u1)))
        (map-set projects new-project-id {
            creator: tx-sender,
            title: title,
            description: description,
            funding-goal: funding-goal,
            current-funds: u0,
            deadline: deadline,
            status: "active"
        })
        (var-set project-id-nonce new-project-id)
        (ok new-project-id)
    )
)

(define-public (back-project (project-id uint) (amount uint))
    (let
        ((project (unwrap! (map-get? projects project-id) (err u404)))
         (current-backing (default-to u0 (map-get? project-backers {project-id: project-id, backer: tx-sender}))))
        (asserts! (is-eq (get status project) "active") (err u403))
        (asserts! (<= block-height (get deadline project)) (err u403))
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set projects project-id (merge project {current-funds: (+ (get current-funds project) amount)}))
        (map-set project-backers {project-id: project-id, backer: tx-sender} (+ current-backing amount))
        (ok true)
    )
)

(define-public (add-milestone (project-id uint) (description (string-utf8 500)) (funds-required uint))
    (let
        ((project (unwrap! (map-get? projects project-id) (err u404)))
         (milestone-count (default-to u0 (map-get? project-milestone-count project-id))))
        (asserts! (is-eq tx-sender (get creator project)) (err u403))
        (map-set project-milestones {project-id: project-id, milestone-id: (+ milestone-count u1)} {
            description: description,
            funds-required: funds-required,
            status: "pending"
        })
        (map-set project-milestone-count project-id (+ milestone-count u1))
        (ok true)
    )
)

(define-public (update-milestone-status (project-id uint) (milestone-id uint) (new-status (string-ascii 20)))
    (let
        ((project (unwrap! (map-get? projects project-id) (err u404)))
         (milestone (unwrap! (map-get? project-milestones {project-id: project-id, milestone-id: milestone-id}) (err u404))))
        (asserts! (is-eq tx-sender (get creator project)) (err u403))
        (map-set project-milestones {project-id: project-id, milestone-id: milestone-id}
            (merge milestone {status: new-status}))
        (ok true)
    )
)

(define-read-only (get-project (project-id uint))
    (ok (unwrap! (map-get? projects project-id) (err u404)))
)

(define-read-only (get-backer-contribution (project-id uint) (backer principal))
    (ok (default-to u0 (map-get? project-backers {project-id: project-id, backer: backer})))
)

(define-read-only (get-milestone (project-id uint) (milestone-id uint))
    (ok (unwrap! (map-get? project-milestones {project-id: project-id, milestone-id: milestone-id}) (err u404)))
)

(define-read-only (get-project-milestone-count (project-id uint))
    (ok (default-to u0 (map-get? project-milestone-count project-id)))
)

