;; ;; This is only needed once, near the top of the file
(eval-when-compile
;;   ;; Following line is not needed if use-package.el is in ~/.emacs.d
;;   (add-to-list 'load-path "<path where use-package is installed>")
  (require 'use-package))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(use-package ayu-theme
  :config (load-theme 'ayu-dark t))