# Build skaware locally {{{1
#
# See also:
# http://skarnet.org/
# https://www.gnu.org/software/make/manual/
# https://www.gnu.org/software/bash/manual/

SHELL=/bin/bash # {{{1

LOCAL_MACHINE=$(shell uname -m)
TARGET=${LOCAL_MACHINE}
MAKE_J=$(shell expr `nproc` - 1)
$(info - TARGET ${TARGET}, MAKE_J ${MAKE_J})

$(info - CURDIR ${CURDIR})

SOURCES = sources

SRC_DIRS=$(basename $(basename $(basename \
				 $(shell cd hashes; for h in *; do echo $$h; done))))
SKALIBS := $(filter skalibs-%, $(SRC_DIRS))
SRC_DIRS := $(SKALIBS) $(filter-out skalibs-%, $(SRC_DIRS))
$(info - SRC_DIRS ${SRC_DIRS})

DL_CMD = curl -C - -L -o
SHASUM = sha1sum
SKAWARE = http://www.skarnet.org/software
SPACE := $(subst ,, )

all: # the default goal {{{1

clean:
	rm -rf *.src $(SOURCES)

$(SOURCES):
	mkdir -p $@

$(SOURCES)/%: URL=$(SKAWARE)/$(subst $(SPACE),-,$(strip \
	$(filter-out %.gz,$(subst -, ,$(notdir $@)))))

$(SOURCES)/%: hashes/%.sha1 | $(SOURCES)
	rm -rf $@.tmp; mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) $(URL)/$(notdir $@) && touch $(notdir $@)
	cd $@.tmp && $(SHASUM) -c ${CURDIR}/hashes/$(notdir $@).sha1
	mv $@.tmp/$(notdir $@) $@ && rm -rf $@.tmp

%.src: $(SOURCES)/%.tar.gz
	rm -rf $@.tmp; mkdir -p $@.tmp
	( cd $@.tmp && tar zxvf - ) < $<
	rm -rf $@
	touch $@.tmp/$(patsubst %.src,%,$@)
	mv $@.tmp/$(patsubst %.src,%,$@) $@
	rm -rf $@.tmp

%: SKAWARE_PKG=$(subst $(SPACE),-,$(strip \
	$(filter-out %.0 %.1 %.2 %.4,$(subst -, ,$@))))

%: %.src
	@echo '- make $(SKAWARE_PKG): $<'
	$(MAKE) -j $(MAKE_J) -f $(SKAWARE_PKG).mak SRCDIR=$< OBJDIR=$@

all: | $(SRC_DIRS)
	@echo '- $@ built order-only prerequisites: $|'

# Note: .SECONDARY with no prerequisites causes all targets to be treated {{{1
# as secondary. No target is removed because it is considered intermediate, like
# $(SOURCES)/%.tar.gz, for example.
.SECONDARY:
