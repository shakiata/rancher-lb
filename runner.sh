echo "Did you change the names of the Vars Files?"
read blank

ANSIBLE_CONFIG=./ansible.cfg ansible-playbook -i inventory/hosts.ini playbook.yml \
    --limit 'all' --skip-tags "none" --tags "containers"



# Available tags:

#     - `glusterfs`
#     - `common`
#     - `swarm`
#     - `containers`
#     - `apt`
#     - `always`
#     - `ssh`
#     - `ufw`
#     - `docker`
#     - `dns`
#     - `systemd`
#     - `mount-volumes`