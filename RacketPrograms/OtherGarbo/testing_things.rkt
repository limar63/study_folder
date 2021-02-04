#lang racket
(require 2htdp/image)
(define main-list '((4 0) (2 7 7 7 6 6) 10))


;(place-image (square 10 "solid" "green") 15 15 (place-image (square 10 "solid" "green") 35 35 (empty-scene 100 100)))


(define-struct snake (apple body scene change tick))

;x and y reversed (x is right and y is left element)
(define (apple-list snake) (snake-apple snake))
(define (snake-list snake) (snake-body snake))
(define (list-past-snake snake) (list (snake-scene snake) (snake-change snake) (snake-tick snake)))
(define (change-list snake) (snake-change snake))
(define (apple-x snake) (cadr (snake-apple snake)))
(define (apple-y snake) (car (snake-apple snake)))
(define (snake-x snake) (cadr (snake-body snake)))
(define (snake-y snake) (car (snake-body snake)))
(define (scene-size snake) (snake-scene snake))
(define (change-x snake) (cadr (snake-change snake)))
(define (change-y snake) (cadr (snake-change snake)))
(define (new-head-x snake) (+ (snake-x snake)(change-x snake)))
(define (new-head-y snake) (+ (snake-y snake)(change-y snake)))

(apple-list (make-snake '(4 0) '(2 7 7 7) 10 '(0 1) 5))

(cddadr main-list)


(caddr '(0 1 2 3 4))

(snake-tick (make-snake '(4 0) '(2 7 7 7) 10 '(0 1) (+ 2 2)))