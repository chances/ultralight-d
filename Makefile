# TODO: Use proper extension for each platform
ULTRALIGHT_D_LIB_NAME := libultralight.a
ULTRALIGHT_D_BINARY := bin/$(ULTRALIGHT_D_LIB_NAME)

.DEFAULT_GOAL := all
all: ultralight

# Subprojects
node_modules:
	@npm i
subprojects/ultralight/SDK/bin: node_modules subprojects/ultralight/download.mjs
	@node subprojects/ultralight/download.mjs

bin/ultralight: subprojects/ultralight/SDK/bin
	@mkdir -p bin/ultralight
	@echo "Copying ultralight distributables"
	cp -r subprojects/ultralight/SDK/bin/* bin/ultralight/.
ultralight: bin/ultralight
.PHONY: ultralight

subprojects: ultralight
.PHONY: subprojects

# Documentation
docs:
	dub build -b ddox
.PHONY: docs
