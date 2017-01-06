(require 'json)

(linum-mode)

;; configure look and feel of emacs
(defun configure()
  ;; needed to give stacktrace for debugging while development
  (setq debug-on-error t)

  ;; show linenumbers IMPORTANT read https://lists.gnu.org/archive/html/help-gnu-emacs/2008-08/msg00162.html
  ;(global-linum-mode t)
  ;(setq linum-format "%4d \u2502 ") ;; Separating line numbers from text
  ;(force-window-update)
  ;(redraw-display)
  ;(setq redisplay-dont-pause t)
  ;(redisplay t)

  ;; look configruation i guess! check if they are turely needed? but i think yes!
  (setq default-minibuffer-frame
	(make-frame
	  '((name . "minibuffer")
	    (width . 0)
	    (height . 0)
	    (minibuffer . only)
	    (top . 0)
	    (left . 0)
	    )))
  (setq new-frame
	(make-frame
	  '((name . "editor")
	    (width . 80)
	    (height . 30)
	    (minibuffer . nil)
	    (top . 50)
	    (left . 0)
	    )))

  (menu-bar-mode 0) 
  (tool-bar-mode 0) 
  (setq mode-line-format nil)

  ;; set the time delay between each action
  ;;TODO should accept (hunk_delay) and (line_delay) from argv
  (setq delay 0.509)
  );;;;;; end of look configurations

(defun apply-patch()

  (sit-for delay) 

  (let* ((json-object-type 'hash-table)
	 (json-array-type 'list)
	 (json-key-type 'string)
	 (json (json-read-file (elt argv 0)))
	 ; binding variables to json values
	 (start_blob_content (gethash "start_blob_content" json))
	 (blob_language (gethash "blob_language" json))
	 (lines (gethash "lines" json))
	 )

    ;; setting emacs mode based on blob langauge
    (cond 
      ((string= blob_language "ruby") 
       ; Changes the scratch buffer mode into ruby-mode instead (lisp-interaction-mode)
       (setq initial-major-mode 'ruby-mode)
       )
      )

    ; insert lapse start blob contents into the active buffer
    (insert (base64-decode-string start_blob_content))

    ; executing diff path operations
    (dolist (line lines)
      (cond
	; line addition
	((string= (gethash "operation" line) "addition")
	 (message "operation: addition")
	 (sit-for delay)
	 (save-excursion

	   (goto-line (string-to-number (gethash "number" line)))

	   (insert (base64-decode-string  
		     (gethash "content" line))
		   )
	   (message "line added")
	   )
	 ) ; end of line addition
	; line deletion
	((string= (gethash "operation" line) "deletion")
	 (message "operation: deletion")
	 (sit-for delay)
	 (save-excursion
	   (goto-line (string-to-number (gethash "number" line)))
	   (kill-whole-line)
	   (open-line 1) 
	   (message "line deleted")
	   (sit-for delay)
	   )
	 ) ; end of line deletion

	(sit-for delay)
	) ; end of cond
      (goto-line (string-to-number (gethash "number" line)))
      ) ; end of dolist
    ) ; end of let*
  ) ; end apply-patch

(defun render()
  ;(interactive)

  (configure)
  (sit-for delay) ;initial wait

  ; apply patch 
  (apply-patch)

  (sit-for delay) ;initial wait

  ; kills emacs so that ttyrec ends the rendering 
  (kill-emacs)
  )

;Usage: emacs -nw --load render.el "this is a file"  "+ 1 _gitlapse_eol_separator_+ 2 s"
;notice how newline is used as a seperator
(render)
