# rbac

Ansible role for setting up rbac.

## Supported Platforms

## Supported Platforms

### Ubuntu

- Focal 20.04
- Eoan 19.10
- Bionic 18.04

### Debian

- Buster 10
- Stretch 9

### RHEL /CENTOS

- 7
- 6

### Alpine

- 3.11
- 3.10

## Requirements

Ansible 2.8 or higher is recommended.

## Variables

Variables and defaults for this role:

| variable     | default value in defaults/main.yml | description                                             |
| ------------ | ---------------------------------- | ------------------------------------------------------- |
| rbac_enabled | False                              | determine whether role is enabled (True) or not (False) |

## Dependencies

None.

## Example Playbook

```yaml
---
# role: rbac
# file: site.yml

- hosts: rbac_systems
  become: True
  vars:
    rbac_enabled: True
  roles:
    - role: rbac
```

## License and Author

- Author:: Stefan Crain (<stefancraian@gmail.com>)
- Copyright:: 2020, Stefan Crain

Licensed under MIT License;
See LICENSE file in repository.

## References
