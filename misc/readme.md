Everything in this folder will be decompressed on the target system before the first boot, at the same level.

For instance:

- ./misc/root/.bashrc ⇒ /root/.bashrc
- ./misc/root/.ssh/authorized_keys ⇒ /root/.ssh/authorized_keys
- etc…

Your SSH public key is specified in system.yml file, with a full path, for instance:

```yaml
root:
  password: ********
  pubkey: /home/andre/.ssh/arodier.rsa.pub
```
