# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.
variable "ansible_playbook_dir" {
  type    = string
  default = "vagrant/centos8-devbox/ansible"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "source_path" {
  type    = string
  default = "output-virtualbox-almalinux8-ansible/almalinux8-ansible.ovf"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "vm_name" {
  type    = string
  default = "almalinux8-devbox"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "virtualbox-ovf" "autogenerated_1" {
  guest_additions_mode = "disable"
  headless             = false
  output_directory     = "output-virtualbox-${var.vm_name}"
  shutdown_command     = "echo ${var.ssh_password} | sudo -S shutdown -P now"
  source_path          = "${var.source_path}"
  ssh_password         = "${var.ssh_password}"
  ssh_username         = "${var.ssh_username}"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "${var.memory}"], ["modifyvm", "{{ .Name }}", "--cpus", "${var.cpus}"]]
  vm_name              = "${var.vm_name}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.virtualbox-ovf.autogenerated_1"]

  provisioner "ansible-local" {
    playbook_dir  = "${var.ansible_playbook_dir}"
    playbook_file = "${var.ansible_playbook_dir}/devbox.yml"
  }

  provisioner "shell" {
    execute_command = "echo ${var.ssh_password} | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["scripts/basebox/cleanup.sh", "scripts/basebox/zerodisk.sh"]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "builds/{{ .Provider }}-${var.vm_name}.box"
  }
}
