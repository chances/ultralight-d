# TODO: Use proper extension for each platform
ULTRALIGHT_D_LIB_NAME := libultralight.a
ULTRALIGHT_D_BINARY := bin/$(ULTRALIGHT_D_LIB_NAME)

.DEFAULT_GOAL := all
all: ultralight

# Subprojects
subprojects/ultralight/SDK: subprojects/ultralight/download.mjs
	@node subprojects/ultralight/download.mjs

bin/ultralight: subprojects/ultralight/SDK
	@mkdir -p bin/ultralight
	@echo "Copying ultralight distributables"
	cp -r subprojects/ultralight/SDK/bin/* bin/ultralight/.
ultralight: bin/ultralight
.PHONY: ultralight

subprojects: ultralight
.PHONY: subprojects
