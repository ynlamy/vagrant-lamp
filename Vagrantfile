# -*- mode: ruby -*-
# vi: set ft=ruby :

# Description : A LAMP environment with Vagrant using VMware Workstation
# Author : Yoann LAMY <https://github.com/ynlamy/vagrant-lamp>
# Licence : GPLv3

# Vagrant version requirement
Vagrant.require_version ">= 2.0.0"

Vagrant.configure("2") do |config|
  # Box used ("rockylinux/9" is compatible with the provider "vmware_desktop")
  config.vm.box = "rockylinux/9"

  # Box must be up to date
  config.vm.box_check_update = true

  # VM Hostname
  config.vm.hostname = "lamp"

  # The plugin vagrant "vagrant-vmware-desktop" is required
  config.vagrant.plugins = "vagrant-vmware-desktop"

  # Provider configuration for "vmware_desktop"
  config.vm.provider "vmware_desktop" do |vmw|
    vmw.gui = true
    vmw.vmx["displayName"] = "LAMP"
    vmw.vmx["numvcpus"] = "2"
    vmw.vmx["memsize"] = "2048"
  end

  # Forwarded port for HTTP
  config.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "127.0.0.1"
  
  # Forwarded port for MariaDB
  config.vm.network "forwarded_port", guest: 3306, host: 3306, host_ip: "127.0.0.1"

  # Disable the default share of the current code directory
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Share an additional folder to the guest VM
  config.vm.synced_folder "www", "/var/www/html"

  # Provisioning script
  config.vm.provision "shell", path: "provisioning.sh", env: {
    "TIMEZONE" => "Europe/Paris", # Timezone to be used by the system and PHP
    "PHP_VERSION" => "8.2", # PHP version to use (currently : 7.4, 8.0, 8.1, 8.2, 8.3)
    "PHP_ERROR_REPORTING" => "E_ALL", # Sets which PHP errors are reported
    "PHP_DISPLAY_ERRORS" => "On", # This determines whether errors should be printed to the screen as part of the output
    "PHP_DISPLAY_STARTUP_ERRORS" => "On", #Even when display_errors is on, errors that occur during PHP's startup sequence are not displayed
    "PHP_MEMORY_LIMIT" => "128M", # This sets the maximum amount of memory in bytes that a script is allowed to allocate
    "PHP_UPLOAD_MAX_FILESIZE" => "2M", # The maximum size of an uploaded file
    "PHP_POST_MAX_SIZE" => "8M", # Sets max size of post data allowed
    "PHP_MAX_EXECUTION_TIME" => "30" # This sets the maximum time in seconds a script is allowed to run before it is terminated by the parser
  }
end