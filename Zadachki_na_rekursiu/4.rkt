#lang racket
(define (LastAtom L) (if (list? L)
                         (if (null? (cdr L)) (LastAtom (car L)) (LastAtom (cdr L))
                             ) L))

(LastAtom '(((a)b)c))
