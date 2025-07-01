# systemd-leak-repro
make - it will start qemu, deploy ham.service and patch OS to boot systemd under valgrind, and reboot (give it time)

It uses cloud-init to patch things up and to deploy service.


root:toor
