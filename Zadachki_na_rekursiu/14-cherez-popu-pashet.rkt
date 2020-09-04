#lang racket
(require racket/trace)
(define (LeftBr L)
  (if (null? (cdr L))
      L
      (cons (LeftBr (cdr L)) (list (car L)))))
(trace LeftBr)
(LeftBr (reverse '(A B C)))
;Определить функцию (LeftBr L), которая делает преобразование
;исходного списка атомов, подобное RightBr, но на самом глубоком
;уровне находится первый атом исходного списка:
;(LeftBr '(A B C)) => (((A) B) C)