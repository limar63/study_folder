#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require racket/trace)

;x and y reversed (x is right and y is left element)
(define-struct snake (apple body scene change tick))


(define (apple-list snake) (snake-apple snake))
(define (snake-list snake) (snake-body snake))
(define (scene-size snake) (snake-scene snake))
(define (list-past-snake snake) (list (snake-scene snake) (snake-change snake) (snake-tick snake)))
(define (change-list snake) (snake-change snake))
(define (tick snake) (snake-tick snake))
(define (apple-x snake) (cadr (snake-apple snake)))
(define (apple-y snake) (car (snake-apple snake)))
(define (snake-x snake) (cadr (snake-body snake)))
(define (snake-y snake) (car (snake-body snake)))
(define (snake-second-x snake) (cadddr (snake-body snake)))
(define (snake-second-y snake) (caddr (snake-body snake)))
(define (change-x snake) (cadr (change-list snake)))
(define (change-y snake) (car (change-list snake)))
(define (new-head-x snake) (+ (snake-x snake)(change-x snake)))
(define (new-head-y snake) (+ (snake-y snake)(change-y snake)))
(define (rand-apple size) (random 0 size))
(define (head-to-body snake) (append (list (new-head-y snake) (new-head-x snake)) (snake-list snake)))

(define (length list count)
  (if (null? list)
      count
      (length (cdr list) (add1 count))))

(define (append L1 L2)
  (if (null? L1)
      L2
      (cons (car L1)
            (append (cdr L1) L2))))

(define (add-second-double-tail given-list)
  (if (null?(cddr given-list))
      (append (list (car given-list)
                    (cadr given-list))
              given-list)
      (cons (car given-list) (add-second-double-tail (cdr given-list)))))

(define (cut-the-tail list)
  (if (null? (cdr list))
      '()
      (cons (car list)
            (cut-the-tail (cdr list)))))

(define (body-check body)
  (if (null? (cddr body))
      #t
      (if (equal?
           (list (car body) (cadr body))
           (list (caddr body) (cadddr body)))
          #f
          (body-check (append (list (car body) (cadr body)) (cddddr body))))))

(define (drawing-game main-list)
  (if (null? (snake-list main-list))
      (place-image
       (square (scene-size main-list) "solid" "green")
       (+
        (* (apple-x main-list) (scene-size main-list))
        (/ (scene-size main-list) 2))
       (+
        (* (apple-y main-list) (scene-size main-list))
        (/ (scene-size main-list) 2))
       (empty-scene
        (sqr (scene-size main-list))
        (sqr (scene-size main-list))))
      (place-image
       (square (scene-size main-list) "solid" "grey")
       (+
        (* (snake-x main-list) (scene-size main-list))
        (/ (scene-size main-list) 2))
       (+
        (* (snake-y main-list) (scene-size main-list))
        (/ (scene-size main-list) 2))
       (drawing-game
        (make-snake
         (apple-list main-list)
         (cddr (snake-list main-list))
         (scene-size main-list)
         (change-list main-list)
         (tick main-list))))))

(define (moving-snake main-list)
  (if (< (tick main-list) ;controlling speed to skip ticks depending on the size of the snake body
         (/ (* (scene-size main-list) 2)
            (length (snake-list main-list) 0)))
      (make-snake
       (apple-list main-list)
       (snake-list main-list)
       (scene-size main-list)
       (change-list main-list)
       (add1 (tick main-list)))
      (if (and ;checking if apple was eaten
           (= (new-head-x main-list) (apple-x main-list)) 
           (= (new-head-y main-list) (apple-y main-list)))
          (make-snake ;was eaten, so, we generate new apple and skip cut-the-tail
           (new-apple (apple-list main-list) (head-to-body main-list) (scene-size main-list))
           (head-to-body main-list)
           (scene-size main-list)
           (change-list main-list)
           (tick main-list))
          (make-snake ;was not eaten, so, we add new head and cut the tail
           (apple-list main-list)
           (append (list (check-cord
                          (new-head-y main-list)
                          (scene-size main-list))
                         (check-cord
                          (new-head-x main-list)
                          (scene-size main-list)))
                   (cut-the-tail
                    (cut-the-tail
                     (snake-list main-list))))
           (scene-size main-list)
           (change-list main-list)
           0)))) ;changing tick to zero to reset the tick check
  


(define (check-cord cord scene)
  (if (= cord scene)
      0
      (if (< cord 0)
          (- scene 1)
          cord)))

(define (apple-check apples body)
  (if (null? body)
   #t
   (if (equal? apples (list (car body) (cadr body)))
    #f
    (apple-check apples (cddr body)))))

(define (new-apple apples body size)
  (if (apple-check apples body)
      apples
      (new-apple (list
                  (rand-apple size)
                  (rand-apple size))
                 body
                 size)))

(define (key-react w a-key)
  (cond
    [(and (key=? a-key "right")
          (not (and (= (change-x w) -1) (= (change-y w) 0))))
     (make-snake (apple-list w) (snake-list w) (scene-size w) '(0 1) (tick w))]
    [(and (key=? a-key "left")
          (not (and (= (change-x w) 1) (= (change-y w) 0))))
     (make-snake (apple-list w) (snake-list w) (scene-size w) '(0 -1) (tick w))]
    [(and (key=? a-key "up")
          (not (and (= (change-x w) 0) (= (change-y w) 1))))
     (make-snake (apple-list w) (snake-list w) (scene-size w) '(-1 0) (tick w))]
    [(and (key=? a-key "down")
          (not (and (= (change-x w) 0) (= (change-y w) -1))))
     (make-snake (apple-list w) (snake-list w) (scene-size w) '(1 0) (tick w))]
    [else w]))

(define (snake-wreck main-list)
  (if (body-check (snake-list main-list))
      #f
      #t))

(trace body-check)
(big-bang (make-snake '(0 6) '(0 1) 25 '(0 1) 0) 
  [to-draw drawing-game]
  [on-tick moving-snake]
  [on-key key-react]
  [stop-when snake-wreck])