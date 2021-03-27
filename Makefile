# Build skaware locally {{{1

SHELL=/bin/bash
LOCAL_MACHINE=$(shell uname -m)
TARGET=${LOCAL_MACHINE}
$(info - TARGET ${TARGET})

all: # the default goal {{{1
