---
name: Build an image from a Dockerfile and develop in a container in a Docker host with code-server
description: The goal is to enable code-server (VS Code) 
tags: [local, docker]
---

# Build an image and code-server (VS Code) template for a workspace in a container on a Docker host

### Apps included
1. A web-based terminal
1. code-server IDE (VS Code-in-a-browser)

### Additional resources
1. `docker_image` and `build` to build a VNC image from a Dockerfile included in the directory

### Additional bash scripting
1. Prompt user and clone/install a dotfiles repository (for personalization settings)
1. Prompt user for code-server release to install
1. Clone repo
1. Download, install and start code-server (VS Code-in-a-browser)

### Known limitations


### Authentication


### Resources
[Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
[Image Resource](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image)
[VNC Dockerfile](https://github.com/coder/enterprise-images/tree/main/images/vnc)
[Coder OSS VNC docs](https://github.com/bpmct/coder-templates/tree/main/desktop-container)

