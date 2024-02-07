MAKEFILES_VERSION=9.0.1

.DEFAULT_GOAL:=help

WORKSPACE=/workspace

include build/make/variables.mk
include build/make/self-update.mk
include build/make/release.mk
include build/make/bats.mk
