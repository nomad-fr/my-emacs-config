;; -*- mode: lisp; coding: utf-8-unix -*-
;;--------------------------------------------------------------------------------
;; kolorowanie składni
;;--------------------------------------------------------------------------------
(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t))
;; Set lazy-lock mode (fontifies only when not typing) with .3 sec refresh
;; time and no minimum buffer size
;; Lazy lock gives problems with Java files in RHEL4
;(setq font-lock-support-mode 'lazy-lock-mode)
(setq lazy-lock-continuity-time 0.3)
(setq lazy-lock-minimum-size (* 1024 10))       ; Fontify small buffers
(setq font-lock-maximum-size nil)       ; Fontify huge buffers
(setq font-lock-maximum-decoration t)

;; highlight FIXME, TODO and XXX as warning in some major modes
(dolist (mode '(c-mode
                cperl-mode
                html-mode-hook
                css-mode-hook
                emacs-lisp-mode))
  (font-lock-add-keywords mode
                          '(("\\(XXX\\|FIXME\\|TODO\\)"
                             1 font-lock-warning-face prepend))))

;;--------------------------------------------------------------------------------
;; polskie ustawienia
;;--------------------------------------------------------------------------------
;;(codepage-setup '1250)
;;(codepage-setup '852)
(if running-ms-windows
    (progn
      (set-keyboard-coding-system 'cp1250)
      (set-default-coding-systems 'cp1250)
      )
  )

;;--------------------------------------------------------------------------------
;; rozpoznawanie odpowiednich końcówek linii plików tekstowych
;;--------------------------------------------------------------------------------
(defun set-buffer-file-eol-type (eol-type)
  "Set the file end-of-line conversion type of the current buffer to
 EOL-TYPE.
 This means that when you save the buffer, line endings will be converted
 according to EOL-TYPE.

 EOL-TYPE is one of three symbols:

   unix (LF)
   dos (CRLF)
   mac (CR)

 This function marks the buffer modified so that the succeeding
 \\[save-buffer]
 surely saves the buffer with EOL-TYPE.  From a program, if you don't want
 to mark the buffer modified, use coding-system-change-eol-conversion
 directly [weikart]."
  (interactive "SEOL type for visited file (unix, dos, or mac): ")
  (setq buffer-file-coding-system (coding-system-change-eol-conversion
                                   buffer-file-coding-system eol-type))
  (set-buffer-modified-p t)
  (force-mode-line-update))

(global-set-key (kbd "C-c u") (lambda () (interactive) (set-buffer-file-eol-type 'unix)))
(global-set-key (kbd "C-c d") (lambda () (interactive) (set-buffer-file-eol-type 'dos)))
(global-set-key (kbd "C-c m") (lambda () (interactive) (set-buffer-file-eol-type 'mac)))


;; Make the mode-line display the standard EOL-TYPE symbols (used above)...
(setq eol-mnemonic-undecided "(?)" ;; unknown EOL type
      eol-mnemonic-unix  "(unix)" ;; LF
      eol-mnemonic-dos  "(dos)" ;; CRLF
      eol-mnemonic-mac  "(mac)") ;; CR


;;--------------------------------------------------------------------------------
;; gnuserv
;;--------------------------------------------------------------------------------
(if running-ms-windows
    (server-start)
  )

;;--------------------------------------------------------------------------------
;; chrome edit
;;--------------------------------------------------------------------------------
(when (require 'edit-server nil t)
  (setq edit-server-new-frame nil)
  (edit-server-start))

;;--------------------------------------------------------------------------------
;; pokazuj krańcowe nawiasy
;;--------------------------------------------------------------------------------
(show-paren-mode 1)
(setq show-paren-style 'expression)
(setq transient-mark-mode nil)

;;--------------------------------------------------------------------------------
;;
;;--------------------------------------------------------------------------------
(setq vc-follow-symlinks t
      visible-bell t)

;;--------------------------------------------------------------------------------
;; automatyczny odczyt plików kompresowanych
;;--------------------------------------------------------------------------------
(auto-compression-mode 1)

;;--------------------------------------------------------------------------------
;; turn off blinking cursor
;;--------------------------------------------------------------------------------
(blink-cursor-mode -1)

;;--------------------------------------------------------------------------------
;; klawisze skrótów
;;--------------------------------------------------------------------------------
(global-set-key (kbd "M-g") 'goto-line)
;; (global-set-key [(meta G)] 'what-line)

(if (string-equal "21" (substring emacs-version 0 2))
    (progn
      ;; ===== Function to delete a line =====

      ;; First define a variable which will store the previous column position
      (defvar previous-column nil "Save the column position")

      ;; Define the nuke-line function. The line is killed, then the newline
      ;; character is deleted. The column which the cursor was positioned at is then
      ;; restored. Because the kill-line function is used, the contents deleted can
      ;; be later restored by usibackward-delete-char-untabifyng the yank commands.
      (defun nuke-line()
        "Kill an entire line, including the trailing newline character"
        (interactive)

        ;; Store the current column position, so it can later be restored for a more
        ;; natural feel to the deletion
        (setq previous-column (current-column))

        ;; Now move to the end of the current line
        (end-of-line)

        ;; Test the length of the line. If it is 0, there is no need for a
        ;; kill-line. All that happens in this case is that the new-line character
        ;; is deleted.
        (if (= (current-column) 0)
            (delete-char 1)

          ;; This is the 'else' clause. The current line being deleted is not zero
          ;; in length. First remove the line by moving to its start and then
          ;; killing, followed by deletion of the newline character, and then
          ;; finally restoration of the column position.
          (progn
            (beginning-of-line)
            (kill-line)
            (delete-char 1)
            (move-to-column previous-column))))

      ;; kill whole line with C-; (because ; is close to k)
      (global-set-key (kbd "C-;") 'nuke-line)
      )

  ;; kill whole line with C-; (because ; is close to k)
  (global-set-key (kbd "C-;") 'kill-whole-line)

  )

;; string-insert-rectangle is useful but not binded to any key by default
(global-set-key (kbd "C-x r a") 'string-insert-rectangle)

;; Join lines as in Vim
;; (defun my-join-line()
;;   "Join current and next line, remove tralinig spaces leaving only one. Similar to Vim Ctrl-j"
;;   (interactive)
;;   (join-line 'forward-line)
;; )  
;; (global-set-key (kbd "C-j") 'my-join-line)

;; keep minibuffer history between session
(if (not (string-equal "21" (substring emacs-version 0 2)))
    (savehist-mode t)
  )

;; autocompletion
(global-set-key (kbd "ESC ESC") 'dabbrev-expand) ; ESC ESC ESC not usable :-/

;; comment-or-uncomment-region-or-line
; it's almost the same as in textmate.el but I wrote it before I know about
; textmate.el, in fact that's how I found textmate.el, by googling this
; function to see if somebody already did that in a better way than me.
(defun comment-or-uncomment-region-or-line ()
  "Like comment-or-uncomment-region, but if there's no mark \(that means no
region\) apply comment-or-uncomment to the current line"
  (interactive)
  (if (not mark-active)
      (comment-or-uncomment-region
        (line-beginning-position) (line-end-position))
      (if (< (point) (mark))
          (comment-or-uncomment-region (point) (mark))
        (comment-or-uncomment-region (mark) (point)))))
(global-set-key (kbd "C-'") 'comment-or-uncomment-region-or-line)

;;--------------------------------------------------------------------------------
;; function that inserts incrementing numbers in place
;;--------------------------------------------------------------------------------
(defun insert-numbers (min max)
  "Insert numbers incrementing in lines at point."
  (interactive "nFrom: \nnTo: ")
  (let ((insertcolumn (current-column))
        (first t))
    (push-mark)
    (while (<= min max)
      (or first
          (progn
            (forward-line 1)
            (or (bolp) (insert ?\n))
            (move-to-column-force insertcolumn)))
      (setq first nil)
      (insert (format "%d" min))
      (setq min (+ 1 min)))))

;; (defun insert-numbers (min max)
;;   (interactive "nFrom: \nnTo: ")
;;   (let ((margin (buffer-substring (save-excursion (beginning-of-line) (point))
;;                                (point))))
;;  (when (<= min max)
;;    (insert (format "%d" min))
;;    (setq min (+ 1 min))
;;    (while (<= min max)
;;      (insert (format "\n%s%d" margin min))
;;      (setq min (+ 1 min))))))

;;--------------------------------------------------------------------------------
;; recentf mode
;;--------------------------------------------------------------------------------
(recentf-mode t)
(global-set-key (kbd "<f8>") 'recentf-open-files)

;;--------------------------------------------------------------------------------
;; ido!
;;--------------------------------------------------------------------------------
;;(require 'ido)
(ido-mode t)
;; (setq ido-enable-flex-matching t)

(global-set-key (kbd "C-x C-r") 'ido-recentf-open)
(defun ido-recentf-open ()
  "Use 'ido-completing-read to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file:" recentf-list))
      (message "Opening file...")
    (message "Aborting")))

;; scrolling settings
;;(setq scroll-preserve-screen-position t)
;;(setq scroll-margin 2)
;;(setq scroll-step 1)

;; files should always end with a new line
;; (setq require-final-newline t)

;; no automatic saving and ugly #file#
;; (setq auto-save-default nil)

;; tramp claque (really bad french play-on-word)
;(require 'tramp)
;(setq tramp-default-method "scp")

;; xml-mode is better than nxml-mode or html-mode
(add-to-list 'auto-mode-alist
  '("\\.html\\'\\|\\.xml\\'\\|\\.phtml\\'" . xml-mode))

;; don't let Customize mess with my .emacs
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

