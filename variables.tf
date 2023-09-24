# Input variables

variable "environment" {
  default = ""
}

variable "env" {
  default = ""
}

variable "bastion_linux" {
  default = {
    hostname   = "bastion_linux"
    private_ip = ""
  }
}

variable "bastion_windows" {
  default = {
    hostname   = "bastion_windows"
    private_ip = ""
  }
}

variable "app" {
  type = map(any)
  default = {
    app_a = {
      hostname   = "app-a",
      private_ip = "",
      subnet = ""
    },
    app_b = {
      hostname   = "app-b",
      private_ip = "",
      subnet = ""
    },
    app_c = {
      hostname   = "app-c",
      private_ip = "",
      subnet = ""
    },
  }
}

variable "mongodb" {
  type = map(any)
  default = {
    mongodb_a = {
      hostname   = "mongodb-a",
      private_ip = "",
      subnet = ""
    },
    mongodb_b = {
      hostname   = "mongodb-b",
      private_ip = "",
      subnet = ""
    },
    mongodb_c = {
      hostname   = "mongodb-c",
      private_ip = "",
      subnet = ""
    },
  }
}

variable "elasticsearch" {
  type = map(any)
  default = {
    elasticsearch_a = {
      hostname   = "elasticsearch-a",
      private_ip = ""
      subnet = ""
    },
    elasticsearch_b = {
      hostname   = "elasticsearch-b",
      private_ip = ""
      subnet = ""
    },
    elasticsearch_c = {
      hostname   = "elasticsearch-c",
      private_ip = ""
      subnet = ""
    },
  }
}

variable "opsmanager" {
  default = {
    hostname   = "opsmanager",
    private_ip = ""
  }
}

variable "stresstest" {
  default = {
    hostname   = "stresstest"
    private_ip = ""
  }
}

variable "web" {
  type = map(any)
  default = {
    web_a = {
      hostname   = "web-a",
      private_ip = ""
      hostname = ""
    },
    web_b = {
      hostname   = "web-b",
      private_ip = ""
      hostname = ""
    },
  }
}