# docker_nano_host

A sample cookbook that can configure a Windows Nano Server as a Docker container host.

## Requirements

* chef-dk 0.18.26 or greater
* Recent version of Vagrant

## Creating the nano docker host with test kitchen

* simply run `kitchen converge`
* Creates a Nano vagrant box running as a docker host and listening on port 2375
* On VirtualBox add a port forwarding rule for port 2375 from host to guest
* Set `DOCKER_HOST` to `tcp://<ip of vm>:2375`
* Now docker commands should run against the Nano host

## Problems on Hyper-V

The vagrant box supports a Hyper-V and VirtualBox providers. There are two known issues with the Hyper-V provider:

1. Vagrant validates winrm connectivity using powershell in such a way that breaks. A small change to the vagrant source can work around this. Update `C:\HashiCorp\Vagrant\embedded\gems\gems\vagrant-1.8.5\plugins\communicators\winrm\communicator.rb` and change

```
        result = Timeout.timeout(@machine.config.winrm.timeout) do
          shell(true).powershell("hostname")
        end
```
to
```
        result = Timeout.timeout(@machine.config.winrm.timeout) do
          shell(true).cmd("hostname")
        end
```

2. The Hyper-V box may "Blue Screen" on first boot once or twice. If this happens, you should reboot the box and then it should boot normally moving forward. I anticipate this will be fixed in future RTM builds.

## I want to run on Windows Azure

You can do this using [Stuart Preston's](https://github.com/stuartpreston) excellent [kitchen-azurerm](https://github.com/pendrica/kitchen-azurerm) driver.

Change the `.kitchen.yml` driver and platform config to look like:

```
---
driver:
  name: azurerm

driver_config:
  subscription_id: 'your subscription id'
  location: 'West Europe'
  machine_size: 'Standard_F1'

platforms:
  - name: windowsnano
    driver_config:
      image_urn: MicrosoftWindowsServer:WindowsServer:2016-Nano-Server-Technical-Preview:latest
```

See the [kitchen-azurerm readme](https://github.com/pendrica/kitchen-azurerm) for details regarding azure authentication configuration.
