environment = "PROD"
env = "PROD"

bastion_linux = {
  hostname   = "HKAWSBASPLV001"
  private_ip = "172.17.1.4"
}
bastion_windows = {
  hostname   = "HKAWSBASPWV001"
  private_ip = "172.17.1.5"
}
app = {
  app_a = {
    hostname   = "HKAWSAPPPLV001",
    private_ip = "172.17.21.9",
    subnet = "prod-private-subnet-a"
  },
  app_b = {
    hostname   = "HKAWSAPPPLV002",
    private_ip = "172.17.22.9",
    subnet = "prod-private-subnet-b"
  },
  app_c = {
    hostname   = "HKAWSAPPPLV003",
    private_ip = "172.17.23.9",
    subnet = "prod-private-subnet-c"
  },
}
mongodb = {
  mongodb_a = {
    hostname   = "HKAWSDBSPLV001",
    private_ip = "172.17.21.5",
    subnet = "prod-private-subnet-a"
  },
  mongodb_b = {
    hostname   = "HKAWSDBSPLV002",
    private_ip = "172.17.22.5",
    subnet = "prod-private-subnet-b"
  },
  mongodb_c = {
    hostname   = "HKAWSDBSPLV003",
    private_ip = "172.17.23.5",
    subnet = "prod-private-subnet-c"
  },
}
elasticsearch = {
  elasticsearch_a = {
    hostname   = "HKAWSELSPLV001",
    private_ip = "172.17.21.6"
    subnet = "prod-private-subnet-a"
  },
  elasticsearch_b = {
    hostname   = "HKAWSELSPLV002",
    private_ip = "172.17.22.6"
    subnet = "prod-private-subnet-b"
  },
  elasticsearch_c = {
    hostname   = "HKAWSELSPLV003",
    private_ip = "172.17.23.6"
    subnet = "prod-private-subnet-c"
  },
}
opsmanager = {
  hostname   = "HKAWSDBSPLV004",
  private_ip = "172.17.21.7"
}
stresstest = {
  hostname   = "HKAWSAPPPWV001"
  private_ip = "172.17.21.8"
}
web = {
  web_a = {
    hostname   = "HKAWSWEBPLV001",
    private_ip = "172.17.121.4",
    subnet = "prod-web-subnet-a"
  },
  web_b = {
    hostname   = "HKAWSWEBPLV002",
    private_ip = "172.17.122.4",
    subnet = "prod-web-subnet-b"
  },
}
