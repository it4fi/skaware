# Build skaware locally {{{1
#
# See also:
# http://skarnet.org/
# https://www.gnu.org/software/make/manual/
# https://www.gnu.org/software/bash/manual/

SHELL=/bin/bash # {{{1

LOCAL_MACHINE=$(shell uname -m)
TARGET=${LOCAL_MACHINE}
$(info - TARGET ${TARGET})

$(info - CURDIR ${CURDIR})

SOURCES = sources

SRC_DIRS=$(basename $(basename $(basename \
				 $(shell cd hashes; for h in *; do echo $$h; done))))
$(info - SRC_DIRS ${SRC_DIRS})

DL_CMD = curl -C - -L -o
SHASUM = sha1sum
SKAWARE = http://www.skarnet.org/software
SPACE := $(subst ,, )

all: # the default goal {{{1

$(SOURCES):
	mkdir -p $@

$(SOURCES)/%: URL=$(SKAWARE)/$(subst $(SPACE),-,$(strip $(filter-out %.gz,$(subst -, ,$(notdir $@)))))

$(SOURCES)/%: hashes/%.sha1 | $(SOURCES)
	rm -rf $@.tmp; mkdir -p $@.tmp
	cd $@.tmp && $(DL_CMD) $(notdir $@) $(URL)/$(notdir $@)
	touch $(notdir $@)
	cd $@.tmp && $(SHASUM) -c ${CURDIR}/hashes/$(notdir $@).sha1
	mv $@.tmp/$(notdir $@) $@ && rm -rf $@.tmp

%.orig: $(SOURCES)/%.tar.gz
	rm -rf $@.tmp; mkdir -p $@.tmp
	( cd $@.tmp && tar zxvf - ) < $<
	rm -rf $@
	touch $@.tmp/$(patsubst %.orig,%,$@)
	mv $@.tmp/$(patsubst %.orig,%,$@) $@
	rm -rf $@.tmp

%: %.orig
	@echo '- $@ built prerequisites: $^'

all: | $(SRC_DIRS)
	@echo '- $@ built order-only prerequisites: $|'

# Note: .SECONDARY with no prerequisites causes all targets to be treated {{{1
# as secondary. No target is removed because it is considered intermediate, like
# $(SOURCES)/%.tar.gz, for example.
.SECONDARY:
