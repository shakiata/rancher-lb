<h1 align="center">
  <a href="https://github.com/ansible-glusterfs-swarm">
    <img src="https://www.svgrepo.com/show/354115/nginx.svg" alt="Logo" width="" height="100">
  </a>
    <a href="https://github.com/ansible-glusterfs-swarm">
    <img src="https://static-00.iconduck.com/assets.00/pihole-icon-1393x2048-dld9kbl1.png" alt="Logo" width="" height="120">
  </a>
    <a href="https://github.com/ansible-glusterfs-swarm">
    <img src="https://raw.githubusercontent.com/docker-library/docs/471fa6e4cb58062ccbf91afc111980f9c7004981/swarm/logo.png" alt="Logo" width="" height="110">
  </a>
  </a>
    <a href="https://github.com/ansible-glusterfs-swarm">
    <img src="https://ispire.me/wp-content/uploads/2017/02/file-changed-as-we-read-it-glusterfs-issue.png" alt="Logo" width="" height="120">
  </a>
</h1>

<div align="center">
  <b>Rancher-LB</b> - Highly Available Swarm + GlusterFS Cluster with NGINX Load Balancer and Pi-hole DNS to serve your rancher instance. (and downstream applications)
  <br />
  <br />
  <a href="https://github.com/ansible-glusterfs-swarm/issues/new?assignees=&labels=bug&title=bug%3A+">Report a Bug</a>
  ·
  <a href="https://github.com/ansible-glusterfs-swarm/issues/new?assignees=&labels=enhancement&template=02_FEATURE_REQUEST.md&title=feat%3A+">Request a Feature</a>
</div>
<br>
<details open="open">
<summary>Table of Contents</summary>

summary>Table of Contents</summary>

- [About](#about)
- [System Requirements](#system-requirements)
- [Repository Structure](#repository-structure)
- [Install Required Ansible Collections](#install-required-ansible-collections)
- [Usage](#usage)
  - [Inventory Configuration](#inventory-configuration)
  - [Variable Configuration](#variable-configuration)
  - [Running the Playbook](#running-the-playbook)
- [Contributing](#contributing)
- [License](#license)

</details>
<br>

# About

This repository contains Ansible playbooks to set up a highly available loadbalancer/ DNS cluster:

- GlusterFS
- Docker Swarm
- NGINX Load Balancer
- Round Robbin Pi-hole DNS pointing at swarm nodes
- Wildcard DNS

# System Requirements

### OS Support
- Works and tested on Ubuntu versions 22.04 and up.

### Ansible Version Requirement
- Deployment environment must have Ansible 2.9.0+

## Repository Structure

```plaintext
├── inventory/
│   ├── hosts.ini
│   └── group_vars/
│       └── all.yml
├── playbook.yml
├── roles/
│   ├── common/
│   │   └── tasks/
│   │       └── apt.yml
│   │       └── debug.yml
│   │       └── dns.yml
│   │       └── docker.yml
│   │       └── main.yml
│   │       └── ssh_setup.yml
│   │       └── ufw.yml
│   ├── docker-swarm/
│   │   └── tasks/
│   │       └── main.yml
│   │       └── swarm_join.yml
│   │       └── swarm_master.yml
│   ├── glusterfs-persistent-storage/
│   │   └── tasks/
│   │       └── configure.yml
│   │       └── create-volumes.yml
│   │       └── install.yml
│   │       └── main.yml
│   │       └── mount-volumes.yml
│   ├── nginx-load-balancer/
│   │   └── handlers/
│   │       └── main.yml
│   │   └── tasks/
│   │       └── main.yml
│   ├── pihole-dns/
│   │   └── handlers/
│   │   └── tasks/
│   │       └── main.yml
├── runner.sh
├── ssh-copy
```

## Usage

### Inventory Configuration

Update your [`inventory/hosts.ini`](inventory/hosts.ini ) file with the target servers and any required variables:

**inventory/hosts.ini:**

```ini
[load-balancers]
lbserver1 ansible_host=192.168.0.38
lbserver2 ansible_host=192.168.0.42
lbserver3 ansible_host=192.168.0.43

[load-balancers:vars]
ansible_user={{ssh_user}} 
ansible_port={{ssh_port}}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file={{ssh_cert}}
ansible_become=true
```

### Variable Configuration

Update the centralized variables in [`inventory/group_vars/all.yml`](inventory/group_vars/all.yml ):

**inventory/group_vars/all.yml:**

```yaml
---
# Ansible Common Variables
ssh_user: adminuser
ansible_sudo_pass: adminpass
ssh_cert: ~/.ssh/id_ed25519
ssh_port: "22"
TZ: America/Toronto

# Pi-hole Variables
pihole_password: adminpass

# NGINX Load Balancer Variables
downstream_hostname_public: jtmb.cc
downstream_hostname_internal: rancher-dev.branconet.lan
downstream_nodes:
  - 192.168.0.39
  - 192.168.0.40
  - 192.168.0.41

# GlusterFS Variables
glusterfs_packages:
  - glusterfs-server
  - glusterfs-client

gluster_replica_count: 3
glusterfs_nodes:
  - "{{ hostvars['lbserver1']['ansible_host'] }}"
  - "{{ hostvars['lbserver2']['ansible_host'] }}"
  - "{{ hostvars['lbserver3']['ansible_host'] }}"

gluster_volumes_paths: 
  - /opt/swarm-volumes/nginx-lb
  - /opt/swarm-volumes/pihole-dns

gluster_volumes:
  - name: nginx-lb
    bricks:
      - "{{ glusterfs_nodes[0] }}:{{ gluster_volumes_paths[0] }}"
      - "{{ glusterfs_nodes[1] }}:{{ gluster_volumes_paths[0] }}"
      - "{{ glusterfs_nodes[2] }}:{{ gluster_volumes_paths[0] }}"
  - name: pihole-dns
    bricks:
      - "{{ glusterfs_nodes[0] }}:{{ gluster_volumes_paths[1] }}"
      - "{{ glusterfs_nodes[1] }}:{{ gluster_volumes_paths[1] }}"
      - "{{ glusterfs_nodes[2] }}:{{ gluster_volumes_paths[1] }}"
```

### Running the Playbook

To execute the playbook, run:

```bash
ansible-playbook -i inventory/hosts.ini playbook.yml
```

or

```bash
./runner.sh
```

## Contributing

First off, thanks for taking the time to contribute! Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make will benefit everybody else and are **greatly appreciated**.

Please try to create bug reports that are:

- _Reproducible._ Include steps to reproduce the problem.
- _Specific._ Include as much detail as possible: which version, what environment, etc.
- _Unique._ Do not duplicate existing opened issues.
- _Scoped to a Single Bug._ One bug per report.

## License

This project is licensed under the **GNU GENERAL PUBLIC LICENSE v3**. Feel free to edit and distribute this template as you like.

See LICENSE for more information.
```

Similar code found with 1 license type