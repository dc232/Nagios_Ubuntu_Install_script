#demo script for nagios 

#Taken from https://www.howtoforge.com/tutorial/ubuntu-nagios/
#this script is a demo script to get started with nagios

#GLOBAL VARS
NAGIOS_VERSION="4.3.4"
NAGIOS_PLUGIN_VERSION="2.2.1"
NPRE_PLUGIN_VERSION="3.2.1"
IP_ADDRESS="$(hostname -I | awk '{print $1}')"


install_programs () {
    cat << EOF
##############################
Installing the following packages 
Apache2 
php and exstentions
#############################
EOF

sleep 2

sudo apt install wget build-essential libgd-dev libgd2-xpm-dev openssl libssl-dev apache2 php apache2-mod-php7.0 php-gd php-mcrypt php-cli sendmail unzip -y
}

apache_config () {
    cat << EOF
    ###############################
    Suppressing global warnings about
    FQDN
    ###############################
EOF
sleep 2
    sed -i '$ a ServerName '$IP_ADDRESS'' /etc/apache2/apache2.conf

    cat << EOF
    ###############################
Checking configuration
    ###############################
EOF
sleep 2
sudo apache2ctl configtest #seems to  be the same as nginx -t

    cat << EOF
    ###############################
Restarting apache
    ###############################
EOF
sleep 2
sudo systemctl restart apache2
}

ufw_firewall_check () {
   cat << EOF
   ########################
   Checking firewall rule 
   ########################
EOF
sleep 2
    sudo ufw app list

cat << EOF 
########################
Checking Apache2 full profile
########################
EOF
sleep 2

sudo ufw app info "Apache Full"

cat << EOF
###########################
Changing firewall rules 
to qllow incoming traffic 
into port 80 and 443
###########################
EOF

sleep 2

sudo ufw allow in "Apache Full"
}

user_and_group_configuration () {
cat << EOF
#############################
creating the user nagios 
creating  group nagcmd
#############################
EOF

sleep 2

sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagios,nagcmd www-data
}


download_extract_install_nagios () {
cat << EOF
#############################
Downloading and exstracting nagios
#############################
EOF

sleep 2


wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-$NAGIOS_VERSION.tar.gz
tar -xzf nagios*.tar.gz
cd nagios-$NAGIOS_VERSION

cat << EOF
#############################
Compiling Nagios
#############################
EOF
sleep 2
./configure --with-nagios-group=nagios --with-command-group=nagcmd

cat << EOF
#############################
installing Nagios
#############################
EOF

sleep 2

sudo make all
sudo make install
sudo make install-commandmode
sudo make install-init
sudo make install-config
sudo /usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf

}

nrpe_nagios_plugin_install () {
    cd ~
    curl -L -O https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-$NPRE_PLUGIN_VERSION/nrpe-$NPRE_PLUGIN_VERSION.tar.gz 
    tar zxvf nrpe-*.tar.gz
    cd nrpe-*
    ./configure
    make check_nrpe
    sudo make install-plugin
}

replace_a_line () {
    cat << EOF 
###############################
Replacing line 51
###############################
EOF
sudo  sed -i '51s/#//' /usr/local/nagios/etc/nagios.cfg
}
#cfg_dir=/usr/local/nagios/etc/servers


contact_info_for_emailing () {

    sudo mkdir -p /usr/local/nagios/etc/servers

    cat << EOF
    ########################################
    please enter email address in the 
    sed subsitution below
    ########################################
EOF

#    sed -i 's/nagios@localhost/email@address.domain/' /usr/local/nagios/etc/objects/contacts.cfg
}

command_check_npre () {
   sudo sed -i '$ a define command{' /usr/local/nagios/etc/objects/commands.cfg
   sudo sed -i '$ a command_name check_nrpe' /usr/local/nagios/etc/objects/commands.cfg
   sudo sed -i '$ a command_line $USER1$/check_npre -H $HOSTADDRESS$ -c $ARG1$' /usr/local/nagios/etc/objects/commands.cfg
   sudo sed -i '$ a }'
   sudo sed -i '240,243s/$^     /' /usr/local/nagios/etc/objects/commands.cfg
}

installing_nagios_plugins () {

cat << EOF
#############################
Installing and configuring 
Nagios plugins
#############################
EOF

cd ~
wget https://nagios-plugins.org/download/nagios-plugins-$NAGIOS_PLUGIN_VERSION.tar.gz
tar -xzf nagios-plugins*.tar.gz
cd nagios-plugins-$NAGIOS_PLUGIN_VERSION/
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
sudo make
sudo make install
}

rest_of_setup () {

    cat << EOF
    ########################################
    Installing Apache Modules
    ########################################
EOF
sleep 2
sudo a2enmod rewrite
sudo a2enmod cgi

cat << EOF 
    ########################################
    Please type you nagios web interface
    password when promted
    ########################################
EOF

sleep 4

sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

    cat << EOF
    ########################################
    enabling Nagios Virtualhosts
    ########################################
EOF

sleep 2

sudo ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/

cat <<EOF
    ########################################
    starting apache and nagios
    ########################################
EOF

sleep 2
sudo service apache2 restart
sudo service nagios start
}


nagios_start_code () {
cat << EOF
#############################
Adding nagios.service to 
systemd to allow it to 
start
#############################
EOF 

sleep 5

sudo cat << EOF >>nagios.service
[Unit]
Description=Nagios
BindTo=network.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
User=nagios
Group=nagios
ExecStart=/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg
EOF
sudo mv nagios.service /etc/systemd/system/


cat << EOF
#############################
Enabling nagios in systemd
#############################
EOF 

sleep 2

sudo systemctl enable /etc/systemd/system/nagios.service
sudo systemctl start nagios
}

apache_and_starting_apache () {
sudo systemctl restart apache2
sudo systemctl start nagios
}

daigs () {
cat << EOF 
##############################################################
Please note that that is the service is not recognised then 
you will need to restart the service inroder for it then 
be recognised
##############################################################
EOF
sleep 5 
sudo systemctl status nagios

cat << EOF
##############################################################
To Acess the Nagios web interface you will need to go 
$IP_ADDRESS/nagios (best to use IPV4 addr then 
add an A record in the DNS Server, remeber to update the serial ;)
U: nagiosadmin
P: whatever you set as the password
##############################################################
EOF
sleep 6

}

overall_install () {
    install_programs
    apache_config
    ufw_firewall_check
    user_and_group_configuration
    download_extract_install_nagios
    nrpe_nagios_plugin_install
    replace_a_line
    contact_info_for_emailing
    command_check_npre
    intalling_nagios_plugins
    rest_of_setup
    nagios_start_code
    apache_and_starting_apache
    daigs
}



Os_Check () {
OS="grep Ubuntu /etc/os-release"

    if [ "$OS" ]; then
    cat << EOF
###########################
Installing and setting up
Nagios version $NAGIOS_VERSION for
Ubuntu 
###########################
EOF
sleep 2
overall_install

else
cat << EOF
###########################
Unkown version of linux
detected exiting
###########################
EOF

sleep 2

exit 0
    fi
}

Os_Check