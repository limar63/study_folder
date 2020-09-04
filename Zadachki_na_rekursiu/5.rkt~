#lang racket
(require racket/trace)
(define (DeleteA L X) (if (equal? (car L) X)
                          (cdr L)
                          (cons (car L) (DeleteA (cdr L) X))))
(DeleteA '(a x b x (x x a) c x) 'x)

(define (DeleteB L X) (if (null? L)
                          null
                          (if (equal? (car L) X)
                              (DeleteB (cdr L) X)
                              (cons (car L) (DeleteB (cdr L) X)))))
(DeleteB '(a x b x (x x a) c x) 'x)

