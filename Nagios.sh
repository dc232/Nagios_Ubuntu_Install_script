#demo script for nagios 

#Taken from https://www.howtoforge.com/tutorial/ubuntu-nagios/
#this script is a demo script to get started with nagios




install_programs () {
    cat << EOF
##############################
Installing the following packages 
Apache2 
php7.0
apache mod php
pph-gd exstention 
unzip 
apache-mod-php7.0
sendmail
#############################
EOF

sleep 2

sudo apt install wget build-essential apache2 php apache2-mod-php7.0 php-gd libgd-dev sendmail unzip -y
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

wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.2.0.tar.gz
tar -xzf nagios*.tar.gz
cd nagios-4.2.0

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

even_hander_dir_copy () {

cat << EOF
#############################
copying and changing ownership
of directories
#############################
EOF

sudo cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
sudo chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
}

intalling_nagios_plugins () {

cat << EOF
#############################
Installing and configuring 
Nagios plugins
#############################
EOF

cd ~
wget https://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
tar -xzf nagios-plugins*.tar.gz
cd nagios-plugins-2.1.2/
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
sudo make
sudo make install
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


rest_of_setup () {

    sudo mkdir -p /usr/local/nagios/etc/servers

    cat << EOF
    ########################################
    please enter email address in the 
    sed subsitution below
    ########################################
EOF

#    sed -i 's/nagios@localhost/email@address.domain/' /usr/local/nagios/etc/objects/contacts.cfg

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

cat <<EOF
    ########################################
    Copying Skelton to Nagios
    ########################################
EOF
sleep 2


NAGIOS_PATH="/etc/init.d/nagios"
sudo cp /etc/init.d/skeleton $NAGIOS_PATH

}


nagios_start_code () {
NAGIOS_PATH="/etc/init.d/nagios"
cat << EOF
#############################
Changing $NAGIOS_PATH with new
infromation
#############################
EOF 

sleep 2

# the $ means go to the end of the file 
DEAMON_INSERT='DAEMON=/usr/local/nagios/bin/$NAME'
PATH_TO_INSERT="/usr/local/nagios/etc/nagios.cfg"
DAEMON_ARGS_INSERT='DAEMON_ARGS="-d '$PATH_TO_INSERT'"'
PIDFILE_INSERT='PIDFILE=/usr/local/nagios/var/$NAME.lock'
sudo sed -i '$ a DESC="Nagios"' $NAGIOS_PATH
sudo sed -i '$ a NAME=nagios' $NAGIOS_PATH
sudo sed -i "$ a $DEAMON_INSERT" $NAGIOS_PATH
sudo sed -i "$ a $DAEMON_ARGS_INSERT" $NAGIOS_PATH
sudo sed -i '$ a '$PIDFILE_INSERT'' $NAGIOS_PATH
}

apache_and_starting_apache () {
sudo chmod +x /etc/init.d/nagios
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
}

overall_install () {
    install_programs
    user_and_group_configuration
    download_extract_install_nagios
    even_hander_dir_copy
    intalling_nagios_plugins
    replace_a_line
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
Nagios version 4.2.0 for
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

