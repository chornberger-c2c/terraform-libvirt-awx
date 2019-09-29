#!/bin/bash

#ssh pubkey
mkdir -p /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYiGNCEq4+gMpKaRXR5K/mSGeGO5Z4QPh852agg2U2tvYFX4MgDvuS6yXueIslzbsOJWluCi9rZkR0ZzCdD1DqbKQXyB7sbXW29FJj/5BMnxQaLW04T5hhLw97GxY+Kf5NG72ixLa7uNpZpBy06NA0nNAS8u+E2qYegSp2F5xcahUo1kRgqiYfrWe6g9JDnujk7SbtOMPQSnhUJpnacykrgckvlRuo+XjqQdYgn9q+MZPSVfmOZHCdr8BDuST2JhRGHqU5STcj/XpV8ADvkzirfIAXmRbFjC/U+KdxfCu8a/Rym+hTAv4hL3eix8CNBmd9fEUEicSLmQR5JMpfLFCd horni@feddy" >> /root/.ssh/authorized_keys

#hostname awx
hostnamectl set-hostname awx
#sed -i s/without-password/yes/ /etc/ssh/sshd_config

#node.js
curl -sL https://rpm.nodesource.com/setup_12.x | bash -

#yum packages: git docker ansible nodejs python-pip
yum -y install epel-release
yum -y install git docker ansible nodejs python-pip

#pip packages
pip install docker
pip install docker-compose

#selinux
setenforce permissive
sed -i s/SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config

#start docker unit
systemctl enable docker
systemctl start docker

#docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#awx repo
cd /root
git clone https://github.com/ansible/awx.git
cd awx/installer
ansible-playbook -i inventory install.yml

#wait
sleep 15m

#tower-cli
pip install ansible-tower-cli
tower-cli config host http://localhost:80
tower-cli config username admin
tower-cli config password password
tower-cli config verify_ssl False

#get ips
#yum -y install nmap
#worker=$(nmap -sn 192.168.122.0/24|awk '/worker/ {sub(/)/, ""); sub(/\(/, ""); print $6}')
#master=$(nmap -sn 192.168.122.0/24|awk '/master/ {sub(/)/, ""); sub(/\(/, ""); print $6}')

#create workflow
tower-cli organization create --name="Default"
tower-cli project create --name k8s --organization "Default" --scm-type git --scm-url https://github.com/horni23/terraform-libvirt-awx.git --wait
tower-cli inventory create --name="kubernetes" --description="k8s cluster" --organization=Default 
tower-cli host create --name="k8s-master" --inventory="kubernetes"
tower-cli host create --name="k8s-worker" --inventory="kubernetes"
tower-cli credential create --name k8s --credential-type 1 --inputs='{"username": "root", "password": "pass123"}' --organization="Default"
tower-cli job_template create --name=k8s-cluster --description="setup kubernetes cluster" --inventory="kubernetes" --project="k8s" --playbook="playbooks/k8s-cluster.yml" --credential="k8s" --job-type=run --verbosity=verbose --forks=5 --ask-credential-on-launch true
#tower-cli job launch --job-template="k8s-cluster"

#new awx cli
#pip install "https://github.com/ansible/awx/archive/7.0.0.tar.gz#egg=awxkit&subdirectory=awxkit"