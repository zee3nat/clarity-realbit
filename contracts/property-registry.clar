;; Property Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-property (err u101))

;; Data structures
(define-map properties
  { property-id: uint }
  {
    owner: principal,
    location: (string-ascii 100),
    value: uint,
    token-address: principal,
    shares: uint,
    active: bool
  }
)

(define-data-var next-property-id uint u1)

;; Public functions
(define-public (register-property 
  (location (string-ascii 100))
  (value uint)
  (shares uint)
  (token-address principal))
  (let
    ((property-id (var-get next-property-id)))
    (if (is-eq tx-sender contract-owner)
      (begin
        (map-set properties
          { property-id: property-id }
          {
            owner: contract-owner,
            location: location,
            value: value,
            token-address: token-address,
            shares: shares,
            active: true
          }
        )
        (var-set next-property-id (+ property-id u1))
        (ok property-id))
      err-owner-only)))
