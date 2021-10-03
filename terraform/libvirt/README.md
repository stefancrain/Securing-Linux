# Linux Setup

```bash
wget https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/v0.6.3/terraform-provider-libvirt-0.6.3+git.1604843676.67f4f2aa.Ubuntu_20.04.amd64.tar.gz
tar xf terraform-provider-libvirt-0.6.3+git.1604843676.67f4f2aa.Ubuntu_20.04.amd64.tar.gz
install -d ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.3/linux_amd64
install terraform-provider-libvirt ~/.local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.3/linux_amd64/
rm terraform-provider-libvirt terraform-provider-libvirt-*.amd64.tar.gz
```


```bash
mkdir -p iso/ubuntu/{16.04,18.04,20.04,21.04}
wget -O iso/ubuntu/16.04/ubuntu-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img
wget -O iso/ubuntu/18.04/ubuntu-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img
wget -O iso/ubuntu/20.04/ubuntu-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img
wget -O iso/ubuntu/21.04/ubuntu-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/releases/hirsute/release/ubuntu-21.04-server-cloudimg-amd64.img

wget -O iso/ubuntu/16.04/ubuntu-server-cloudimg-arm64.img https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-arm64-disk1.img
wget -O iso/ubuntu/18.04/ubuntu-server-cloudimg-arm64.img https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-arm64.img
wget -O iso/ubuntu/20.04/ubuntu-server-cloudimg-arm64.img https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-arm64.img
wget -O iso/ubuntu/21.04/ubuntu-server-cloudimg-arm64.img https://cloud-images.ubuntu.com/releases/hirsute/release/ubuntu-21.04-server-cloudimg-arm64.img
```
