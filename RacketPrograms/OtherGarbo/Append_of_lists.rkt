#lang racket
(require racket/trace)
(define (append L1 L2)
  (if (null? L1)
      L2
      (cons (car L1) (append (cdr L1) L2))))
(trace append)
(append '(a b c) '(d e))