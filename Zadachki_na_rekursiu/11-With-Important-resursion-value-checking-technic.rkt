#lang racket
(require racket/trace)
(define (Position X L) 
(if (null? (cdr L))
    0
    (if (equal? X (car L))
        1
        (let ((tmp (Position X (cdr L)))) (if (= tmp 0) 0 (+ tmp 1))))))
(trace Position)
(Position 'a '(x c v a s d e r a))
;Составить функцию (Position X L), возвращающую порядковый
;номер значения Х в списке L, либо 0, если выражение Х не
;встречается в списке на верхнем уровне.

;(Position 's '(x c v a s d e r a))
;(IF (NULL (CDR '(X C V A S D E R A))) 0 (IF (= 'S (CAR '(X C V A S D E R A))) 1 (LET ((TMP (POSITION 'S (CDR '(X C V A S D E R A))))) (IF (= TMP 0) 0 (+ TMP 1)))))
;(LET ((TMP (POSITION 'S '(C V A S D E R A)))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (POSITION 'S '(V A S D E R A)))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (LET ((TMP (POSITION 'S '(A S D E R A)))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (LET ((TMP (LET ((TMP (POSITION 'S '(S D E R A)))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (LET ((TMP (LET ((TMP 1)) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (LET ((TMP (IF (= 1 0) 0 (+ 1 1)))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (LET ((TMP 2)) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP (IF (= 2 0) 0 (+ 2 1)))) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (LET ((TMP 3)) (IF (= TMP 0) 0 (+ TMP 1))))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP (IF (= 3 0) 0 (+ 3 1)))) (IF (= TMP 0) 0 (+ TMP 1)))
;(LET ((TMP 4)) (IF (= TMP 0) 0 (+ TMP 1)))
;(IF (= 4 0) 0 (+ 4 1))
;5
