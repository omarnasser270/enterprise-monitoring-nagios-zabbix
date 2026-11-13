NODES = {
  "db01"      => { ip: "192.168.56.23", memory: 1024, cpus: 1, script: "provision/db.sh" },
  "app01"     => { ip: "192.168.56.22", memory: 512,  cpus: 1, script: "provision/app.sh" },
  "web01"     => { ip: "192.168.56.21", memory: 512,  cpus: 1, script: "provision/web.sh" },
  "generic01" => { ip: "192.168.56.24", memory: 512,  cpus: 1, script: "provision/generic.sh" },
  # Bare VMs: Nagios and Zabbix are installed manually later (no provisioning here)
  "nagios01"  => { ip: "192.168.56.10", memory: 1536, cpus: 1, script: nil },
  "zabbix01"  => { ip: "192.168.56.11", memory: 2048, cpus: 2, script: nil },
}

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  NODES.each do |name, cfg|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: cfg[:ip]

      node.vm.provider "virtualbox" do |vb|
        vb.name   = name
        vb.memory = cfg[:memory]
        vb.cpus   = cfg[:cpus]
      end

      node.vm.provision "shell", path: cfg[:script] if cfg[:script]
    end
  end
end
