#!/usr/bin/env racket
#lang racket/base
(require json racket/port net/url yotsubAPI)

;Default paths
(define 4chan-folder (build-path (find-system-path 'home-dir) "4chan"))

(define image-url-prefix "http://i.4cdn.org/g/")

;make sure the folder exists
(define (create-4chan-dir)
  (cond ((not (directory-exists? 4chan-folder))
         (make-directory 4chan-folder))))

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
  (let ([thread (4chan-data-thread board (string->number id))] ;get the thread's data
        [board-path (build-path 4chan-folder board)]
        [new-thread-path (build-path 4chan-folder board id)])
    (cond ((not (directory-exists? board-path))
           (make-directory board-path))
          ((not (directory-exists? new-thread-path))
           (make-directory new-thread-path)))
    (map (lambda (file-name) (save-image (string-append image-url-prefix file-name) new-thread-path file-name))
         (get-filenames thread))
    (displayln (format "Files saved in ~a" (path->string new-thread-path)))))

(create-4chan-dir)
;TODO cycle for all the pairs of <board thread>
(let ([arguments (current-command-line-arguments)])
  (download-images-from-thread (vector-ref arguments 0) (vector-ref arguments 1)))

