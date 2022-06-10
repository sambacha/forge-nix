VERSION?=
CHANNEL?=

VOLUME_MOUNTS=-v "$(CURDIR)":/v
SHELLCHECK_EXCLUSIONS=$(addprefix -e, SC1091 SC1117)
SHELLCHECK=docker run --rm $(VOLUME_MOUNTS) -w /v koalaman/shellcheck $(SHELLCHECK_EXCLUSIONS)

ENVSUBST_VARS=LOAD_SCRIPT_COMMIT_SHA

.PHONY: build
build: src/forge2nix

build: install
	mkdir -p $(@D)
	LOAD_SCRIPT_COMMIT_SHA='$(shell git rev-parse HEAD)' envsubst '$(addprefix $$,$(ENVSUBST_VARS))' < $< > $@

.PHONY: shellcheck
shellcheck: src/forge2nix
	$(SHELLCHECK) $<

.PHONY: test
test: src/forge2nix
	cat src/forge2nix
		sh "$<"

.PHONY: clean
clean:
	$(RM) -r build/