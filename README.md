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

## Running a windows container

* Install the docker client locally (windows or linux)
* Ensure your `DOCKER_HOST` is set as above
* `docker pull microsoft/nanoserver`
* `docker run -it microsoft/nanoserver powershell`

## Problems on Hyper-V

The vagrant box supports a Hyper-V and VirtualBox providers. There is a known issue with the Hyper-V provider on nano:

Vagrant validates winrm connectivity using powershell in such a way that breaks. A small change to the vagrant source can work around this. Update `C:\HashiCorp\Vagrant\embedded\gems\gems\vagrant-1.8.5\plugins\communicators\winrm\communicator.rb` and change

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
