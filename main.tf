// link project directory to GCP project
provider "google" {
  credentials = "${file("bootcamp-terraform-18f7b5fc87e4.json")}"
  project     = "bootcamp-terraform-666"
  region      = "europe-north1"
}


resource "random_id" "instance_id" {
  byte_length = 8
}


resource "google_compute_instance" "default" {
  name         = "bootcamp-terraform-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone         = "europe-north1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata_startup_script = "sudo-apt-get update; sudo apt-get install -yq nginx"

  network_interface {
    network = "${google_compute_network.default.name}" 
    access_config {
    }
  }
  
  metadata { 
    sshKeys = "joh:${file("~/.ssh/id_rsa.pub")}"
  }
}


output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}


resource "google_compute_firewall" "default" {
  name    = "terraform-bootcamp-firewall"
  network = "${google_compute_network.default.name}"
  
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
}


resource "google_compute_network" "default" {
  name                    = "bootcamp-terraform-network"
  auto_create_subnetworks = "true"
}

#resource "google_compute_forwarding_rule" "default" {
# name       = "http-to-https-rule"
#  target 
#}
