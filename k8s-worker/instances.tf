provider "libvirt" {
  uri = "qemu:///system"
}

#for remote libvirtd
#provider "libvirt" {
#  alias = "server2"
#  uri   = "qemu+ssh://root@192.168.100.10/system"
#}

resource "libvirt_volume" "xenial64-2" {
  name   = "xenial64-2"
  pool   = "Downloads"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  #source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  source = "../iso/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  format = "qcow2"
  #size   = "20000000000"
}

 resource "libvirt_cloudinit_disk" "commoninit-client-2" {
   name      = "commoninit-client-2.iso"
   pool      = "Downloads"
   meta_data = "${data.template_file.meta-data.rendered}"
   user_data = "${data.template_file.init-script.rendered}"
 }

data "template_file" "meta-data" {
  template = "${file("${path.module}/meta-data")}"
}

data "template_file" "init-script" {
  template = "${file("${path.module}/cloud_init.sh")}"
}

# Define KVM domain to create
resource "libvirt_domain" "k8s-worker" {
  name   = "k8s-worker"
  memory = "4096"
  vcpu   = 2

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.xenial64-2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit-client-2.id}"

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
