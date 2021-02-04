#lang racket
(define (Remove2 L cont)
  (if (null? L)
      (cont L)
      (if (empty? (cdr L))
          (cont L)
          (Remove2 (cdr (cdr L)) (lambda (x) (cont (cons (car L) x)))))))
          ;(cons (car L) (Remove2 (cdr (cdr L)))))))

(define (id x) x)

(Remove2 '(1 2 3 4 5 6 7 8 9) id)
;Написать функцию (Remove2 L), удаляющую из списка каждый
;второй элемент верхнего уровня:
;(Remove2 '(A B C D E)) => (A C E).