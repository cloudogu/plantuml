MAKEFILES_VERSION=7.5.0

.DEFAULT_GOAL:=help

WORKSPACE=/workspace

include build/make/variables.mk
include build/make/self-update.mk
include build/make/release.mk
