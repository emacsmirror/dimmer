export EMACS ?= emacs
export EASK := $(shell command -v eask 2>/dev/null)
EASK_STAMP := .eask/.deps-stamp

.PHONY: default lint compile test deps gallery gifs clean realclean

default:
	@echo "Available targets:"
	@echo "  lint           Run lint suite"
	@echo "  compile        Byte-compile the package"
	@echo "  test           Run ERT tests (requires deps)"
	@echo "  deps           Install development dependencies"
	@echo "  gallery        Generate screenshot gallery"
	@echo "  gifs           Generate animated GIFs"
	@echo "  clean          Remove compiled files"
	@echo "  realclean      Remove compiled files + Eask cache"

lint:
	$(EASK) lint checkdoc && \
	$(EASK) lint package && \
	$(EASK) lint declare && \
	$(EASK) lint indent && \
	$(EASK) lint elisp-lint

compile:
	$(EASK) compile

test: deps compile
	$(EASK) test ert test/*-test.el

gallery: deps
	$(MAKE) -C doc gallery

gifs:
	$(MAKE) -C doc gifs

deps: $(EASK_STAMP)

$(EASK_STAMP): Eask
	$(EASK) install-deps --dev
	touch $@

clean:
	$(EASK) clean elc
	rm -f dimmer.el-autoloads.el *~
	make -C doc clean

realclean: clean
	rm -rf .eask
	make -C doc realclean
