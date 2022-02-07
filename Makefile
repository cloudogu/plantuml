MAKEFILES_VERSION=4.7.1

.DEFAULT_GOAL:=dogu-release

WORKSPACE=/workspace

include build/make/variables.mk
include build/make/self-update.mk
include build/make/release.mk