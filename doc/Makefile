# =============================================================================
# Gallery image generator for dimmer.el
# Invoked by: make -C doc gallery  (from project root Makefile)
# =============================================================================

EASK   ?= eask
UV     ?= uv
DOC_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ROOT_DIR := $(abspath $(DOC_DIR)/..)
VENV_DIR := .venv
VENV_STAMP := $(VENV_DIR)/.deps-stamp
VENV_PYTHON := $(VENV_DIR)/bin/python

.PHONY: gallery gallery-one gifs clean realclean

# ---------------------------------------------------------------------------
# Animated GIFs
# ---------------------------------------------------------------------------

VIDEOS = dimmer-demo.webm
GIFS   = $(VIDEOS:.webm=.gif)

gifs: $(GIFS)

%.gif : %.webm
	ffmpeg -i $< -filter_complex \
	  "[0:v] fps=15,scale=w=640:h=-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" $@

# ---------------------------------------------------------------------------
# Screenshot gallery -- see gallery.el and comp.py
# ---------------------------------------------------------------------------

GALLERY_THEMES  = catppuccin-latte \
                  doom-one \
                  doom-molokai \
                  doom-gruvbox-light \
                  zenburn
GALLERY_MODES   = foreground desaturate hueshift background both
GALLERY_FRACS   = 0.00 0.20 0.40 0.50 0.75 0.90
GALLERY_THEME  ?= zenburn
GALLERY_MODE   ?= foreground
GALLERY_FRAC   ?= 0.30

# Base names for composite images (no fraction suffix)
GALLERY_CASES = $(foreach theme,$(GALLERY_THEMES), \
                  $(foreach mode,$(GALLERY_MODES), \
                    $(subst MODE,$(mode), \
                      $(subst THEME,$(theme),example-THEME-MODE))))
GALLERY_IMAGES = $(foreach theme,$(GALLERY_THEMES), \
                   $(foreach mode,$(GALLERY_MODES), \
                     $(foreach frac,$(GALLERY_FRACS), \
                       example-$(theme)-$(mode)-$(frac).png)))
GALLERY_COMPOSITES = $(addsuffix -comp.png,$(GALLERY_CASES))
GALLERY_IMAGE_DEPS = $(ROOT_DIR)/dimmer.el gallery.el Makefile $(VENV_STAMP)
GALLERY_COMP_DEPS = comp.py Makefile $(VENV_STAMP)

define GALLERY_IMAGE_RULE
example-$(1)-$(2)-$(3).png: $$(GALLERY_IMAGE_DEPS)
	cd $$(ROOT_DIR) && $$(EASK) emacs -q -l $$(DOC_DIR)/gallery.el -- $(1) $(2) $(3)
endef

define GALLERY_COMPOSITE_RULE
example-$(1)-$(2)-comp.png: $$(foreach frac,$$(GALLERY_FRACS),example-$(1)-$(2)-$$(frac).png) $$(GALLERY_COMP_DEPS)
	$$(VENV_PYTHON) comp.py example-$(1)-$(2) $$(GALLERY_FRACS)
endef

$(foreach theme,$(GALLERY_THEMES), \
  $(foreach mode,$(GALLERY_MODES), \
    $(foreach frac,$(GALLERY_FRACS), \
      $(eval $(call GALLERY_IMAGE_RULE,$(theme),$(mode),$(frac))))))

$(foreach theme,$(GALLERY_THEMES), \
  $(foreach mode,$(GALLERY_MODES), \
    $(eval $(call GALLERY_COMPOSITE_RULE,$(theme),$(mode)))))

gallery: $(GALLERY_COMPOSITES)

gallery-one:
	cd $(ROOT_DIR) && $(EASK) emacs -q -l $(DOC_DIR)/gallery.el -- $(GALLERY_THEME) $(GALLERY_MODE) $(GALLERY_FRAC)

$(VENV_STAMP):
	$(UV) venv $(VENV_DIR)
	$(UV) pip install --python $(VENV_PYTHON) pillow
	touch $@

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

clean:
	$(EASK) clean elc
	rm -f *.log *~

realclean:
	rm -f $(GIFS) example-*.png
	rm -rf $(VENV_DIR)
