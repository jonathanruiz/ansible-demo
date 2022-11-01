
# Resource Groups
resource "azurerm_resource_group" "ansible-demo" {
  name     = "ansible-demo-rg"
  location = var.region
}

# NSGs
resource "azurerm_network_security_group" "server-nsg" {
  name                = "ansible-demo-nsg"
  location            = azurerm_resource_group.ansible-demo.location
  resource_group_name = azurerm_resource_group.ansible-demo.name
}

# NSG Rules
resource "azurerm_network_security_rule" "server-nsg-rule" {
  name                        = "Allow SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ansible-demo.name
  network_security_group_name = azurerm_network_security_group.server-nsg.name
}

# VNets
resource "azurerm_virtual_network" "ansible-demo-vnet" {
  name                = "ansible-demo-vnet"
  resource_group_name = azurerm_resource_group.ansible-demo.name
  location            = azurerm_resource_group.ansible-demo.location
  address_space       = ["10.0.0.0/16"]

}

# Subnets
resource "azurerm_subnet" "server-subnet" {
  name                 = "server"
  resource_group_name  = azurerm_virtual_network.ansible-demo-vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.ansible-demo-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "vm-subnet-nsg-assoc" {
  subnet_id                 = azurerm_subnet.server-subnet.id
  network_security_group_id = azurerm_network_security_group.server-nsg.id
}

# Ansible Demo NICs
resource "azurerm_network_interface" "vm-nics" {
  count               = length(var.vm-ipaddr)
  name                = "server-00${count.index + 1}-nic"
  location            = azurerm_resource_group.ansible-demo.location
  resource_group_name = azurerm_resource_group.ansible-demo.name

  ip_configuration {
    name                          = "server-00${count.index + 1}"
    subnet_id                     = azurerm_subnet.server-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = element(var.vm-ipaddr, count.index)
  }
}

# Create Ansible Demo Virtual Machines
resource "azurerm_linux_virtual_machine" "server-vms" {
  count               = length(var.vm-ipaddr)
  name                = "server-00${count.index + 1}"
  location            = azurerm_resource_group.ansible-demo.location
  resource_group_name = azurerm_resource_group.ansible-demo.name

  size                            = "Standard_B1ms"
  admin_username                  = "nuanceadmin"
  admin_password                  = "SuperSecret!1"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.vm-nics[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Jumpbox Private NIC
resource "azurerm_network_interface" "jumpbox-nic" {
  name                = "jumpbox-private-nic"
  location            = azurerm_resource_group.ansible-demo.location
  resource_group_name = azurerm_resource_group.ansible-demo.name

  ip_configuration {
    name                          = "jumpbox-private"
    subnet_id                     = azurerm_subnet.server-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox-public-ip.id
  }
}

# Jumpbox Public NIC
resource "azurerm_public_ip" "jumpbox-public-ip" {
  name                = "jumpbox-public-nic"
  location            = azurerm_resource_group.ansible-demo.location
  resource_group_name = azurerm_resource_group.ansible-demo.name
  allocation_method   = "Static"
  private_ip_address  = ["10.0.1.10"]
}

data "azurerm_public_ip" "data-jumpbox-public-ip" {
  name                = azurerm_public_ip.jumpbox-public-ip.name
  resource_group_name = azurerm_linux_virtual_machine.jumpbox-vm.resource_group_name
}


# Jumpbox Virtual Machine
resource "azurerm_linux_virtual_machine" "jumpbox-vm" {
  name                = "jumpbox"
  location            = azurerm_resource_group.ansible-demo.location
  resource_group_name = azurerm_resource_group.ansible-demo.name

  size                            = "Standard_B1ms"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.jumpbox-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}

# Copy files to jumpbox and run setup
resource "null_resource" "setup-ansible" {

  connection {
    type     = "ssh"
    port     = 22
    host     = data.azurerm_public_ip.data-jumpbox-public-ip.ip_address
    user     = var.username
    password = var.password
  }

  provisioner "file" {
    source      = "../ansible"
    destination = "/home/${var.username}/ansible"
  }

  provisioner "file" {
    source      = "install_ansible.sh"
    destination = "/home/${var.username}/install_ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.username}/install_ansible.sh",
      "/home/${var.username}/install_ansible.sh"
    ]
  }
}

# Output SSH command
output "jumpbox_ssh_command" {
  value       = "ssh ${var.username}@${data.azurerm_public_ip.data-jumpbox-public-ip.ip_address}"
  description = "The ssh command to be able to remote into the jumpbox."
}
