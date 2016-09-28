powershell_script 'install networking dsc module' do
  code 'Install-package -Name xNetworking -ForceBootstrap -Provider PowerShellGet -Force'
  not_if '(Get-Module xNetworking -list) -ne $null'
end

zip_path = "#{Chef::Config[:file_cache_path]}/docker.zip"
docker_config = File.join(ENV["ProgramData"], "docker", "config")

remote_file zip_path do
  source "https://download.docker.com/components/engine/windows-server/cs-1.12/docker.zip"
  action :create_if_missing
end

dsc_resource "Extract Docker" do
  resource :archive
  property :path, zip_path
  property :ensure, "Present"
  property :destination, ENV["ProgramFiles"]
end

directory docker_config do
  recursive true
end

file File.join(docker_config, "daemon.json") do
  content "{ \"hosts\": [\"tcp://0.0.0.0:2375\", \"npipe://\"] }"
end

powershell_script "install docker service" do
  code "& '#{File.join(ENV["ProgramFiles"], "docker", "dockerd")}' --register-service"
  not_if "Get-Service docker -ErrorAction SilentlyContinue"
end

service 'docker' do
  action [:start]
end

dsc_resource "Enable docker firewall rule" do
  resource :xfirewall
  property :name, "Docker daemon"
  property :direction, "inbound"
  property :action, "allow"
  property :protocol, "tcp"
  property :localport, [ "2375" ]
  property :ensure, "Present"
  property :enabled, "True"
end
