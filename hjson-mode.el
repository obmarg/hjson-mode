;;; hhjson-mode.el --- Major mode for editing hJSON files

;; Much code taken from json-mode
;; Copyright (C) 2011-2014 Josh Johnston

;; Author: Graeme Coupar
;; URL: https://github.com/obmarg
;; Version: 0.1.1
;; Package-Requires: ()

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; extend the builtin js-mode's syntax highlighting

;;; Code:

(require 'js)
(require 'rx)

(defconst hjson-mode-quoted-string-re
  (rx (group (char ?\")
             (zero-or-more (or (seq ?\\ ?\\)
                               (seq ?\\ ?\")
                               (seq ?\\ (not (any ?\" ?\\)))
                               (not (any ?\" ?\\))))
             (char ?\"))))
(defconst hjson-mode-unquoted-string-re
  (rx ?\: (one-or-more blank) (group alpha (zero-or-more alnum))))
(defconst hjson-mode-quoted-key-re
  (rx (group (char ?\")
             (zero-or-more (or (seq ?\\ ?\\)
                               (seq ?\\ ?\")
                               (seq ?\\ (not (any ?\" ?\\)))
                               (not (any ?\" ?\\))))
             (char ?\"))
      (zero-or-more blank)
      ?\:))
(defconst hjson-mode-unquoted-key-re
  (rx (group (one-or-more (any alnum "$" "_")) (zero-or-more blank)) ?\:))
(defconst hjson-mode-number-re (rx (group (one-or-more digit)
                                         (optional ?\. (one-or-more digit)))))
(defconst hjson-mode-keyword-re  (rx (group (or "true" "false" "null"))))
(defconst hjson-mode-comment-re
  (rx (group (or
              (group ?\# (zero-or-more any))
              (group ?\/ ?\/ (zero-or-more any))))))

(defconst hjson-font-lock-keywords-1
  (list
   (list hjson-mode-quoted-key-re 1 font-lock-keyword-face)
   (list hjson-mode-unquoted-key-re 1 font-lock-keyword-face)
   (list hjson-mode-quoted-string-re 1 font-lock-string-face)
   (list hjson-mode-unquoted-string-re 1 font-lock-string-face)
   (list hjson-mode-keyword-re 1 font-lock-constant-face)
   (list hjson-mode-number-re 1 font-lock-constant-face)
   (list hjson-mode-comment-re 1 font-lock-comment-face)
   )
  "Level one font lock.")

;;;###autoload
(define-derived-mode hjson-mode javascript-mode "HJSON"
  "Major mode for editing HJSON files"
  (set (make-local-variable 'font-lock-defaults) '(hjson-font-lock-keywords-1 t)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.hjson$" . hjson-mode))
(add-to-list 'auto-mode-alist '("\\.hjsonld$" . hjson-mode))

;;;###autoload
(defun hjson-mode-show-path ()
  (interactive)
  (let ((temp-name "*hjson-path*"))
    (with-output-to-temp-buffer temp-name (hjsons-print-path))

    (let ((temp-window (get-buffer-window temp-name)))
      ;; delete the window if we have one,
      ;; so we can recreate it in the correct position
      (if temp-window
          (delete-window temp-window))

      ;; always put the temp window below the hjson window
      (set-window-buffer (split-window-below) temp-name))
    ))

(define-key hjson-mode-map (kbd "C-c C-p") 'hjson-mode-show-path)

(provide 'hjson-mode)
;;; hjson-mode.el ends here
