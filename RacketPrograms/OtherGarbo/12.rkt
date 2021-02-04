#lang racket
(require racket/trace)
(define (RevBr L)
  (if (null? (cdr L))
      L
      (cons (RevBr (cdr L)) (list (car L)))))
(trace RevBr)
(RevBr '(A B C))

;Запрограммировать функцию (RevBr L), которая переворачивает
;свой аргумент-список атомов и разбивает его на уровни; количество
;уровней равно количеству элементов исходного списка:
;(RevBr '(A B C)) => (((C) B) A)