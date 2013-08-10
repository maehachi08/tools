#!/bin/bash
# pachi
# 
# Install apache with passenger
# 

function create_maehachi08() {
    groupadd -g 5000 worker
    useradd -u 5000 -g 5000 maehachi08
}

function install_rbenv() {
    yum -y install git
    su -l maehachi08 -c "git clone git://github.com/sstephenson/rbenv.git /home/maehachi08/.rbenv"
    su -l maehachi08 -c "mkdir /home/maehachi08/.rbenv/{shims,plugins,versions}"
    su -l maehachi08 -c "git clone git://github.com/jamis/rbenv-gemset.git /home/maehachi08/.rbenv/plugins/gemse"
    su -l maehachi08 -c "git clone git://github.com/sstephenson/ruby-build.git /home/maehachi08/.rbenv/plugins/ruby-build"

    export PREFIX=/home/maehachi08/.rbenv
    cd /home/maehachi08/.rbenv/plugins/ruby-build/
    ./install.sh

    # 冪等性を保証するためにチェック
    if [ $( (grep 'RBENV_ROOT' /home/maehachi08/.bash_profile > /dev/null) ; echo $?) -ne 0 ] ; then
        cat << EOT ->> /home/maehachi08/.bash_profile
		export RBENV_ROOT="/home/maehachi08/.rbenv"
		export PATH="/home/maehachi08/.rbenv/bin:$PATH"
		eval "\$(rbenv init -)"
EOT
    fi
}

function install_ruby() {
    su -l maehachi08 -c "rbenv install 1.9.3-p194"
    su -l maehachi08 -c "rbenv global 1.9.3-p194"
}

function install_apache() {
    yum -y install make gcc-c++ curl-devel openssl-devel zlib-devel
    yum -y install ruby-devel rubygems
    yum -y install httpd httpd-devel mod_ssl
}

function install_passenger() {
    test ! -e /home/maehachi08/.rbenv/shims/passenger && su -l maehachi08 -c "gem install passenger"
    su -l maehachi08 -c "rbenv rehash"
    test ! -e /home/maehachi08/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/passenger-4.0.10/buildout/apache2/mod_passenger.so && su -l maehachi08 -c "yes | passenger-install-apache2-module"
    #test ! -f /etc/httpd/conf.d/passnger.conf && /home/maehachi08/.rbenv/shims/passenger-install-apache2-module --snippet > /etc/httpd/conf.d/passnger.conf
    /home/maehachi08/.rbenv/shims/passenger-install-apache2-module --snippet > /etc/httpd/conf.d/passnger.conf


    # 冪等性を保証するためにチェック
#    if [ $( (grep 'PassengerUserSwitching' /etc/httpd/conf.d/passnger.conf > /dev/null) ; echo $?) -ne 0 ] ; then
#    cat << EOT ->> /etc/httpd/conf.d/passnger.conf
#	PassengerUserSwitching off
#	PassengerDefaultUser   apache
#EOT
#    fi
}

function install_mysql() {
    yum -y install mysql mysql-server mysql-devel

    cp -af /usr/share/mysql/my-medium.cnf /etc/my.cnf
    sed -i -e s:/var/lib/mysql/mysql\.sock:/tmp/mysql.sock:g /etc/my.cnf
    service mysqld start

    if [ ! -e /tmp/mysql.sock ]; then
        exit 99
    fi
}

function install_module_for_rails() {
    # Install package for nokogiri
    yum install -y gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel
}

function deploy_app() {
    rsync -av 192.168.146.102:/var/backup/app/rails/infinitewall /var/www/
    chown -R maehachi08:worker /var/www/infinitewall
}


function setup_app() {
    su -l maehachi08 -c "gem install bundler"
    su -l maehachi08 -c "rbenv rehash"
    su -l maehachi08 -c "cd /var/www/infinitewall/ ; bundle install"

    su -l maehachi08 -c "cd /var/www/infinitewall/ ; rake db:create RAILS_ENV='production'"
    su -l maehachi08 -c "cd /var/www/infinitewall/ ; rake db:migrate RAILS_ENV='production'"
}


function setup_apache() {
    cat << EOT -> /etc/httpd/conf.d/infinitewall.conf
<VirtualHost *:80>
    ServerName infinite-wall.pachi.local
    DocumentRoot /var/www/infinitewall/public
    <Directory />
        Options Indexes
    </Directory>
</VirtualHost>
EOT

    service httpd stop
    service httpd start
}


create_maehachi08
install_rbenv
install_apache
install_mysql
install_ruby
install_passenger
install_module_for_rails
deploy_app
setup_app
setup_apache
