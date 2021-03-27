# Usiful playbooks and ansible commands

## Playbooks

### create LXD

1. add the lxd info inside `inventory/lxd_invetory.ini`


2. run 
```
ansible-playbook -i inventory/lxd_invetory.ini create-lxd.yml
```

### create Postgres instance


ansible-playbook -i inventory/lxd_invetory.ini create-cluster.yml  --vault-password-file ~/.vault_pass.txt