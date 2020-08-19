.PHONY: help init enc dec pull build start stop destroy reset rebuild lint pretty ping list role audit 

# dynamically load list of VMS and source boxes from Vagrantfile
VMS =  $(shell vagrant status --machine-readable | grep metadata | cut -d, -f2)

help: ## show this help.
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

############################################################

init: ## install requirements
	ansible-galaxy install -r requirements.yml
	pip3 install -r requirement.txt
	vagrant plugin install vagrant-vbguest
	vagrant box update
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

build: ## create vagrant boxes and take "baseline" snapshot
	vagrant status --machine-readable | grep metadata | cut -d, -f2 | xargs --max-procs=0 -I {} vagrant up {}
	for vm in $(VMS); do \
		VBoxManage snapshot "$$vm" take "baseline" --live; \
	done
	
start: ## start vagrant boxes
	for vm in $(VMS); do \
		VBoxManage startvm "$$vm" --type headless; \
	done

stop: ## suspend vagrant boxes
	for vm in $(VMS); do \
		VBoxManage controlvm "$$vm" poweroff ; \
	done

destroy: ## destroy vagrant boxes, clean disks
	make stop
	for vm in $(VMS); do \
		VBoxManage unregistervm "$$vm" --delete ; \
	done
	rm -rf *.vdi || true

restore: ## restore vagrant boxes to "baseline" snapshot
	for vm in $(VMS); do \
		make stop ; \
		VBoxManage snapshot "$$vm" restore "baseline" ; \
		make start ; \
	done

rebuild: ## destroy + build 
	make destroy
	make build

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
ping: ## run playbook to test compliance with audit tools
	ansible all --one-line -m ping -e @inventory/group_vars/vault.yml -i inventory/virtualbox.yml

list: ## list hosts
	ansible all --list-hosts

audit: ## run playbook to test compliance with audit tools
	ansible-playbook -l Securing-Linux playbooks/audit.yml

play: ##run playbook to setup hosts
	ansible-playbook -l Securing-Linux playbooks/setup.yml

replay: ## destroy + build 
	make restore
	make play
