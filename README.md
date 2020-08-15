# Secure Linux

This repo creates a usable Linux platform with adequately security for daily, non-production usage.

TODO: add blurb about reasoning

TODO: add blurb about workflow

Make no mistake this set of playbooks are opinionated and comes **without any express or implied warranty**.

## Hardening Strategy

### Audit programs

- [jtesta/ssh-audit](https://github.com/jtesta/ssh-audit)
- [CISOfy/lynis](https://github.com/CISOfy/lynis)

### [Chef InSpec](https://docs.chef.io/inspec)

- [dev-sec/linux-baseline](https://github.com/dev-sec/linux-baseline)
- [dev-sec/linux-patch-baseline](https://github.com/dev-sec/linux-patch-baseline)
- [dev-sec/ssh-baseline](https://github.com/dev-sec/ssh-baseline)
- [dev-sec/cis-dil-benchmark](https://github.com/dev-sec/cis-dil-benchmark)
- [dev-sec/cis-docker-benchmark](https://github.com/dev-sec/cis-docker-benchmark)
- [dev-sec/cis-kubernetes-benchmark](https://github.com/dev-sec/cis-kubernetes-benchmark)
- [vibrato/inspec-meltdownspectre](https://github.com/vibrato/inspec-meltdownspectre)

Security hardening guides, best practices, checklists, benchmarks, tools and other resources. Help from [decalage2/awesome-security-hardening](https://github.com/decalage2/awesome-security-hardening)

## Roles as steps in security

1. Set useful base of common tools - [base](./roles/base)
2. Restrict physical access - [physical_access](./roles/physical_access)
3. Restrict network access - [network_access](./roles/network_access)
4. Enforce role based access controls - [rbac](./roles/rbac)
5. Protect data with partitioning and encryption - [data](./roles/data)
6. Track audit-worthy change events - [audit_tools](./roles/audit_tools)

## Setting up for development

This project uses Ansible, Vagrant, and VirtualBox for local development and testing. The [makefile](makefile) contains most of the magic to get this project working.

- Ansible
  - ansible-galaxy
  - ansible-lint
  - yamllint
  - markdownlint
- Vagrant
  - vagrant-lint
- VirtualBox
- make
- prettier

### Initializing the project

```bash
make init
```

- Ansible-galaxy installs required public roles within [requirements.yml](requirements.yml)
- Vagrant pulling down the most recent versions of the boxes currently configured.
- Creating an [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to protect sensitive data such as keys / passwords in an encrypted vault. An example decrypted file can be reviewed [vault-example.yml](inventory/group_vars/vault-example.yml), which will become [vault.yml](inventory/group_vars/vault.yml).

### Encrypting and decrypting the vault

```bash
make enc # encrypt vault.yml
make dec # decrypt vault.yml
```

### Creating the test VMs

```bash
make build
```

- Vagrant creates 4 test VMs
- Vagrant takes snapshot of the state at *baseline* to make iterative testing much faster

### Managing the state of the VMs

```bash
make start
make stop
make restore # restore baseline snapshot
make destroy # remove all traces
```

### Reviewing the baseline security official vagrant boxes

```bash
make audit
```

### Running a hardening playbook

```bash
make play
make audit
```

## Tested Operating Systems

- RHEL TODO: add approved images
- CentOS
  - [8](https://app.vagrantup.com/centos/boxes/8)
  - [7](https://app.vagrantup.com/centos/boxes/7)
  - [6](https://app.vagrantup.com/centos/boxes/6)
- Ubuntu
  - [20.10 - Groovy ](https://app.vagrantup.com/ubuntu/boxes/groovy64)
  - [20.04 - Focal](https://app.vagrantup.com/ubuntu/boxes/focal64)
  - [18.04 - Bionic](https://app.vagrantup.com/ubuntu/boxes/bionic64)
  - [16.04 - Xenial](https://app.vagrantup.com/ubuntu/boxes/xenial64)
- Debian
  - [10 - Buster](https://app.vagrantup.com/debian/boxes/buster64)
  - [9 - Stretch](https://app.vagrantup.com/debian/boxes/stretch64)
  - [8 - Jessie](https://app.vagrantup.com/debian/boxes/jessie64)
