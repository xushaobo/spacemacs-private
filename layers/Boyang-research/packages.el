;;; packages.el --- Boyang-research layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2021 Sylvain Benner & Contributors
;;
;; Author: Boyang Yan <guanghui8827@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `Boyang-research-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `Boyang-research/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `Boyang-research/pre-init-PACKAGE' and/or
;;   `Boyang-research/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst Boyang-research-packages
  '(
    (org-roam :location
              (recipe :fetcher github
                      :repo "org-roam/org-roam"
                      :files (:defaults "extensions/*")))
    (org-roam-bibtex :location
                     (recipe :fetcher github :repo "org-roam/org-roam-bibtex"))
    (bibtex)
    deft
    )
  "The list of Lisp packages required by the Boyang-research layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun Boyang-research/init-org-roam ()
  (use-package org-roam
    ;; :diminish
    ;; :hook (after-init . org-roam-db-autosync-enable)
    :defer t
    ;; :demand t
    :hook (after-init . org-roam-mode)
    ;; :init
    ;; (add-hook 'after-init-hook 'org-roam-mode)
    :init
    (setq org-roam-v2-ack t)
    :custom
    (org-roam-directory org-roam-directory) ;; please change it to your path
    :config
    (progn
      (spacemacs/declare-prefix "aor" "org-roam")
      (spacemacs/declare-prefix "aord" "org-roam-dailies")
      (spacemacs/declare-prefix "aort" "org-roam-tags")
      (spacemacs/set-leader-keys
        "aordy" 'org-roam-dailies-goto-yesterday
        "aordt" 'org-roam-dailies-goto-today
        "aordT" 'org-roam-dailies-goto-tomorrow
        "aordd" 'org-roam-dailies-goto-date
        "aor/" 'org-roam-node-find
        "aorc" 'org-roam-capture
        ;; "aorg" 'org-roam-graph
        "aorh" 'org-id-get-create
        "aori" 'org-roam-node-insert
        "aorl" 'org-roam-buffer-toggle
        "aorta" 'org-roam-tag-add
        "aortd" 'org-roam-tag-delete
        "aora" 'org-roam-alias-add)

      (spacemacs/declare-prefix-for-mode 'org-mode "mr" "org-roam")
      (spacemacs/declare-prefix-for-mode 'org-mode "mrd" "org-roam-dailies")
      (spacemacs/declare-prefix-for-mode 'org-mode "mrt" "org-roam-tags")
      (spacemacs/set-leader-keys-for-major-mode 'org-mode
        "rb" 'org-roam-switch-to-buffer
        "rdy" 'org-roam-dailies-goto-yesterday
        "rdt" 'org-roam-dailies-goto-today
        "rdT" 'org-roam-dailies-goto-tomorrow
        "rdd" 'org-roam-dailies-goto-date
        "r/" 'org-roam-node-find
        "rc" 'org-roam-capture
        ;; "rg" 'org-roam-graph
        "rh" 'org-id-get-create
        "ri" 'org-roam-node-insert
        "rl" 'org-roam-buffer-toggle
        "rta" 'org-roam-tag-add
        "rtd" 'org-roam-tag-delete
        "ra" 'org-roam-alias-add))
    (setq org-roam-mode-sections
          (list #'org-roam-backlinks-insert-section
                #'org-roam-reflinks-insert-section
                ))
    (setq org-roam-file-extensions '("org"))
    (org-roam-setup)

    ;; templates
    (setq org-roam-capture-templates
          '(
            ("d" "default" plain
             "%?"
             :if-new (file+head "${slug}.org"
                                "#+title: ${title}\n")
             :immediate-finish t
             :unnarrowed t)
            ("r" "ref" plain
             "%?"
             :if-new (file+head "./ref_notes/${slug}.org"
                                "#+title: ${title}\n")
             :unnarrowed t)))
    (setq org-roam-dailies-directory "daily/")
    (setq org-roam-dailies-capture-templates
          '(("d" "default" entry
             "* %?"
             :if-new (file+head "%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>\n"))))
    ))

(defun Boyang-research/init-org-roam-bibtex ()
  (use-package org-roam-bibtex
    :after org-roam
    :hook (org-roam-mode . org-roam-bibtex-mode)
    :bind (:map org-mode-map
                (("C-c n a" . orb-note-actions)))))
(defun Boyang-research/init-bibtex ()
  (use-package bibtex

    :config
    (setq org-ref-default-bibliography '("~/reference.bib")
          org-ref-pdf-directory "~/papers/"
          org-ref-bibliography-notes "~/papers/notes.org"))
  
  )

(defun Boyang-research/post-init-deft ()
  (progn
    (setq deft-use-filter-string-for-filename t)
    (setq deft-recursive t)
    (setq deft-extension '("org" "md"))
    (setq deft-directory deft-dir)))

