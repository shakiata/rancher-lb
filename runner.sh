ANSIBLE_CONFIG=./ansible.cfg ansible-playbook -i inventory/hosts.ini playbook.yml \
    --limit 'all' --skip-tags "none" --tags "containers"