;;; color-math-test.el --- Tests for dimmer color math  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Neil Okamoto

;; This file is NOT part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(require 'ert)
(require 'dimmer)

;;; dimmer-lerp

(ert-deftest dimmer-lerp/frac-0-returns-c0 ()
  (should (= (dimmer-lerp 0.0 0.0 1.0) 0.0))
  (should (= (dimmer-lerp 0.0 0.2 0.8) 0.2))
  (should (= (dimmer-lerp 0.0 100 200) 100)))

(ert-deftest dimmer-lerp/frac-1-returns-c1 ()
  (should (= (dimmer-lerp 1.0 0.0 1.0) 1.0))
  (should (= (dimmer-lerp 1.0 0.2 0.8) 0.8))
  (should (= (dimmer-lerp 1.0 100 200) 200)))

(ert-deftest dimmer-lerp/frac-0.5-returns-midpoint ()
  (should (= (dimmer-lerp 0.5 0.0 1.0) 0.5))
  (should (= (dimmer-lerp 0.5 0.2 0.8) 0.5))
  (should (= (dimmer-lerp 0.5 100 200) 150)))

(ert-deftest dimmer-lerp/negative-fraction ()
  (should (= (dimmer-lerp -0.5 0.0 1.0) -0.5)))

(ert-deftest dimmer-lerp/fraction-beyond-1 ()
  (should (= (dimmer-lerp 1.5 0.0 1.0) 1.5)))

;;; dimmer-lerp-in-rgb

(ert-deftest dimmer-lerp-in-rgb/black-at-frac-0 ()
  (should (equal (dimmer-lerp-in-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0)
                 "#000000000000")))

(ert-deftest dimmer-lerp-in-rgb/white-at-frac-1 ()
  (should (equal (dimmer-lerp-in-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 1.0)
                 "#ffffffffffff")))

(ert-deftest dimmer-lerp-in-rgb/midpoint ()
  (should (equal (dimmer-lerp-in-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.5)
                 "#7fff7fff7fff")))

;;; dimmer-lerp-in-hsl

(ert-deftest dimmer-lerp-in-hsl/black-at-frac-0 ()
  (should (equal (dimmer-lerp-in-hsl '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0)
                 "#000000000000")))

(ert-deftest dimmer-lerp-in-hsl/white-at-frac-1 ()
  (should (equal (dimmer-lerp-in-hsl '(0.0 0.0 0.0) '(1.0 1.0 1.0) 1.0)
                 "#ffffffffffff")))

;;; dimmer-lerp-in-cielab

;; CIELAB may not represent all RGB values perfectly, so in these tests
;; we tend to use desaturated hues and darker values.

(ert-deftest dimmer-lerp-in-cielab/black-at-frac-0 ()
  (should (equal (dimmer-lerp-in-cielab '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0)
                 "#000000000000")))

(ert-deftest dimmer-lerp-in-cielab/desaturated-frac-0 ()
  (should (equal (dimmer-lerp-in-cielab '(0.5 0.25 0.25) '(0.5 0.5 0.5) 0.0)
                 "#7fff3fff3fff")))

(ert-deftest dimmer-lerp-in-cielab/desaturated-frac-1 ()
  (should (equal (dimmer-lerp-in-cielab '(0.5 0.25 0.25) '(0.5 0.5 0.5) 1.0)
                 "#7fff7fff7fff")))

;;; dimmer-compute-rgb

(ert-deftest dimmer-compute-rgb/rgb-black-at-frac-0 ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0 :rgb)
                 "#000000000000")))

(ert-deftest dimmer-compute-rgb/rgb-white-at-frac-1 ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 1.0 :rgb)
                 "#ffffffffffff")))

(ert-deftest dimmer-compute-rgb/rgb-midpoint ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.5 :rgb)
                 "#7fff7fff7fff")))

(ert-deftest dimmer-compute-rgb/rgb-quarter ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.25 :rgb)
                 "#3fff3fff3fff")))

(ert-deftest dimmer-compute-rgb/hsl-black-at-frac-0 ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0 :hsl)
                 "#000000000000")))

(ert-deftest dimmer-compute-rgb/hsl-white-at-frac-1 ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 1.0 :hsl)
                 "#ffffffffffff")))

;; CIELAB may not represent all RGB values perfectly, so in these tests
;; we tend to use desaturated hues and darker values.

(ert-deftest dimmer-compute-rgb/cielab-black-at-frac-0 ()
  (should (equal (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0 :cielab)
                 "#000000000000")))

(ert-deftest dimmer-compute-rgb/cielab-desaturated-frac-0 ()
  (should (equal (dimmer-compute-rgb '(0.5 0.25 0.25) '(0.5 0.5 0.5) 0.0 :cielab)
                 "#7fff3fff3fff")))

(ert-deftest dimmer-compute-rgb/cielab-desaturated-frac-1 ()
  (should (equal (dimmer-compute-rgb '(0.5 0.25 0.25) '(0.5 0.5 0.5) 1.0 :cielab)
                 "#7fff7fff7fff")))

(ert-deftest dimmer-compute-rgb/unknown-fallthrough ()
  (should (stringp (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0 :unknown)))
  (should (string-prefix-p "#" (dimmer-compute-rgb '(0.0 0.0 0.0) '(1.0 1.0 1.0) 0.0 :unknown))))

;;; dimmer-cached-compute-rgb

(ert-deftest dimmer-cached-compute-rgb/returns-hex ()
  (let ((dimmer-use-colorspace :rgb))
    (should (stringp (dimmer-cached-compute-rgb "white" "black" 0.3 :rgb)))
    (should (string-prefix-p "#" (dimmer-cached-compute-rgb "white" "black" 0.3 :rgb)))))

(ert-deftest dimmer-cached-compute-rgb/caches-results ()
  (let ((dimmer-use-colorspace :rgb)
        (k "white-black-0.300000-:rgb"))
    (remhash k dimmer-dimmed-faces)
    (should (null (gethash k dimmer-dimmed-faces)))
    (dimmer-cached-compute-rgb "white" "black" 0.3 :rgb)
    (should (gethash k dimmer-dimmed-faces))))

(ert-deftest dimmer-cached-compute-rgb/returns-same-for-same-inputs ()
  (let ((dimmer-use-colorspace :rgb)
        (a (dimmer-cached-compute-rgb "white" "black" 0.3 :rgb))
        (b (dimmer-cached-compute-rgb "white" "black" 0.3 :rgb)))
    (should (equal a b))))

;;; dimmer--gray-of-same-lightness

(ert-deftest dimmer--gray-of-same-lightness/red-gives-gray ()
  (should (equal (dimmer--gray-of-same-lightness "#ff0000")
                 "#7fff7fff7fff")))

(ert-deftest dimmer--gray-of-same-lightness/black-stays-black ()
  (should (equal (dimmer--gray-of-same-lightness "#000000")
                 "#000000000000")))

(ert-deftest dimmer--gray-of-same-lightness/white-stays-white ()
  (should (equal (dimmer--gray-of-same-lightness "#ffffff")
                 "#ffffffffffff")))

;;; dimmer--color-with-target-hue

(ert-deftest dimmer--color-with-target-hue/red-to-cyan ()
  (let ((result (dimmer--color-with-target-hue "#ff0000" 0.5)))
    (should (stringp result))
    (should (string-prefix-p "#" result))
    ;; Green and blue channels should be within rounding of 1.0
    (should (> (string-to-number (substring result 5 9) 16) 65000))
    (should (> (string-to-number (substring result 9 13) 16) 65000))))

(ert-deftest dimmer--color-with-target-hue/same-hue-is-identity ()
  (should (equal (dimmer--color-with-target-hue "#ff0000" 0.0)
                 "#ffff00000000")))

(ert-deftest dimmer--color-with-target-hue/black-at-any-hue ()
  (should (equal (dimmer--color-with-target-hue "#000000" 0.3)
                 "#000000000000")))

(ert-deftest dimmer--color-with-target-hue/white-at-any-hue ()
  (should (equal (dimmer--color-with-target-hue "#ffffff" 0.7)
                 "#ffffffffffff")))

;;; dimmer--resolve-hue-target

(ert-deftest dimmer--resolve-hue-target/float-returns-itself ()
  (let ((dimmer-hue-target 0.3))
    (should (equal (dimmer--resolve-hue-target) 0.3))))

(ert-deftest dimmer--resolve-hue-target/wraps-via-mod ()
  (let ((dimmer-hue-target 1.5))
    (should (equal (dimmer--resolve-hue-target) 0.5))))

(ert-deftest dimmer--resolve-hue-target/negative-wraps ()
  (let ((dimmer-hue-target -0.5))
    (should (equal (dimmer--resolve-hue-target) 0.5))))

;;; color-math-test.el ends here