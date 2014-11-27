Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provision :shell, path: "provision.sh"

  config.vm.network :forwarded_port, host: 8080, guest: 80

  if is_windows
    config.vm.synced_folder ".", "/vagrant", type: "smb"
  else
    config.vm.synced_folder ".", "/vagrant", owner: "www-data", group: "vagrant", mount_options: ["dmode=777,fmode=666"]
  end
end
