;; Governance Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-active (err u101))

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
