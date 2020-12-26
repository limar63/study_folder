#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(define height 160)
(define width 160)
(define half-width (/ width 2))
(define half-height (/ height 2))
(define outline "solid")
(define pen-or-color "slateblue")
(define square_side 40)
(define sqimg (square square_side outline pen-or-color))
(define scene (empty-scene width height))

(define (rotating angle) (place-image (rotate (car angle) sqimg) half-width half-height scene))

(define (changing x) (cons (+ (car x) (car (cdr x))) (cdr x)))

(= 5 5)

(define (key-react w a-key)
  (cond
    [(key=? a-key "right") (cons (car w) '(-1))]
    [(key=? a-key "left") (cons (car w) '(1))]
    [else w]))

(big-bang '(0 -1)
  [to-draw rotating]
  [on-tick changing]
  [on-key key-react])