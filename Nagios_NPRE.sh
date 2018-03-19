###############################
#NPRE 
#Nagios Remote Plugin executor
#############################

#taken from https://www.digitalocean.com/community/tutorials/how-to-install-nagios-4-and-monitor-your-servers-on-ubuntu-16-04#step-5-%E2%80%94-installing-npre-on-a-host

NAGIOS_PLUGIN_VER="2.2.1"
NPRE_VERSION="3.2.1"
IP_ADDR_OF_NAGIOS_SERVER="10.0.0.35"

add_user () {
    sudo useradd nagios 
}

install_NPRE_packages () {
    sudo apt update && sudo apt install build-essential libgd2-xpm-dev openssl libssl-dev unzip -y
}

nagios_Plugin_setup () {
    cd ~
    curl -L -O http://nagios-plugins.org/download/nagios-plugins-$NAGIOS_PLUGIN_VER.tar.gz
    tar zxvf nagios-plugins-*.tar.gz
    cd nagios-plugins-*
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
    sudo make 
    sudo make install
}

NPRE_install () {
    cd ~
    curl -L -O https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-$NPRE_VERSION/nrpe-$NPRE_VERSION.tar.gz
    tar zxf nrpe-*.tar.gz
    cd nrpe-*
    ./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
    sudo make all
    sudo make install
    sudo make install-config
    sudo make install-init
}

host_ip_address_adding () {
ALLOWED_HOSTS="allowed_hosts=127.0.0.1,::1,"$IP_ADDR_OF_NAGIOS_SERVER""
sudo sed -i '106d' /usr/local/nagios/etc/nrpe.cfg
sudo sed -i '106i '$ALLOWED_HOSTS'' /usr/local/nagios/etc/nrpe.cfg
}

NPRE_service_and_diags () {
    sudo systemctl start nrpe.service
    sudo systemctl status nrpe.service
}

firewall_ufw_config () {
    sudo ufw allow 5566/tcp
}

comms_check () {
    /usr/local/nagios/libexec/check_nrpe -H
}

overall_install () {
    add_user
    install_NPRE_packages
    nagios_Plugin_setup
    NPRE_install
    host_ip_address_adding
    NPRE_service_and_diags
}


cat << EOF
##################################################################
This script is desighned to install the nagios NPRE
Nagios Remote Plugin executor
Note: before running the script 
please ensure that you have populated the variable $IP_ADDR_OF_NAGIOS_SERVER
with the IP address of the Nagios Server
##################################################################
EOF
sleep 6

overall_install


