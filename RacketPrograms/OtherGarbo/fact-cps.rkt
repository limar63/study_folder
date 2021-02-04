#lang racket
(define (fact number cont)
  (if (or (= number 0) (= number 1))
      (cont 1)
      (fact (- number 1) (lambda (x) (cont (* x number))))))

(define (id x) x)

(fact 10 id)