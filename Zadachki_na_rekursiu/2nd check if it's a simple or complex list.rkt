#lang racket
(require racket/trace)

(define (OneLevel L) (if (null? L) #t (if (list? (car L)) #f (OneLevel (cdr L)))))
(trace OneLevel)
(OneLevel '(1 2 (3 4) 5))