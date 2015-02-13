#!/usr/bin/env racket
#lang racket/base
(require json racket/port net/url yotsubAPI)

;Default paths
(define current-4chan-folder (make-parameter (build-path (find-system-path 'home-dir) "4chan")))

(define image-url-prefix "http://i.4cdn.org/")

(define (create-dir-unless-exists dir)
  (unless (directory-exists? dir)
    (make-directory dir)))

(define (get-filenames ht)
  ;TODO get some options to filter undesirable extensions, e.g., download only webm files
  (for/list ([post (hash-ref ht 'posts)]
             #:when (hash-has-key? post 'tim)) ;list of HTs, each post is an ht
            (format "~a~a" (hash-ref post 'tim) (hash-ref post 'ext))))

;downloads the image
(define (download urlstr)
  (port->bytes (get-pure-port (string->url urlstr))))

;saves the image to a file
(define (save-image url path file-name)
  (call-with-output-file (build-path path file-name)
                         ;the truncate is irrelevant since there shouldn't be any file in the directory
                         (lambda (out) (write-bytes (download url) out)) #:exists 'truncate))

(define (download-images-from-thread board id)
  (define thread (4chan-data-thread board (string->number id))) ;get the thread's data
  (define board-path (build-path (current-4chan-folder) board))
  (define new-thread-path (build-path (current-4chan-folder) board id))
  (create-dir-unless-exists board-path)
  (create-dir-unless-exists new-thread-path)
  (for-each (lambda (file-name)
              (save-image (string-append image-url-prefix board "/" file-name) new-thread-path file-name))
            (get-filenames thread))
  (printf "Files saved in ~a~%" (path->string new-thread-path)))

(create-dir-unless-exists (current-4chan-folder))
;TODO cycle for all the pairs of <board thread>
(let ([arguments (current-command-line-arguments)])
  (download-images-from-thread (vector-ref arguments 0) (vector-ref arguments 1)))

