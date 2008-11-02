;;; ergomap.el --- Functions for remapping keyboard, some remappings
;;;                that should be more hand-friendly.

;; Author: Nelson Minar <nelson@santafe.edu>
;; Maintainer: Nelson Minar <nelson@santafe.edu>
;; Created: 10 Aug 1995
;; Keywords: keyboard mapping RSI ergonomic
;; Copyright (C) 1995 Nelson Minar
;;   You have permission to freely redistribute and modify this file.

;; To use this, just run (load-library "ergomap"), preferably after
;; other emacs packages have loaded. This alone will not do anything,
;; call (ergomap-remap-keyboard) to install my particular keymap, or
;; you can write your own similar function.

;; The idea is to limit the use of C-key and M-key combos for common
;; functions by replacing those keys with warning messages in order to
;; teach myself new habits, and remapping those keys to other keyboards.
;; These keymappings are set up for an IBM 101 keyboard.

;; If you're running emacs under X, you'll have no problem using these
;;   keys, assuming that your X terminal is configured correctly.
;; If you're using emacs on a tty, you need to make sure that the lisp
;;   library "term/$TERM.el" defines the keycodes you want. [home] and
;;   [end] are particularly tricky.

;; First, functions to remap the keyboard.
(defun disable-key (keymap oldkey newkey)
  "Disable a keybinding, and replace it with a message of what key to use."
  (define-key keymap oldkey 
    (list 'lambda ()
	  "Disabled key"
	  '(interactive)
	  (list 'message "Key disabled, use %s instead" newkey))))

(defun move-key (keymap oldkey newkey)
  "Move a local key binding to a new key and install a disabled message 
in the old one."
  (define-key keymap newkey (lookup-key keymap oldkey))
  (disable-key keymap oldkey newkey))

;; convenience functions for the global map.
(defun global-disable-key (oldkey newkey)
  "Disable a keybinding in the global map, and replace it with a message
of what key to use."
  (disable-key (current-global-map) oldkey newkey))

(defun global-move-key (oldkey newkey)
  "Move a global key binding to a new key and install a disabled message 
in the old one."
  (move-key (current-global-map) oldkey newkey))

;; Now, remappings: move some of the common chord combos to other keys.
;; This mapping is optimized for an IBM-101 style keyboard, function key
;; assignments are somewhat arbitrary. See above about [home] and [end].
;; Note - this function doesn't actually execute, you'll need to call it
;;   yourself if appropriate.
(defun ergomap-remap-keyboard ()
  "Remap the keyboard to be more hand-friendly"
  (mapcar (function (lambda (l)
		      (global-move-key (car l) (car (cdr l)))))
	  '(("\C-a"     [home])
	    ("\C-e"     [end])
	    ("\C-v"     [next])
	    ("\M-v"     [prior])
	    ("\C-b"     [left])
	    ("\C-f"     [right])
	    ("\C-p"     [up])
	    ("\C-n"     [down])
	    ("\C-x\C-f" [f2])		;find file
	    ("\C-x\C-s" [f3])		;save buffer
	    ("\C-xk"    [f4])		;kill buffer
	    ("\C-xb"    [f5])		;switch buffer
	    ("\C-xo"    [f6])		;switch window
  	  ("\C-k"     "\M-d") ;delete line
	    ))
  ;; These keymappings are a little strange, so they're listed separately.
  ;; On my keyboard, I've mapped the key marked "Backspace" to mean Delete,
  ;; and the key marked "Delete" to mean F13. These emacs keybindings below
  ;; mean that the Insert key does kill-line, the Delete key does delete-char
  (global-move-key "\C-k" [insert])
  (global-move-key "\C-d" [f13])

  ;; Assign [f1] to also be C-x. We can't unmap C-x because it's
  ;; still a prefix. This doesn't work in emacs 19.29 for some reason -
  ;; it's colliding with help.
  (global-set-key [f1] 'Control-X-prefix))

;; Mode-specific setup example: for folding mode, in this case (only
;;   works with a hacked version that is more emacs19ish, contact Nelson.)
;; folding.el redefines some cursor movement keys, so we define them
;; back in the folding-mode-map. Note that we can't use local-move-key
;; because this hook is invoked many times.

(defun folding-mode-ergo-hook ()
  "Remap folding-mode keys for cursor movement"
  (define-key folding-mode-map [right] 'fold-forward-char)
  (define-key folding-mode-map [left] 'fold-backward-char)
  (define-key folding-mode-map [end] 'fold-end-of-line)
  (disable-key folding-mode-map "\C-f" [right])
  (disable-key folding-mode-map "\C-b" [left])
  (disable-key folding-mode-map "\C-e" [end]))

(add-hook 'folding-mode-hook 'folding-mode-ergo-hook t)
