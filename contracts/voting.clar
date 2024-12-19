;; Voting Contract

(define-map votes {project-id: uint, milestone-id: uint, voter: principal} bool)
(define-map vote-counts {project-id: uint, milestone-id: uint} {yes: uint, no: uint})

(define-public (vote-on-milestone (project-id uint) (milestone-id uint) (vote bool))
    (let
        ((project (unwrap! (contract-call? .crowdfunding get-project project-id) (err u404)))
         (milestone (unwrap! (contract-call? .crowdfunding get-milestone project-id milestone-id) (err u404)))
         (backer-contribution (unwrap! (contract-call? .crowdfunding get-backer-contribution project-id tx-sender) (err u403)))
         (current-votes (default-to {yes: u0, no: u0} (map-get? vote-counts {project-id: project-id, milestone-id: milestone-id}))))
        (asserts! (> backer-contribution u0) (err u403))
        (asserts! (is-eq (get status milestone) "pending") (err u403))
        (map-set votes {project-id: project-id, milestone-id: milestone-id, voter: tx-sender} vote)
        (if vote
            (map-set vote-counts {project-id: project-id, milestone-id: milestone-id}
                (merge current-votes {yes: (+ (get yes current-votes) u1)}))
            (map-set vote-counts {project-id: project-id, milestone-id: milestone-id}
                (merge current-votes {no: (+ (get no current-votes) u1)}))
        )
        (ok true)
    )
)

(define-read-only (get-vote-counts (project-id uint) (milestone-id uint))
    (ok (default-to {yes: u0, no: u0} (map-get? vote-counts {project-id: project-id, milestone-id: milestone-id})))
)

(define-read-only (get-voter-decision (project-id uint) (milestone-id uint) (voter principal))
    (ok (default-to false (map-get? votes {project-id: project-id, milestone-id: milestone-id, voter: voter})))
)

