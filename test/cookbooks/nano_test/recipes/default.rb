# There is a bug in Test-Kitchen on nano that clears the PATH
# This will be fixed in the next release but is fixed by this:
ENV['PATH'] += ";C:\\Windows\\system32;C:\\Windows;C:\\Windows\\System32\\Wbem;C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\;C:\\Users\\vagrant\\AppData\\Local\\Microsoft\\WindowsApps"
node.automatic[:languages][:powershell][:version] = "5.1.14368.1000"
