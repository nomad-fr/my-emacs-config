;;; rc-column-marker.el ---
;; configuration of column markers

(ensure-package-installed 'column-marker)

(require 'column-marker)
;; highlight column 80 in cc-mode
;; (add-hook 'c++-mode-hook
;;           (lambda ()
;;             (interactive)
;;             (column-marker-1 80)))

;; use `C-c m' interactively to highlight with `column-marker-1-face'
(global-set-key (kbd "C-c m") 'column-marker-2)

(provide 'rc-column-marker)

;;; rc-column-marker.el ends here
