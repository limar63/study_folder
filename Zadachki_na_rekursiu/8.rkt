#lang racket
(require racket/trace)
(define (Mix1 L1 L2)
  (if (null? L1)
      L2
      (cons (car L1) (Mix1 (cdr L1) L2))))
(trace Mix1)
(Mix1 '(a b c) '(d e f))
;Определить функцию(Mix1 L1 L2), которая образует новый
;список, чередуя элементы заданных:
;(Mix1 '(A B C) '(Z X)) => (A Z B X C)
;Сons + хвостовая рекурсия = реверснутый список. Cons + нехвостовая = обычный список.