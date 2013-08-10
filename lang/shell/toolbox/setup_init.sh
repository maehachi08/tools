#!/bin/bash
# pachi
# 
# setup
# 

cat << EOT >> /etc/hosts
192.168.146.102 manage001.pachi.local
EOT

yum install ntp
ntpdate 210.173.160.27

rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

cat << "EOT" > /etc/yum.repos.d/dag.repo 
[dag]
name=DAG RPM Repository
baseurl=http://ftp.riken.jp/Linux/dag/redhat/el$releasever/en/$basearch/dag
gpgcheck=1
gpgkey=http://ftp.riken.go.jp/pub/Linux/dag/RPM-GPG-KEY.dag.txt
EOT

yum -y install puppet puppet-server
rm -rf /var/lib/puppet/ssl/

cat << "EOT" > /etc/puppet/puppet.conf
[main]
ssldir = $vardir/ssl
rundir = /var/run/puppet
logdir = /var/log/puppet
 
[master]
environment = production
certname    = manage001.pachi.local
manifestdir = $vardir/data/manifests
templatedir = $vardir/data/templates
modulepath  = $vardir/data/modules:$vardir/modules
ssl_client_header        = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
 
[agent]
environment = production
server      = manage001.pachi.local
factsource  = puppet://$server/facts
pluginsync  = true
EOT

puppet agent --test --noop --server=manage001.pachi.local --certname=web001.pachi.local
