# vagrant-lamp

A LAMP development environment with [Vagrant](https://www.vagrantup.com/) using [VMware Workstation](https://www.vmware.com/) created by Yoann LAMY under the terms of the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).

This LAMP environment is based on a [Rocky Linux 9](https://rockylinux.org/) distribution and contains :
* An [Apache/httpd](https://httpd.apache.org/) web server
* A [MariaDB](https://mariadb.org/) server
* [PHP](https://www.php.net) scripting language
* [Xdebug](https://xdebug.org/) to provides a range of features to improve the PHP development experience
* [phpMyAdmin](https://www.phpmyadmin.net/) to handle the administration of MySQL over the Web
* [Composer](https://getcomposer.org/) to manage dependencies in PHP

The php version and some PHP parameters can be defined through the ``Vagrantfile``.

### Usage

- ``cd vagrant-lamp``
- Edit ``Vagrantfile`` to customize settings :

```
  ...
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
    "PHP_MAX_EXECUTION_TIME" => "120", # This sets the maximum time in seconds a script is allowed to run before it is terminated by the parser
    "PHP_XDEBUG_MODE" => "debug", # This setting controls which Xdebug features are enabled (off, develop, coverage, debug, gcstats, profile, trace)
    "PHP_XDEBUG_CLIENT_HOST" => "192.168.2.1", # Configures the IP address or hostname where Xdebug will attempt to connect to when initiating a debugging connection
    "PHP_XDEBUG_START_WITH_REQUEST" => "default" # A Function Trace, Garbage Collection Statistics, Profiling, or Step Debugging can be activated at the start of a PHP request (yes, no, trigger, default)
  }
  ...
```

This LAMP environment must be started using Vagrant.

- ``vagrant up``

```
    ...
    default: Disbaling SELinux...
    default: Configuring Timezone...
    default: Cleaning dnf cache...
    default: Updating the system...
    default: Installing LAMP...
    default: Installing Composer...    
    default: Configuring Apache/httpd...
    default: Configuring MariaDB...
    default: Configuring PHP...
    default: Configuring phpinfo...
    default: Configuring phpMyAdmin...
    default: Starting LAMP...
    default:
    default: LAMP is ready !
    default: - Apache/httpd version : 2.4.57
    default: - MariaDB version : 10.5.22
    default: - PHP version : 8.2.16
    default: - phpMyAdmin version : 5.2.1
    default: - Composer version : 2.7.1    
    default:
    default: Informations :
    default: - Web server URL : http://127.0.0.1/
    default: - phpinfo URL : http://127.0.0.1/phpinfo/
    default: - phpMyAdmin URL : http://127.0.0.1/phpmyadmin/
    default: - MariaDB host : localhost
    default: - MariaDB port : 3306
    default: - MariaDB user : root
    default: - MariaDB root password is empty
```

And it must be destroy using Vagrant.

- ``vagrant destroy``

```
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
    ...    
```