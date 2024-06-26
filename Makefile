SHELL:=/usr/bin/env bash
MAKEFLAGS += --no-builtin-rules --no-builtin-variables

#### Nix

BUILDER_EXEC:=
NIXOS_CONFIG:=qcow
TF_WORKSPACE:=dev
TF_ALL_WORKSPACES:=dev prod

ifeq ($(shell uname -s),Darwin)
   BUILDER_EXEC:=NIX_CONF_DIR=$(PWD)/bootstrap nix develop .\#builder --command
endif

bootstrap:
	@$(BUILDER_EXEC) echo "Started build environment"

build:
	@nix build .#nixosConfigurations.$(NIXOS_CONFIG) --system aarch64-linux $(ARGS)

#### Terraform

TF_ROOT_DIRS := $(wildcard tf-root-*) .
TF_ROOT_DIRS_DESTROY:=$(addsuffix -destroy,$(TF_ROOT_DIRS))
TF_ROOT_DIRS_CONSOLE:=$(addsuffix -console,$(TF_ROOT_DIRS))
TF_ROOT_DIRS_INIT:=$(addsuffix -init,$(TF_ROOT_DIRS))
TF_ROOT_DIRS_FMT:=$(addsuffix -fmt,$(TF_ROOT_DIRS))
TF_ROOT_DIRS_VALIDATE:=$(addsuffix -validate,$(TF_ROOT_DIRS))

init: $(TF_ROOT_DIRS_INIT) $(TF_ALL_WORKSPACES)
	@terraform workspace select $(TF_WORKSPACE)

$(TF_ALL_WORKSPACES):
	@terraform workspace new $@ || true

$(TF_ROOT_DIRS_INIT):
	@$(eval DIR:=$(subst -init,,$@))
	terraform -chdir=$(DIR) init -upgrade $(ARGS)

$(TF_ROOT_DIRS):
	@terraform -chdir=$@ apply -compact-warnings -auto-approve $(ARGS)

$(TF_ROOT_DIRS_DESTROY):
	@$(eval DIR:=$(subst -destroy,,$@))
	@terraform -chdir=$(DIR) destroy -auto-approve $(ARGS)

$(TF_ROOT_DIRS_CONSOLE):
	@$(eval DIR:=$(subst -console,,$@))
	@terraform -chdir=$(DIR) console $(ARGS)

fmt: $(TF_ROOT_DIRS_FMT)

$(TF_ROOT_DIRS_FMT):
	@$(eval DIR:=$(subst -fmt,,$@))
	terraform -chdir=$(DIR) fmt $(ARGS)

validate: $(TF_ROOT_DIRS_VALIDATE)

$(TF_ROOT_DIRS_VALIDATE):
	@$(eval DIR:=$(subst -validate,,$@))
	terraform -chdir=$(DIR) validate -no-color $(ARGS)

.PHONY: fmt validate build build-x86 bootstrap init \
  $(TF_ROOT_DIRS) $(TF_ROOT_DIRS_DESTROY) $(TF_ROOT_DIRS_INIT) \
  $(TF_ROOT_DIRS_CONSOLE) $(TF_ROOT_DIRS_FMT) $(TF_ROOT_DIRS_VALIDATE)
