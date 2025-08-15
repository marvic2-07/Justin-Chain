(define-constant contract-owner tx-sender)

;; Store dispute info: (partyA, partyB, description, resolved?)
(define-map disputes uint
  {
    party-a: principal,
    party-b: principal,
    description: (string-utf8 100),
    resolved: bool,
    winner: (optional principal)
  }
)

;; Store mediator for each dispute
(define-map mediators uint principal)

(define-data-var next-id uint u1)

;; Create a new dispute
(define-public (file-dispute (party-b principal) (description (string-utf8 100)))
  (let 
    (
      (id (var-get next-id))
      (validated-description (unwrap! (as-max-len? description u100) (err u109))) ;; Description too long
      (dispute-data {
        party-a: tx-sender,
        party-b: party-b,
        description: validated-description,
        resolved: false,
        winner: none
      })
    )
    (begin
      (asserts! (not (is-eq tx-sender party-b)) (err u105)) ;; Cannot file dispute against self
      (map-set disputes id dispute-data)
      (var-set next-id (+ id u1))
      (ok id)
    )
  )
)

;; Assign mediator (only contract owner)
(define-public (assign-mediator (dispute-id uint) (mediator principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u100)) ;; Unauthorized
    (asserts! (is-some (map-get? disputes dispute-id)) (err u103)) ;; Dispute must exist
    (asserts! (is-none (map-get? mediators dispute-id)) (err u106)) ;; Mediator already assigned
    (asserts! (not (is-eq mediator tx-sender)) (err u107)) ;; Contract owner cannot be mediator
    (map-set mediators dispute-id mediator)
    (ok "Mediator assigned")
  )
)

;; Mediator resolves dispute
(define-public (resolve-dispute (dispute-id uint) (winner principal))
  (let ((dispute (unwrap! (map-get? disputes dispute-id) (err u103)))
        (mediator (unwrap! (map-get? mediators dispute-id) (err u104))))
    (begin
      (asserts! (is-eq tx-sender mediator) (err u101))
      (asserts! (is-eq (get resolved dispute) false) (err u102))
      (asserts! (or (is-eq winner (get party-a dispute)) 
                    (is-eq winner (get party-b dispute))) 
                (err u108))
      (map-set disputes dispute-id
        {
          party-a: (get party-a dispute),
          party-b: (get party-b dispute),
          description: (get description dispute),
          resolved: true,
          winner: (some winner)
        })
      (ok "Dispute resolved"))))

;; View dispute details
(define-read-only (get-dispute (id uint))
  (map-get? disputes id)
)
