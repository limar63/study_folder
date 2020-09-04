#lang racket
(define (Pair L)
  (if (null? L)
      L
      (if (empty? (cdr L))
          L
          (cons (cons (car L) (car (cdr L))) (Pair (cdr (cdr L)))))))
(Pair '(a b c d e f g h))
;Составить функцию(Pair L), которая разбивает элементы списка L
;на точечные пары, например:
;(Pair '(A B C D E)) => ((A . B)(C . D)(E))