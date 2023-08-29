# TODO: Use proper extension for each platform
ULTRALIGHT_D_LIB_NAME := libultralight.a
ULTRALIGHT_D_BINARY := bin/$(ULTRALIGHT_D_LIB_NAME)

.DEFAULT_GOAL := all
all: ultralight

# Subprojects
package-lock.json: package.json
	@npm i
subprojects/ultralight/SDK/include/Ultralight/CAPI.h: package-lock.json subprojects/ultralight/download.mjs
	@node subprojects/ultralight/download.mjs

ultralight: subprojects/ultralight/SDK/include/Ultralight/CAPI.h
	@mkdir -p bin/ultralight
	@echo "Copying ultralight distributables"
	cp -r subprojects/ultralight/SDK/bin/* bin/ultralight/.
.PHONY: ultralight

subprojects: ultralight
.PHONY: subprojects

# Documentation
docs:
	dub build -b ddox
.PHONY: docs
