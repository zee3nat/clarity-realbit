;; Property Ownership Token Contract
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-fungible-token property-token)

;; Error constants
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))

;; Token information
(define-data-var token-name (string-ascii 32) "RealBit Property Token")
(define-data-var token-symbol (string-ascii 10) "RBT")
(define-data-var token-decimals uint u6)

;; SIP-010 functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (try! (ft-transfer? property-token amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance property-token who)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply property-token)))

(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender contract-owner)
    (ft-mint? property-token amount recipient)
    err-owner-only))
