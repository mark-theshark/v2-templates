terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 0.4.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }
}

variable "use_kubeconfig" {
  type        = bool
  sensitive   = true
  description = <<-EOF
  Use host kubeconfig? (true/false)

  Set this to false if the Coder host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.

  Set this to true if the Coder host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Coder host.
  EOF
}

variable "workspaces_namespace" {
  type        = string
  sensitive   = true
  description = "The namespace to create workspaces in (must exist prior to creating workspaces)"
  default     = "coder-clean"
}

provider "kubernetes" {
  # Authenticate via ~/.kube/config or a Coder-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}

data "coder_workspace" "me" {}

resource "coder_agent" "coder" {
  os   = "linux"
  arch = "amd64"
  #dir            = "/home/${lower(data.coder_workspace.me.owner)}"
  dir = "/home/coder"
  startup_script = <<EOT
#!/bin/bash
# start supervisord and start jupyterlab
/coder/configure 2>&1 > ~/configure.log

# install code-server
curl -fsSL https://code-server.dev/install.sh | sh
code-server --auth none --port 13337 &

# clone dotfiles
coder dotfiles git@github.com:mark-theshark/dotfiles.git -y
EOT
}

# code-server
resource "coder_app" "code-server" {
  agent_id      = coder_agent.coder.id
  name          = "code-server"
  icon          = "https://cdn.icon-icons.com/icons2/2107/PNG/512/file_type_vscode_icon_130084.png"
  url           = "http://localhost:13337?folder=/home/coder"
  relative_path = true  
}

resource "coder_app" "jupyterlab" {
  agent_id      = coder_agent.coder.id
  name          = "jupyterlab"
  icon          = "https://upload.wikimedia.org/wikipedia/commons/3/38/Jupyter_logo.svg"
  url           = "http://localhost:8888/"
  relative_path = true
}

resource "kubernetes_pod" "main" {
  count = data.coder_workspace.me.start_count
  metadata {
    name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
    namespace = "coder-clean"
  }
  spec {
    container {
      name    = "jupyterlab"
      image   = "docker.io/marktmilligan/jupyterlab:dev-url"
      command = ["sh", "-c", coder_agent.coder.init_script]
      security_context {
        run_as_user = "1000"
      }
      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.coder.token
      }
    }    
  }
}
