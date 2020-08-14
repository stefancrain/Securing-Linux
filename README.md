# Secure Linux

This repo creates a usable Linux platform with adequately security for daily, non-production usage. Make no mistake this set of playbooks is opinionated and comes with *no warranty stated or implied*.

We like to build and use devices connected to the internet. That shouldn't keep us up at night.

## Roles as steps in security

1. Set useful base of common tools - [base](./roles/base)
2. Restrict physical access - [physical_access](./roles/physical_access)
3. Restrict network access - [network_access](./roles/network_access)
4. Enforce role based access controls - [rbac](./roles/rbac)
5. Protect data with partitioning and encryption - [data](./roles/data)
6. Track audit-worthy change events - [audit_tools](./roles/audit_tools)

## Requirements

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

## Setting up for development

### Help

The makefile is annotated with comments, and they are also viewable via the help command.

```bash
make help
```

### Initialization

To get started, we will Initialize the project.

```bash
make init
```

- Ansible-galaxy installing all [requirements.yml](requirements.yml)
- Vagrant pulling down the most recent versions of the 5 boxes currently configured.
- Creating an [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) allows us to keep sensitive data such as passwords or keys in an encrypted vault. An example decrypted file can be reviewed [vault-example.yml](inventory/group_vars/vault-example.yml), which will become [vault.yml](inventory/group_vars/vault.yml).

### Encrypting and Decryptingthe vault

```bash
make enc
make dec
```

### Creating the test VMs

```bash
make build
```

- Vagrant creates 4 test VMs
- Vagrant takes snapshot of the state at *first-boot* to make iterative testing much faster

### Managing the state of the VMs

```bash
make start
make stop
make reset #  restore first-boot snapshot
make destroy # remove all traces
```

## Reviewing security official vagrant boxes

```bash
make audit
```


## Running a hardening playbook

```bash
make play
make audit
```
