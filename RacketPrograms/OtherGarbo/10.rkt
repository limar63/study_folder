#lang racket
(require racket/trace)
(define (Elem N L)
  (if (null? L)
      null
      (if (= N 0)
          (car L)
          (Elem (- N 1) (cdr L)))))
(Elem 10 '(0 1 2 3 4 5 6 7 8))
;Написать функцию (Elem N L), которая выдаёт N-тый элемент
;верхнего уровня списка L. Если длина списка меньше N, то функция
;возвращает NIL.
