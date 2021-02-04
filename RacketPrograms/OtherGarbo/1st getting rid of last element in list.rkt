#lang racket
(require racket/trace)
(define (RemoveLast L) (if (null? (cdr L)) '() (cons (car L) (RemoveLast(cdr L)))))
(trace RemoveLast)
(RemoveLast '(1 (2 3) (4 5)))

;(RemoveLast (1 2 3 4 5)
;(RemoveLast (cons 1 (RemoveLast(2 3 4 5))))
;(RemoveLast (cons 1 (cons 2 (RemoveLast(3 4 5)))))
;(RemoveLast (cons 1 (cons 2 (cons 3 (RemoveLast(4 5))))))
;(RemoveLast (cons 1 (cons 2 (cons 3 (cons 4 (RemoveLast(5)))))))
;(RemoveLast (cons 1 (cons 2 (cons 3 (cons 4 '())))))
