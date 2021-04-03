# Build skaware locally {{{1
#
# See also:
# http://skarnet.org/
# https://www.gnu.org/software/make/manual/
# https://www.gnu.org/software/bash/manual/

include config.mak # {{{1

SOURCES = sources

PACKAGES=$(basename $(basename $(basename \
				 $(shell cd hashes; for h in *; do echo $$h; done))))
SKALIBS := $(filter skalibs-%, $(PACKAGES))
NSSS := $(filter nsss-%, $(PACKAGES))
UTMPS := $(filter utmps-%, $(PACKAGES))
PACKAGES := $(SKALIBS) $(NSSS) $(UTMPS) $(filter-out utmps-%, \
	$(filter-out nsss-%, \
	$(filter-out skalibs-%, $(PACKAGES))))

DL_CMD = curl -C - -L -o
SHASUM = sha1sum
SKAWARE = http://www.skarnet.org/software
SPACE := $(subst ,, )

all: # the default goal {{{1

clean:
	rm -rf $(PACKAGES) *.build $(SOURCES)

$(SOURCES):
	mkdir -p $@

$(SOURCES)/%: URL=$(SKAWARE)/$(subst $(SPACE),-,$(strip \
	$(filter-out %.gz,$(subst -, ,$(notdir $@)))))

$(SOURCES)/%: hashes/%.sha1 | $(SOURCES)
	rm -rf $@.tmp; mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) $(URL)/$(notdir $@) && touch $(notdir $@)
	cd $@.tmp && $(SHASUM) -c ${CURDIR}/hashes/$(notdir $@).sha1
	mv $@.tmp/$(notdir $@) $@ && rm -rf $@.tmp

%.build: $(SOURCES)/%.tar.gz
	rm -rf $@.tmp; mkdir -p $@.tmp
	( cd $@.tmp && tar zxvf - ) < $<
	rm -rf $@
	touch $@.tmp/$(patsubst %.build,%,$@)
	mv $@.tmp/$(patsubst %.build,%,$@) $@
	rm -rf $@.tmp

%: SKAWARE_PKG=$(subst $(SPACE),-,$(strip \
	$(filter-out %.0 %.1 %.2 %.4,$(subst -, ,$@))))

%: %.build
	$(MAKE) -f $(SKAWARE_PKG).mak BUILD_DIR=$<
	touch $@

all: | $(PACKAGES)
	@echo '- $@ built order-only prerequisites: $|'

# Note: .SECONDARY with no prerequisites causes all targets to be treated {{{1
# as secondary. No target is removed because it is considered intermediate, like
# $(SOURCES)/%.tar.gz, for example.
.SECONDARY:
