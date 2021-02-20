#!/bin/bash

echo "Hola $USER, please type your password"
read -s USER_PWD

 USER_UID=$(id -u)
 sudo apt-get install autofs

 # conpying configuration to /etc
 sudo cat ./auto.master >> /etc/auto.master
 sudo cp ./auto.nfs /etc/
 sudo sed -i "s/NORDIC_USER/`echo $USER`/g" /etc/auto.nfs
 sudo sed -i "s/NORDIC_UID/`echo $USER_UID`/g" /etc/auto.nfs

# copying credentials
 cp smbcredentials /home/$USER/.smbcredentials
 sed -i "s/NORDIC_USER/`echo $USER`/g" /home/$USER/.smbcredentials
 sed -i "s/NORDIC_PWD/`echo $USER_PWD`/g" /home/$USER/.smbcredentials
 chmod 600  /home/$USER/.smbcredentials

 # Creating folders for mapping, repeat for each map
 sudo mkdir /temp
 sudo chown $USER /temp

 echo "Reboot please"


