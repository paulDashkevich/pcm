terraform {
  required_providers {
    ah = {
      source = "advancedhosting/ah"
      version = "0.1.3"
    }
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
  }
}

provider "ah" {
        access_token = "secret_token"
}
resource "ah_cloud_server" "iscsi" {
   name                     = "iscsi"
   image                    = "centos-7-x64"
   datacenter               = "ams1"
   product                  = "start-xs"
   ssh_keys                 = ["xx:xx:xx:ba:f4:xx:5d:a8:da:75:be:b3:34:e8:bf:4a"]
}

resource "ah_private_network" "iscsinet" {
  ip_range = "10.1.0.0/24"
  name = "iscsi_network"
}
resource "ah_volume" "storage" {
  name    = "storage"
  product = "hdd2-ams1"
  file_system = "ext4"
  size    = "1"
}
resource "ah_private_network_connection" "iscsi-connect" {
  cloud_server_id    = ah_cloud_server.iscsi.id
  private_network_id = ah_private_network.iscsinet.id
  ip_address         = "10.1.0.1"
}

resource "ah_volume_attachment" "storage-attach" {
  cloud_server_id = ah_cloud_server.iscsi.id
  volume_id = ah_volume.storage.id
}

resource "ah_cloud_server" "worker" {
  name = "server${count.index}"
  count = 3
  datacenter = "ams1"
  image = "centos-7-x64"
  product = "start-xs"
  ssh_keys = ["xx:xx:xx:ba:f4:xx:5d:a8:da:75:be:b3:34:e8:bf:4a"]
}
resource "ah_private_network_connection" "worker-connect0" {
  cloud_server_id = ah_cloud_server.worker[0].id
  private_network_id = ah_private_network.iscsinet.id
  ip_address         = "10.1.0.2"
}
resource "ah_private_network_connection" "worker-connect1" {
  cloud_server_id = ah_cloud_server.worker[1].id
  private_network_id = ah_private_network.iscsinet.id
  ip_address         = "10.1.0.3"
}
resource "ah_private_network_connection" "worker-connect22" {
  cloud_server_id = ah_cloud_server.worker[2].id
  private_network_id = ah_private_network.iscsinet.id
  ip_address         = "10.1.0.4"
}


output "iscsi" {
  value = ah_cloud_server.iscsi.ips[*].ip_address
}
output "server0" {
  value = ah_cloud_server.worker[0].ips[*].ip_address
}
output "server1" {
  value = ah_cloud_server.worker[1].ips[*].ip_address
}
output "server2" {
  value = ah_cloud_server.worker[2].ips[*].ip_address
}
