packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/openstack"
    }
  }
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

source "openstack" "ubuntu-noble-hardened" {
  identity_endpoint = "https://openstack-keystone.haproxy.us-homelab1.hl.rmb938.me/v3"
  cacert = "/home/rbelgrave/.step/certs/root_ca.crt"
  region            = "us-homelab1"

  source_image_filter {
    filters {
      visibility = "public"
      properties = {
        "os_type"    = "linux"
        "os_distro"  = "ubuntu"
        "os_version" = "24.04"
      }
      tags = ["ubuntu-noble-lts-amd64", "latest"]
    }
  }
  ssh_username = "ubuntu"

  flavor       = "c1-standard-1"
  image_name   = "ubuntu-noble-lts-amd64-hardened"
  skip_create_image = true
  
  tenant_name         = "application-platform"
  floating_ip_network = "provider"

  security_groups = [
    # TODO:
  ]
  networks        = [
    # TODO:
  ]
}

build {
  sources = ["source.openstack.ubuntu-noble-hardened"]

  // Packer setup
  provisioner "shell" {
    script = "../scripts/provisioner-shell-image-packer.sh"
  }

  provisioner "ansible" {
    galaxy_file = "ansible/requirements.yml"

    playbook_file   = "ansible/site.yaml"
    user            = "ubuntu"
    extra_arguments = [
      "-v",
      "--diff"
    ]

    ansible_env_vars = ["ANSIBLE_FORCE_COLOR=1"]
  }

  // Trivy
  provisioner "shell" {
    script = "../scripts/provisioner-shell-image-trivy.sh"
  }

  // Cleanup
  provisioner "shell" {
    script = "../scripts/provisioner-shell-image-cleanup.sh"
  }

  post-processor "manifest" {}

}