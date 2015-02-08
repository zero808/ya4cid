#!/usr/bin/env racket
#lang racket/base

(require json yotsubAPI)
;4chan-data
;4chan-data-page
;4chan-data-catalog
;4chan-data-thread
(define catalog (4chan-data-catalog "g"))
(define lispg (4chan-catalog-find-lisp-general catalog))
;get a thread
;try to iterate over the posts
;try to look up for the trim atribute or whatever it's called and get the filename
;create a folder
;download every image into that folder



;on the main function
;read the input which should be
;./ya4cid.rkt [<board> <thread>]+
;(for ([posts keys (in-hash b)])

(define (get-filenames ht)
  (for/list ([post (hash-ref ht 'posts)]
             #:when (hash-has-key? post 'tim)) ;list of HTs, each post is an ht
            (format "~a~a" (hash-ref post 'tim) (hash-ref post 'ext))))

;we might make two different functions one for unix and another for windows
(define (download-images-from-thread board id)
  ;1st create a file for the thread under, for e.g., ~/4chan/<board>/<id>/
  ;see http://docs.racket-lang.org/reference/Filesystem.html
  ;2nd either
  ;     a) make sure we 'cd' to that directory
  ;     b) pass the destination path to wget in step 3
  ;3rd start downloading them creating a process using wget
  ;if we decide to use threads check (split-at lst pos) so we can divide them among threads
  )
