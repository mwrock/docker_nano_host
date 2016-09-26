powershell_script 'install Nuget package provider' do
  code 'Install-PackageProvider -Name NuGet -Force'
  not_if '(Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction SilentlyContinue) -ne $null'
end

powershell_script 'install nano container package' do
  code 'Install-Module -Name xNetworking -Force'
  not_if '(Get-Module xNetworking -list) -ne $null'
end

zip_path = "#{Chef::Config[:file_cache_path]}/docker-1.12.0.zip"
docker_config = File.join(ENV["ProgramData"], "docker", "config")

remote_file zip_path do
  source "https://get.docker.com/builds/Windows/x86_64/docker-1.12.0.zip"
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
