# # encoding: utf-8

# Inspec test for recipe docker_nano_host::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe port(2375) do
  it { should be_listening }
end

describe command("& '$env:ProgramFiles/docker/docker' ps") do
  its('exit_status') { should eq 0 }
end

describe command("(Get-service -Name 'docker').status") do
  its(:stdout) { should eq("Running\r\n") }
end
