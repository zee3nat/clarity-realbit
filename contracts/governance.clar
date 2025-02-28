;; Governance Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-active (err u101))
(define-constant err-already-voted (err u102))
(define-constant err-deadline-passed (err u103))
(define-constant err-not-executable (err u104))

;; Data structures
(define-map proposals
  { proposal-id: uint }
  {
    property-id: uint,
    description: (string-utf8 500),
    votes-for: uint,
    votes-against: uint,
    deadline: uint,
    executed: bool
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { amount: uint }
)

(define-data-var next-proposal-id uint u1)

;; Private functions
(define-private (is-active-proposal (proposal-id uint))
  (match (map-get? proposals {proposal-id: proposal-id})
    proposal (and
      (not (get executed proposal))
      (> (get deadline proposal) block-height)
    )
    false
  )
)

;; Public functions
(define-public (create-proposal 
  (property-id uint)
  (description (string-utf8 500))
  (deadline uint))
  (let
    ((proposal-id (var-get next-proposal-id)))
    (begin
      (map-set proposals
        { proposal-id: proposal-id }
        {
          property-id: property-id,
          description: description,
          votes-for: u0,
          votes-against: u0,
          deadline: deadline,
          executed: false
        }
      )
      (var-set next-proposal-id (+ proposal-id u1))
      (ok proposal-id))))

(define-public (vote-on-proposal 
  (proposal-id uint)
  (amount uint)
  (vote-for bool))
  (let ((proposal (unwrap! (map-get? proposals {proposal-id: proposal-id}) err-invalid-proposal)))
    (if (is-active-proposal proposal-id)
      (if (is-none (map-get? votes {proposal-id: proposal-id, voter: tx-sender}))
        (begin
          (map-set votes 
            {proposal-id: proposal-id, voter: tx-sender}
            {amount: amount}
          )
          (map-set proposals
            {proposal-id: proposal-id}
            (merge proposal 
              {
                votes-for: (if vote-for (+ (get votes-for proposal) amount) (get votes-for proposal)),
                votes-against: (if vote-for (get votes-against proposal) (+ (get votes-against proposal) amount))
              }
            )
          )
          (ok true))
        err-already-voted)
      err-not-active)))

(define-public (execute-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals {proposal-id: proposal-id}) err-invalid-proposal)))
    (if (and
          (>= block-height (get deadline proposal))
          (not (get executed proposal))
          (> (get votes-for proposal) (get votes-against proposal)))
      (begin
        (map-set proposals
          {proposal-id: proposal-id}
          (merge proposal {executed: true})
        )
        (ok true))
      err-not-executable)))
