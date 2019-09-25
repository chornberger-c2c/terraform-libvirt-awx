#!/bin/bash
mkdir -p /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYiGNCEq4+gMpKaRXR5K/mSGeGO5Z4QPh852agg2U2tvYFX4MgDvuS6yXueIslzbsOJWluCi9rZkR0ZzCdD1DqbKQXyB7sbXW29FJj/5BMnxQaLW04T5hhLw97GxY+Kf5NG72ixLa7uNpZpBy06NA0nNAS8u+E2qYegSp2F5xcahUo1kRgqiYfrWe6g9JDnujk7SbtOMPQSnhUJpnacykrgckvlRuo+XjqQdYgn9q+MZPSVfmOZHCdr8BDuST2JhRGHqU5STcj/XpV8ADvkzirfIAXmRbFjC/U+KdxfCu8a/Rym+hTAv4hL3eix8CNBmd9fEUEicSLmQR5JMpfLFCd horni@feddy" >> /root/.ssh/authorized_keys
hostnamectl set-hostname k8s-worker
(echo pass123; echo pass123) | passwd
sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload ssh

