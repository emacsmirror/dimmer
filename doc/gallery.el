;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; run with:
;;    eask emacs -q -l gallery.el -- zenburn desaturate 0.4

(defconst gallery-directory
  (file-name-directory (or load-file-name (buffer-file-name))))

(defconst gallery-root-directory
  (expand-file-name ".." gallery-directory))

(defun go-add-eask-package-paths ()
  (let* ((package-root
          (expand-file-name (format ".eask/%s.%s/elpa"
                                    emacs-major-version
                                    emacs-minor-version)
                            gallery-root-directory)))
    (when (file-directory-p package-root)
      (dolist (directory (directory-files package-root t "^[^.].*"))
        (when (file-directory-p directory)
          (add-to-list 'load-path directory)
          (add-to-list 'custom-theme-load-path directory))))))

(go-add-eask-package-paths)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package dependencies managed by Eask (see ../Eask development)

;; Load local dimmer.el to pick up new modes
(load-file (expand-file-name "dimmer.el" gallery-root-directory))

(add-to-list 'default-frame-alist '(fullscreen . fullboth))
(add-to-list 'default-frame-alist '(font . "Inconsolata-12"))
(setq inhibit-splash-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(defvar go-capture-window nil)
(defvar go-frac-string nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun go-gallery (file &optional line)
  (let ((dimmer-buffer (find-file-noselect file))
        (scratch-buffer (get-buffer-create "*scratch*")))
    (delete-other-windows)
    (set-window-buffer (selected-window) dimmer-buffer)
    (setq go-capture-window (selected-window))
    (with-current-buffer dimmer-buffer
      (when line
        (goto-char (point-min))
        (forward-line (1- line))))
    (let ((scratch-window (split-window-right)))
      (set-window-buffer scratch-window scratch-buffer)
      (select-window scratch-window))))

(defun go-dimmer (mode frac)
  (setq dimmer-adjustment-mode mode)
  (setq dimmer-fraction frac)
  (when (eq mode :hueshift)
    (setq dimmer-hue-target :background))
  (dimmer-mode 1))

(defun go-log (format-string &rest args)
  (let ((message (apply #'format (concat format-string "\n") args)))
    (princ message)
    (write-region message nil
                  (expand-file-name "gallery.log" gallery-directory)
                  'append 'silent)))

;; https://emacsthemes.com/popular/index.html
(defun go-theme (theme)
  (condition-case err
      (progn
        (when (eq theme 'catppuccin-latte)
          (setq catppuccin-flavor 'latte)
          (setq theme 'catppuccin))
        (load-theme theme t))
    (error
     (go-log "theme failed: %s" theme)
     (go-log "custom-theme-load-path: %S" custom-theme-load-path)
     (signal (car err) (cdr err)))))

(defun go-capture (output-file window)
  (unless (window-live-p window)
    (error "capture window is not live"))
  (let* ((geometry (frame-geometry (window-frame window)))
         (frame-position (or (alist-get 'outer-position geometry)
                             (alist-get 'position geometry)))
         (edges (window-pixel-edges window))
         (minibuffer-window (minibuffer-window (window-frame window)))
         (minibuffer-edges (window-pixel-edges minibuffer-window))
         (left (nth 0 edges))
         (top (nth 1 edges))
         (right (nth 2 edges))
         (bottom (nth 3 minibuffer-edges))
         (x (+ (car frame-position) left))
         (y (+ (cdr frame-position) top))
         (w (- right left))
         (h (- bottom top))
         (command (format "screencapture -x -R%d,%d,%d,%d %s"
                          x y w h
                          (shell-quote-argument output-file))))
    (go-log "frame: %S" geometry)
    (go-log "window: %S"
            (list :inside-edges edges
                  :minibuffer-edges minibuffer-edges
                  :rect (list x y w h)))
    (go-log "grab: %s" command)
    (unless (and (zerop (shell-command command))
                 (file-exists-p output-file))
      (error "grab failed to create %s" output-file))
    (go-log "saved: %s" output-file)))

(defun go (mode frac theme)
  (set-frame-parameter nil 'fullscreen 'fullboth)
  (go-theme theme)
  (go-gallery (expand-file-name "dimmer.el" gallery-root-directory) 310)
  (go-dimmer mode frac)
  (setq grab-file (format "example-%s-%s-%s.png"
                          theme
                          (substring (symbol-name mode) 1)
                          go-frac-string))
  ;; Let the GUI event loop render and apply frame parameters before capture.
  (sit-for 1.0)
  (condition-case err
      (let ((output-file (expand-file-name grab-file gallery-directory)))
        (go-capture output-file go-capture-window)
        (kill-emacs))
    (error
     (go-log "grab failed: %s" err)
     (kill-emacs 1))))

(defun go-cli ()
  "Run `go' from plain command-line arguments.
Expected args after `--': THEME MODE FRAC."
  ;; Eask/Emacs wrappers may leave arguments in different places; consume the
  ;; trailing THEME MODE FRAC triplet from the full command line.
  (let* ((args (last command-line-args 3))
         (theme (nth 0 args))
         (mode (nth 1 args))
         (frac (nth 2 args)))
    (unless (and theme mode frac)
      (error "Usage: emacs -q -l gallery.el -- THEME MODE FRAC"))
    (raise-frame)
    (select-frame-set-input-focus (selected-frame))
    (setq go-frac-string frac)
    (go (intern (concat ":" mode))
        (string-to-number frac)
        (intern theme))))

(go-cli)
