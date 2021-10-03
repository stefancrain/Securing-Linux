# Securing Linux

This repo creates a usable Linux platform with adequately security for daily, non-production usage.

TODO: add blurb about reasoning

TODO: add blurb about workflow

Make no mistake this set of playbooks are opinionated and come **without any express or implied warranty**.

## Steps in security

1. [Protect data with partitioning and encryption](./terraform/libvirt/ubuntu/cloud_init.yml)
2. [Set useful base tools](./ansible/tasks/base.yml)
3. [Restrict physical access](./ansible/tasks/physical_access.yml)
4. [Restrict network access](./ansible/tasks/network_access.yml)
5. [Track audit-worthy change events](./ansible/tasks/audit_tools.yml)

## Reviewing hardening efforts

### Audit programs

- [jtesta/ssh-audit](https://github.com/jtesta/ssh-audit)
- [CISOfy/lynis](https://github.com/CISOfy/lynis)
- [future-architect/vuls](https://github.com/future-architect/vuls)

### [Chef InSpec](https://docs.chef.io/inspec)

- [dev-sec/linux-baseline](https://github.com/dev-sec/linux-baseline)
- [dev-sec/linux-patch-baseline](https://github.com/dev-sec/linux-patch-baseline)
- [dev-sec/ssh-baseline](https://github.com/dev-sec/ssh-baseline)
- [dev-sec/cis-dil-benchmark](https://github.com/dev-sec/cis-dil-benchmark)
- [dev-sec/cis-docker-benchmark](https://github.com/dev-sec/cis-docker-benchmark)
- [dev-sec/cis-kubernetes-benchmark](https://github.com/dev-sec/cis-kubernetes-benchmark)
- [vibrato/inspec-meltdownspectre](https://github.com/vibrato/inspec-meltdownspectre)

Security hardening guides, best practices, checklists, benchmarks, tools and
other resources. Help from :

- [US DoD DISA Security Technical Implementation Guides (STIGs) and Security Requirements Guides (SRGs)](https://public.cyber.mil/stigs/)
- [decalage2/awesome-security-hardening](https://github.com/decalage2/awesome-security-hardening)

## Setting up for development

This project uses :
- [Terraform](https://www.terraform.io/)
  - [dmacvicar/terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt) for local dev
  - [aws](https://registry.terraform.io/providers/hashicorp/aws/latest) for remote dev
- [Ansible](https://www.ansible.com/) for development and evaluation.
- [Taskfile](./Taskfile.yml) contains most of the magic to get this project working.

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
make ping
```

- Vagrant creates test VMs
- Vagrant takes snapshot of the state at _baseline_ to make iterative testing much faster

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

## Supported Operating Systems

| OS        | Release                                                              |
| :-------- | :------------------------------------------------------------------- |
| Ubuntu    | [20.04 - Focal](https://app.vagrantup.com/bento/boxes/ubuntu-20.04)  |
|           | [19.10 - Eoan](https://app.vagrantup.com/bento/boxes/ubuntu-19.10)   |
|           | [18.04 - Bionic](https://app.vagrantup.com/bento/boxes/ubuntu-18.04) |
|           | [16.04 - Xenial](https://app.vagrantup.com/bento/boxes/ubuntu-16.04) |
| Debian    | [10 - Buster](https://app.vagrantup.com/bento/boxes/debian-10)       |
|           | [9 - Stretch](https://app.vagrantup.com/bento/boxes/debian-9)        |
|           | [8 - Jessie](https://app.vagrantup.com/bento/boxes/debian-8)         |
| ArchLinux | [ArchLinux](https://app.vagrantup.com/archlinux/boxes/archlinux)     |
| CentOS    | [8](https://app.vagrantup.com/bento/boxes/centos-8)                  |
|           | [7](https://app.vagrantup.com/bento/boxes/centos-7)                  |

## Work in progress : Supported Operating Systems

| OS     | Release                                                              |
| :----- | :------------------------------------------------------------------- |
| Ubuntu | [20.10 - Groovy](https://app.vagrantup.com/ubuntu/boxes/groovy64)    |
|        | [14.04 - Trusty](https://app.vagrantup.com/bento/boxes/ubuntu-14.04) |
| CentOS | [6](https://app.vagrantup.com/bento/boxes/centos-6)                  |
| RHEL   | [8](https://app.vagrantup.com/roboxes/boxes/rhel8)                   |
|        | [7](https://app.vagrantup.com/roboxes/boxes/rhel7)                   |
|        | [6](https://app.vagrantup.com/roboxes/boxes/rhel6)                   |


# https://github.com/mitogen-hq/mitogen/archive/v0.3.0-rc.0.tar.gz
