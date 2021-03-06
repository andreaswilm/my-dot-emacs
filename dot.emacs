;; -*- mode: lisp -*-
;;
;; NOTE: tested on Emacs 24 only
;;


;; startup
(setq debug-on-error t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")
;; non-elpa libraries should go here
(add-to-list 'load-path "~/.emacs.d/lisp")

;; ELPA
;; http://emacswiki.org/emacs/ELPA
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(package-initialize)


;; make OS X Emacs GUI use the $PATH set up by the user's shell 
;; https://github.com/purcell/exec-path-from-shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

; Turn beep off
(setq visible-bell nil)

;; http://www.emacswiki.org/emacs/ShowParenMode
(show-paren-mode t)
(setq show-paren-delay 0)

;; http://emacswiki.org/emacs/InteractivelyDoThings
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t); fuzzy matching
(setq ido-everywhere t)

;; markdown
(add-to-list 'auto-mode-alist '("\\.md" . markdown-mode))

;; groovy for nextflow
(add-to-list 'auto-mode-alist '("\\.nf" . groovy-mode))

;; yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))

;; https://github.com/spotify/dockerfile-mode
(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;; http://www.emacswiki.org/emacs/insert-time-string.el
(require 'insert-time-string)
(setq insert-time-string-default-format "iso-8601")


;; default tab behaviour
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)


;; numbering
(line-number-mode t)
(column-number-mode t)


;; line handling
(setq-default truncate-lines t)
;; make sure your text files end in a newline (setq
;; require-final-newline 't) or let Emacs ask about any time it is
;; needed
(setq require-final-newline 'query)


;; python
(load-file "~/.emacs.python.el")


;; http://www.emacswiki.org/cgi-bin/emacs-en/QuickYes
(defalias 'yes-or-no-p 'y-or-n-p)


;; hungry-delete
(require 'hungry-delete)
(global-set-key (kbd "C-c C-d") 'hungry-delete-forward)


;; scrolling
;; http://www.emacswiki.org/cgi-bin/wiki/SmoothScrolling
(setq scroll-step 1
      scroll-conservatively 10000)

;; if using aspell instead of ispell
(setq ispell-list-command "--list")


;; http://auto-complete.org/
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/dict")
(ac-config-default)
(ac-flyspell-workaround)
;; If you are being annoyed with displaying completion menu, you can disable
;; automatic starting completion by setting ac-auto-start to nil.
(setq ac-auto-start nil)
;; delay showing completion menu by setting ac-auto-show-menu to seconds in real number.
;; (setq ac-auto-show-menu 0.8)
;; start completion automatically after X characters
;; (setq ac-auto-start 4)


;; http://www.emacswiki.org/emacs/MidnightMode
;; Midnight mode is a package by SamSteingold that comes with Emacs for running configured actions at every “midnight”.
;; By default, the ‘midnight-hook’ is configured to just run the CleanBufferList command.
(require 'midnight)
(midnight-delay-set 'midnight-delay "11:59am")


;; http://www.emacswiki.org/emacs/RecentFiles
(require 'recentf)
(progn
  (setq recentf-menu-path '("File"))
  ;; when using trampmode with recentf.el, it's advisable to turn
  ;; off the cleanup feature of recentf
  (setq recentf-auto-cleanup 'never) ;; disable before we start recentf!
  (recentf-mode t))


;; uniquify
;; show path info in buffers with otherwise identical filenames
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)


;; window-system specifics
(if window-system
    (progn
      (message "Setting window-system specific stuff")
      (server-start)
      
      (global-unset-key "\C-z"); iconify-or-deiconify-frame (C-x C-z)
      
      ;; del genuinley deletes region, ie it's not put on the kill ring
      (delete-selection-mode t)
      
      (tool-bar-mode -1)
      
      (message "Setting up font")
      (condition-case nil
          (set-face-attribute 'default nil :font "Inconsolata-13:weight=normal")
        (error (message "Couldn't load Inconsolata")))
      
      ;; https://github.com/juba/color-theme-tangotango via MELPA
      (load-theme 'tangotango t)))


;; org-mode

(add-hook 'org-mode-hook
          (lambda ()
            (message "Setting up my org-mode hooks")
            ;; http://stackoverflow.com/questions/11384516/how-to-make-all-org-files-under-a-folder-added-in-agenda-list-automatically
            ;; (setq org-agenda-files '("~/Dropbox/gis/org"))
            ;; http://orgmode.org/worg/org-faq.html#set-agenda-files-recursively
            (setq org-agenda-files
                  (mapcar 'abbreviate-file-name
                          (split-string
                           (shell-command-to-string "find ~/Dropbox/gis/org -name \"*.org\"") "\n")))            
            ;; http://stackoverflow.com/questions/10642888/syntax-highlighting-within-begin-src-block-in-emacs-orgmode-not-working
            (setq org-src-fontify-natively t)
            (setq org-agenda-span 14)
            ;; capture time stamps and/or notes when TODO state changes, in particular when a task is DONE
            (setq org-log-done 'time)
            ))

;; http://emacs.stackexchange.com/questions/27841/unable-to-decrypt-gpg-file-using-emacs-but-command-line-gpg-works
(setf epa-pinentry-mode 'loopback)

;; MacOSX specifics
;;
;; Inspired by http://xahlee.org/emacs/xah_emacs_mac.el
;;
;; OS X Window System
(if (string-equal system-type "darwin")
    (progn
      (message "Customising for Darwin")
      ; delete char on external keyboard (kp) is bound to
      ; backward-delete-char-untabify instead of delete-char on Mac Os X.
      (global-set-key [kp-delete] 'delete-char)
      (if (eq window-system 'ns); Not 'mac!
          (progn
            (message "Customising for OS X window-system")
            ;; see also http://lojic.com/blog/2010/03/17/switching-from-carbonemacs-to-emacs-app/
            (setq ns-command-modifier 'meta)))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   (quote
    ("~/Dropbox/gis/org/cloud.org" "~/Dropbox/gis/org/germs.org" "~/Dropbox/gis/org/hi-c-rna.org" "~/Dropbox/gis/org/lofreq-indel.org" "~/Dropbox/gis/org/lofreq.org" "~/Dropbox/gis/org/master.org" "~/Dropbox/gis/org/meeting-minutes.org" "~/Dropbox/gis/org/nscc.org" "~/Dropbox/gis/org/org-mode-notes.org" "~/Dropbox/gis/org/pipeline-framework.org" "~/Dropbox/gis/org/pipelines.org" "~/Dropbox/gis/org/sg10k.org" "/Users/wilma/Dropbox/gis/org/cloud.org" "/Users/wilma/Dropbox/gis/org/germs.org" "/Users/wilma/Dropbox/gis/org/hi-c-rna.org" "/Users/wilma/Dropbox/gis/org/lofreq-indel.org" "/Users/wilma/Dropbox/gis/org/lofreq.org" "/Users/wilma/Dropbox/gis/org/master.org" "/Users/wilma/Dropbox/gis/org/meeting-minutes.org" "/Users/wilma/Dropbox/gis/org/nscc.org" "/Users/wilma/Dropbox/gis/org/org-mode-notes.org" "/Users/wilma/Dropbox/gis/org/pipeline-framework.org" "/Users/wilma/Dropbox/gis/org/pipelines.org" "/Users/wilma/Dropbox/gis/org/sg10k.org")))
 '(package-selected-packages
   (quote
    (nim-mode go-mode markdown-preview-mode snakemake-mode groovy-mode markdown-mode yaml-mode tangotango-theme hungry-delete exec-path-from-shell auto-complete))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
