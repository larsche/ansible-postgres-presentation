# Usiful playbooks and ansible commands

## Playbooks

### create LXD

1. add the lxd info inside `inventory/lxd_invetory.ini`


2. run 
```
ansible-playbook -i inventory/lxd_invetory.ini create-lxd.yml
```