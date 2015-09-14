;; Emacs config: david@davidjenni.com
;; no GUI disctractions
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

;;; theme, colors & frame setup
(load-theme 'wombat)
(set-cursor-color "orange")
(set-face-attribute 'region nil :background "cornflower blue")
(set-face-attribute 'isearch nil :background "gold" :foreground "black")
(set-face-attribute 'lazy-highlight nil :background "dark goldenrod" :foreground "white")

(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 150))

;; global setup
(fset 'yes-or-no-p 'y-or-n-p)

;; Write backup files to own directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))
;; Make backups of files, even when they're in version control
(setq vc-make-backup-files t)


(show-paren-mode 1)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
(global-visual-line-mode nil)
(setq-default left-fringe-width nil)
(setq-default indent-tabs-mode nil)
(setq large-file-warning-threshold nil)
(setq split-width-threshold nil)
(setq visible-bell t)
(setq line-number-mode t)
(setq column-number-mode t)
(setq-default linum-mode 1)

;; smoother scrolling:
(setq scroll-margin 5
      scroll-conservatively 9999
      scroll-step 1)

;; Auto refresh buffers
(global-auto-revert-mode 1)

;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; package management:
(setq load-prefer-newer t)

(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(setq package-enable-at-startup nil)
(package-initialize)

;; bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(let ((default-directory "/usr/local/share/emacs/site-lisp/"))
  (normal-top-level-add-subdirs-to-load-path))


;; Save point position between sessions
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

;; packages (MELPA etc.)
(use-package session
 :ensure t
 :config (add-hook 'after-init-hook 'session-initialize)
 )

(use-package evil
 :ensure t
 :config (evil-mode 1)
 )

(use-package powerline
  :ensure t
  :config (powerline-evil-vim-color-theme)
  )

(use-package dired-details
  :config ((setq-default dired-details-hidden-string "--- ")
           (dired-details-install))
  )

(use-package smartparens
 :ensure t
 :config (smartparens-global-mode t)
 )

; Powerful minibuffer input framework
(use-package helm
  :ensure t
  :bind (("C-c c b" . helm-resume))
  :init (progn (helm-mode 1)
               (with-eval-after-load 'helm-config
                 (warn "`helm-config' loaded! Get rid of it ASAP!")))
  :config (setq helm-split-window-in-side-p t)
  :diminish helm-mode)

(use-package helm-misc                  ; Misc helm commands
  :ensure helm
  :bind (([remap switch-to-buffer] . helm-mini)))

(use-package helm-command               ; M-x in Helm
  :ensure helm
  :bind (([remap execute-extended-command] . helm-M-x)))

  
