#!/bin/bash

disk_primary: /dev/sda
disk_secondary: /dev/sdb
disk_nvme: /dev/sdc #NVME
disk_partition_size_var_MB: 1024
disk_tmpfs_size_tmp_MB: 512
force: true
format: ext4
password_file: "/root/crypto_{{ id }}"
mapped_device: "/dev/mapper/{{ id }}"
id: foobar2019
mount: /crypto_test

---
# https://gist.github.com/ferdinandosimonetti/150aa9fec62d0007e1801862fec5e465
# https://gist.github.com/halberom/ea9af5d128a0dcfc3a425cdf98ab531c
# https://gist.github.com/bilsch/d141f1a3508e4ba7d4946aaab3113f4e
# https://gist.github.com/nikhiljha/4eec002b1f098c27fb6c65652b4f31d3
# https://gist.github.com/dgadiraju/13a6cd0257bf187d8bb22ba7ee1f3bd3
#
- debug:
    msg: "{{ item }}"
  with_items:
    - "{{ ansible_devices }}"

- name: Read device information
  parted:
    device: "{{ disk_nvme }}"
    unit: MiB
  register: disk_nvme_info

- name: Remove all partitions from disk
  parted:
    device: "{{ disk_nvme }}"
    number: "{{ item.num }}"
    state: absent
  loop: "{{ disk_nvme_info.partitions }}"

- name: Create var partitions
  parted:
    name: "{{ item }}"
    label: gpt
    state: present
    device: "{{ disk_nvme }}"
    number: "{{ my_idx + 1 | int | abs }}"
    flags: [lvm]
    part_start: "{{ (my_idx | int | abs) * (disk_partition_size_var_MB | int | abs)  }}MB"
    part_end: "{{ (my_idx | int | abs) * (disk_partition_size_var_MB | int | abs) + (disk_partition_size_var_MB | int | abs) }}MB"
    unit: "%"
  loop:
    - var
    - var_log
    - var_log_audit
  loop_control:
    index_var: my_idx

- name: Create home partition
  parted:
    name: home
    label: gpt
    state: present
    device: "{{ disk_nvme }}"
    number: 4
    flags: [lvm]
    part_start: "{{ (disk_partition_size_var_MB | int | abs) * 3 }}MB"
    part_end: "50%"
    unit: "%"

- name: Create docker partition
  parted:
    name: docker
    label: gpt
    state: present
    device: "{{ disk_nvme }}"
    number: 5
    flags: [lvm]
    part_start: "51%"
    part_end: "100%"
    unit: "%"

# https://gist.github.com/opalmer/859cf52fa934588206f2908cb6d1888b
# Quick playbook which mounts a device as an encrypted disk.

# - name: Set the options explicitly a device which must already exist
#   crypttab:
#     name: luks-home
#     state: present
#     opts: discard,cipher=aes-cbc-essiv:sha256

- name: "ensure {{ disk_nvme }}5 DOES NOT already have a UUID"
  command: "blkid -s UUID -o value {{ disk_nvme }}5"
  register: uuid
  failed_when: not force and uuid.rc == 0 # we got a uuid back from the command.

- name: "ensure {{ password_file }} DOES NOT exist"
  stat:
    path: "{{ password_file }}"
  register: stat
  failed_when: not force and stat.stat.exists

- name: "ensure {{ mapped_device }} DOES NOT exist"
  stat:
    path: "{{ mapped_device }}"
  register: stat_mapped_device
  failed_when: not force and stat_mapped_device.stat.exists

#
# Generate the password file used to mount the volume.
#
- name: "generate password to {{ password_file }}"
  command: "dd if=/dev/urandom of={{ password_file }} bs=1024 count=4"
  args:
    creates: "{{ password_file }}"

- name: "make {{ password_file }} read-only"
  file:
    path: "{{ password_file }}"
    state: file
    owner: root
    group: root
    mode: 0400

# Set up the luks device.
- name: "cryptsetup luksFormat {{ disk_nvme }}5 {{ password_file }}"
  command: "cryptsetup luksFormat {{ disk_nvme }}5 {{ password_file }}"
  when: not stat_mapped_device.stat.exists

- name: "cryptsetup open --key-file {{ password_file }} --type luks {{ disk_nvme }}5 {{ id }}"
  command: "cryptsetup open --key-file {{ password_file }} --type luks {{ disk_nvme }}5 {{ id }}"
  when: not stat_mapped_device.stat.exists

#
# Configure cryptsetup
#
- name: "get UUID of {{ disk_nvme }}5"
  command: "blkid -s UUID -o value {{ disk_nvme }}5"
  register: uuid

- name: "install cryptsetup"
  package:
    name: cryptsetup
    state: present

- name: "update /etc/crypttab"
  lineinfile:
    backup: true
    create: true
    path: /etc/crypttab
    regexp: "^{{ id }} UUID=[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} {{ password_file }}$"
    line: "{{ id }} UUID={{ uuid.stdout.strip() }} {{ password_file }}"
    state: present

#
# Format and mount device
#
- name: "format {{ format }} {{ mapped_device }}"
  filesystem:
    dev: "{{ mapped_device }}"
    fstype: "{{ format }}"

- name: "mkdir {{ mount }}"
  file:
    state: directory
    path: "{{ mount }}"
    owner: root
    group: root
    mode: 0755

- name: "mount -e {{ format }} {{ mapped_device }}"
  mount:
    state: mounted
    src: "{{ mapped_device }}"
    fstype: "{{ format }}"
    path: "{{ mount }}"

- name: Read device information
  parted:
    device: "{{ disk_nvme }}"
    unit: MiB
  register: disk_nvme_info

- name: Format all partitions disk
  filesystem:
    device: "{{ disk_nvme }}{{ item.num }}"
    fstype: xfs
  loop: "{{ disk_nvme_info.partitions }}"
  when: item.name is not match("docker")

- name: Create Separate Partition for /tmp as ramdisk [CIS 1.1.1]
  mount:
    name: /tmp_new
    src: "tmpfs"
    fstype: tmpfs
    opts: "size={{disk_tmpfs_size_tmp_MB}}m"
    state: mounted

- name: Create Separate Partition for /var [CIS 1.1.5]
  mount:
    path: "/var_new"
    src: "{{ disk_nvme }}1"
    fstype: xfs
    state: mounted
    opts: "noatime,nodiratime,nodev,inode64,largeio"

# - name: Bind Mount the /var/tmp directory to /tmp [CIS 1.1.6]
#   mount:
#     name: /var/tmp
#     src: /tmp
#     state: mounted
#     fstype: none
#     opts: "defaults,nodev,nosuid,noexec,bind"

- name: Create Separate Partition for /var/log [CIS 1.1.7]
  mount:
    path: "/var/log_new"
    src: "{{ disk_nvme }}2"
    fstype: xfs
    state: mounted
    opts: "noatime,nodiratime,nodev,inode64,largeio"

- name: Create Separate Partition for /var/log/audit [CIS 1.1.8]
  mount:
    path: "/var/log/audit_new"
    src: "{{ disk_nvme }}3"
    fstype: xfs
    state: mounted
    opts: "noatime,nodiratime,nodev,inode64,largeio"

- name: Create Separate Partition for /home [CIS 1.1.9]
  mount:
    path: "/home_new"
    src: "{{ disk_nvme }}4"
    fstype: xfs
    state: mounted
    opts: "noatime,nodiratime,nodev,inode64,largeio"
  ignore_errors: true

# copy files to temp location
- name: rsync dirs
  command: rsync -aqxPp "{{ item }}/" "{{ item }}_new"
  with_items:
    - /tmp
    - /var
    - /var/log
    # - /var/log/audit
    - /home

- name: Remove temporary mounts
  mount:
    path: "{{ item }}"
    state: absent
  with_items:
    - /tmp_new
    - /var_new
    - /var/log_new
    - /var/log/audit_new
    - /home_new

- name: Create Separate Partition for /tmp as ramdisk [CIS 1.1.1]
  mount:
    name: /tmp
    src: "tmpfs"
    fstype: tmpfs
    opts: "size={{disk_tmpfs_size_tmp_MB}}m"
    state: present

- name: Create Separate Partition for /var [CIS 1.1.5]
  mount:
    path: "/var"
    src: "{{ disk_nvme }}1"
    fstype: xfs
    state: present
    opts: "noatime,nodiratime,nodev,inode64,largeio"

# - name: Bind Mount the /var/tmp directory to /tmp [CIS 1.1.6]
#   mount:
#     name: /var/tmp
#     src: /tmp
#     state: present
#     fstype: none
#     opts: "defaults,nodev,nosuid,noexec,bind"

- name: Create Separate Partition for /var/log [CIS 1.1.7]
  mount:
    path: "/var/log"
    src: "{{ disk_nvme }}2"
    fstype: xfs
    state: present
    opts: "noatime,nodiratime,nodev,inode64,largeio"

- name: Create Separate Partition for /var/log/audit [CIS 1.1.8]
  mount:
    path: "/var/log/audit"
    src: "{{ disk_nvme }}3"
    fstype: xfs
    state: present
    opts: "noatime,nodiratime,nodev,inode64,largeio"

- name: Create Separate Partition for /home [CIS 1.1.9]
  mount:
    path: "/home"
    src: "{{ disk_nvme }}4"
    fstype: xfs
    state: present
    opts: "noatime,nodiratime,nodev,inode64,largeio"
  ignore_errors: true

- name: Unconditionally reboot the machine with all defaults
  reboot:
