.PHONY: help init enc dec pull build start stop destroy reset lint pretty role audit

BOXES = ubuntu/groovy64 \
				ubuntu/focal64 \
				ubuntu/bionic64 \
				debian/buster64

VMS   = groovy \
				focal \
				bionic \
				buster

help: ## show this help.
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'
	
init: ## install requirements
	ansible-galaxy install -r requirements.yml
	for box in $(BOXES); do \
		vagrant box add --provider=virtualbox --clean "$$box" || true ; \
	done
	test ! -f .vault.pass
	cp inventory/group_vars/vault-example.yml inventory/group_vars/vault.yml
	openssl rand -base64 16384 > .vault.pass

enc: ## encrypt the vault
	ansible-vault encrypt inventory/group_vars/vault.yml --vault-password-file=.vault.pass

dec: ## decrypt the vault
	ansible-vault decrypt inventory/group_vars/vault.yml --vault-password-file=.vault.pass

############################################################

pull: ## update vagrant boxes
	vagrant box update
	vagrant box prune --keep-active-boxes

build: ## create vagrant boxes + "first-boot" snapshot
	vagrant up --destroy-on-error --parallel
	for vm in $(VMS); do \
		vagrant snapshot save "$$vm" "first-boot" ; \
	done
	
start: ## start vagrant boxes
	for vm in $(VMS); do \
		vagrant resume "$$vm" ; \
	done

stop: ## suspend vagrant boxes
	for vm in $(VMS); do \
		vagrant suspend "$$vm" ; \
	done

destroy: ## destroy vagrant boxes, clean disks
	vagrant destroy --force --parallel || true
	rm -rf *.vdi || true

reset: ## reset vagrant boxes to "first-boot" snapshot
	for vm in $(VMS); do \
		vagrant snapshot restore "$$vm" "first-boot" ; \
	done

############################################################

lint: ## test files for syntax errors
	markdownlint . || true
	yamllint . || true
	vagrant validate || true
	ansible-lint playbooks/audit.yml || true
	ansible-lint playbooks/setup.yml || true

pretty: ## correct formatting errors
	prettier --parser=markdown --write '*.md' '**/*.md' || true
	prettier --parser=json --write '**/*.json.j2' || true
	prettier --parser=yaml --write '*.y*ml' '**/*.y*ml' || true
	# prettier --parser=yaml --write '*.y*ml.j2' '**/*.y*ml.j2' || true

role: ## create a new role
	./tools/mkrole.sh

############################################################

audit: ## run playbook to test compliance with audit tools
	ansible-playbook --vault-password-file=.vault.pass -l TEST playbooks/audit.yml

play: ##run playbook to setup hosts
	ansible-playbook --vault-password-file=.vault.pass -l TEST playbooks/setup.yml
