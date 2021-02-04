#lang racket
(require racket/trace)
(define (Mix2 L1 L2)
  (if (null? L1)
      L2
      (if (null? L2)
          L1
          (cons (cons (car L1) (car L2)) (Mix2 (cdr L1) (cdr L2))))))
(trace Mix2)
(Mix2 '(a b c) '(d e f z))

;Определить функцию(Mix2 L1 L2), которая образует список
;точечных пар элементов, взятых последовательно из заданных
;списков L1 и L2, например:
;(Mix2 '(A B C) '(Z X))=> ((A . Z)(B . X)(C))