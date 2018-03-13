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

useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagios,nagcmd www-data
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

make all
sudo make install
sudo make install-commandmode
sudo make install-init
sudo make install-config
/usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf

}

even_hander_dir_copy () {

cat << EOF
#############################
copying and changing ownership
of directories
#############################
EOF

    cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
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
cd nagios-plugin-2.1.2/
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
make install
}

overall_install () {
    install_programs
    user_and_group_configuration
    download_extract_install_nagios
    even_hander_dir_copy
    intalling_nagios_plugins
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