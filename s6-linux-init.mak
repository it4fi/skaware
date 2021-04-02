include config.mak

all: # the default goal {{{1

all: | $(BUILD_DIR)
	cd $|; CC=$(CC) \
		./configure --enable-slashpackage --enable-nsss --enable-utmps
	cd $|; CC=$(CC) make -j $(MAKE_J)
	cd $|; CC=$(CC) sudo -E make install
