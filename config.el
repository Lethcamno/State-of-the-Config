;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;A script for getting the SLY REPL running successfully
(defun my-sly--repl-buffer ()
  "Return an existing SLY REPL buffer, creating one if needed."
  (or (cl-find-if (lambda (b)
                    (with-current-buffer b
                      (derived-mode-p 'sly-mrepl-mode)))
                  (buffer-list))
      (progn (sly-mrepl)           ; create/show it
             (cl-find-if (lambda (b)
                           (with-current-buffer b
                             (derived-mode-p 'sly-mrepl-mode)))
                         (buffer-list)))))

(defun my-sly-send-region-to-repl (beg end &optional keep-focus)
  "Send region to the SLY REPL, insert it at the prompt, and eval it.
With prefix arg (C-u), keep focus in the source buffer."
  (interactive "r\nP")
  (let* ((code (buffer-substring-no-properties beg end))
         (rb (my-sly--repl-buffer)))
    (with-current-buffer rb
      (goto-char (point-max))
      (insert code)
      (sly-mrepl-return))
    (unless keep-focus
      (pop-to-buffer rb))))

(defun my-sly-send-defun-to-repl (&optional keep-focus)
  "Send defun at point to the SLY REPL and eval it.
With prefix arg (C-u), keep focus in the source buffer."
  (interactive "P")
  (save-excursion
    (mark-defun)
    (my-sly-send-region-to-repl (region-beginning) (region-end) keep-focus)))

(map! :map sly-mode-map :localleader "l" #'my-sly-send-defun-to-repl)

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook 'org-bullets-mode))

;this eliminates the org symbols like * and / when they are used
(setq org-hide-emphasis-markers t)

;; ;inserting this permitted the quote notation to become usable
;; (require 'org-tempo)

;this logs the time of completion for an org Task
(setq org-log-done 'time)

;latex extensions suggested by michael nueper for pdf viewing
(use-package! auctex
  :config
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (setq +latex-viewers '(pdf tools)))
(setq lsp-tex-server 'digestif)

;;essential for using org-roam
;1 - these are basic org roam functionalities
;2 - this is for converting my org files to roam noiddd
(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Emacs-Zettelkasten/")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-db-autosync-enable))

;for accessing a graph of my roam files
(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :commands org-roam-ui-open
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; This elisp code uses use-package, a macro to simplify configuration. It will
;; install it if it's not available, so please edit the following code as
;; appropriate before running it.

;; Note that this file does not define any auto-expanding YaSnippets.


;; AucTeX settings - almost no changes
(use-package latex
  :ensure auctex
  :hook ((LaTeX-mode . prettify-symbols-mode))
  :bind (:map LaTeX-mode-map
         ("C-S-e" . latex-math-from-calc))
  :config
  ;; Format math as a Latex string with Calc
  (defun latex-math-from-calc ()
    "Evaluate `calc' on the contents of line at point."
    (interactive)
    (cond ((region-active-p)
           (let* ((beg (region-beginning))
                  (end (region-end))
                  (string (buffer-substring-no-properties beg end)))
             (kill-region beg end)
             (insert (calc-eval `(,string calc-language latex
                                          calc-prefer-frac t
                                          calc-angle-mode rad)))))
          (t (let ((l (thing-at-point 'line)))
               (end-of-line 1) (kill-line 0)
               (insert (calc-eval `(,l
                                    calc-language latex
                                    calc-prefer-frac t
                                    calc-angle-mode rad))))))))

(use-package preview
  :after latex
  :hook ((LaTeX-mode . preview-larger-previews))
  :config
  (defun preview-larger-previews ()
    (setq preview-scale-function
          (lambda () (* 1
                   (funcall (preview-scale-from-face)))))))

;; CDLatex settings
(use-package cdlatex
  :ensure t
  :hook (LaTeX-mode . turn-on-cdlatex)
  :bind (:map cdlatex-mode-map
              ("<tab>" . cdlatex-tab)))

(use-package org-table
  :after cdlatex
  :bind (:map orgtbl-mode-map
              ("<tab>" . lazytab-org-table-next-field-maybe)
              ("TAB" . lazytab-org-table-next-field-maybe))
  :init
  (add-hook 'cdlatex-tab-hook 'lazytab-cdlatex-or-orgtbl-next-field 90)
  ;; Tabular environments using cdlatex
  (add-to-list 'cdlatex-command-alist '("smat" "Insert smallmatrix env"
                                       "\\left( \\begin{smallmatrix} ? \\end{smallmatrix} \\right)"
                                       lazytab-position-cursor-and-edit
                                       nil nil t))
  (add-to-list 'cdlatex-command-alist '("bmat" "Insert bmatrix env"
                                       "\\begin{bmatrix} ? \\end{bmatrix}"
                                       lazytab-position-cursor-and-edit
                                       nil nil t))
  (add-to-list 'cdlatex-command-alist '("pmat" "Insert pmatrix env"
                                       "\\begin{pmatrix} ? \\end{pmatrix}"
                                       lazytab-position-cursor-and-edit
                                       nil nil t))
  (add-to-list 'cdlatex-command-alist '("tbl" "Insert table"
                                        "\\begin{table}\n\\centering ? \\caption{}\n\\end{table}\n"
                                       lazytab-position-cursor-and-edit
                                       nil t nil))
  :config
  ;; Tab handling in org tables
  (defun lazytab-position-cursor-and-edit ()
    ;; (if (search-backward "\?" (- (point) 100) t)
    ;;     (delete-char 1))
    (cdlatex-position-cursor)
    (lazytab-orgtbl-edit))

  (defun lazytab-orgtbl-edit ()
    (advice-add 'orgtbl-ctrl-c-ctrl-c :after #'lazytab-orgtbl-replace)
    (orgtbl-mode 1)
    (open-line 1)
    (insert "\n|"))

  (defun lazytab-orgtbl-replace (_)
    (interactive "P")
    (unless (org-at-table-p) (user-error "Not at a table"))
    (let* ((table (org-table-to-lisp))
           params
           (replacement-table
            (if (texmathp)
                (lazytab-orgtbl-to-amsmath table params)
              (orgtbl-to-latex table params))))
      (kill-region (org-table-begin) (org-table-end))
      (open-line 1)
      (push-mark)
      (insert replacement-table)
      (align-regexp (region-beginning) (region-end) "\\([:space:]*\\)& ")
      (orgtbl-mode -1)
      (advice-remove 'orgtbl-ctrl-c-ctrl-c #'lazytab-orgtbl-replace)))

  (defun lazytab-orgtbl-to-amsmath (table params)
    (orgtbl-to-generic
     table
     (org-combine-plists
      '(:splice t
                :lstart ""
                :lend " \\\\"
                :sep " & "
                :hline nil
                :llend "")
      params)))

  (defun lazytab-cdlatex-or-orgtbl-next-field ()
    (when (and (bound-and-true-p orgtbl-mode)
               (org-table-p)
               (looking-at "[[:space:]]*\\(?:|\\|$\\)")
               (let ((s (thing-at-point 'sexp)))
                 (not (and s (assoc s cdlatex-command-alist-comb)))))
      (call-interactively #'org-table-next-field)
      t))

  (defun lazytab-org-table-next-field-maybe ()
    (interactive)
    (if (bound-and-true-p cdlatex-mode)
        (cdlatex-tab)
      (org-table-next-field))))

;;potentially questionable latex code (which seems to work fine)
(after! tex
  (add-to-list 'TeX-command-list
               '("LatexMk" "latexmk -pdf -synctex=1 %s" TeX-run-TeX nil t)))
(after! org
  (setq org-startup-with-latex-preview t
        org-format-latex-options (plist-put org-format-latex-options :scale 1.2)))

(after! org
  (setq org-latex-preview-auto-toggle t))

;;this is for ensuring I can edit latex previews normally
(use-package! org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))

;;this is to ensure pdfs are presented as I want after rendering
(setq split-height-threshold nil)
(setq split-width-threshold 0)

;;an attempt to get racket to be usable in code blocks
(with-eval-after-load 'geiser
  (setq geiser-active-implementations '(racket))
  (setq geiser-racket-binary "/usr/bin/racket")  ;; path to your Racket binary
)

;;this is to get slime working

(load (expand-file-name "~/quicklisp/slime-helper.el"))
;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "sbcl")
(require 'slime)
(slime-setup '(slime-fancy))                ;; optional extra modules for SLIME


;; ;; (map! :i :desc "YAS Expand" #'yas-next-field-or-cdlatex)
;; (use-package org-latex-preview
;;   :config

;;   (add-hook 'org-mode-hook 'org-latex-preview-mode)

;;   (setq org-latex-preview-mode-display-live t)

;;   ;; More immediate live-previews -- the default delay is 1 second
;;   (setq org-latex-preview-mode-update-delay 0.25))

;; enables the org-mode checkbox
;; (require 'org-checkbox)
