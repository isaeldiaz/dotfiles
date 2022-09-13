#/bin/bash

# https://serverfault.com/questions/1051118/how-to-remote-access-virtualbox-on-a-headless-linux-server/1051119#1051119
#create a non-root user to run the vbox-web service
#add the user to the right groups for Virtualbox and PAM
#modify the systemd unit file, w/r to the executable, the user and the location of the pidfile
#create a user

#Create a non-root user, with a home directory and no login capabilities
adduser --home /home/virtual --shell /bin/false --ingroup vboxusers --disabled-password--disabled-login virtual
#Add the user to the shadow group. The user's primary group needs to be vboxusers. In order to allow the web services to authenticate against PAM it can - at least on debian systems such as debian, ubuntu or mint, be made a member of the shadow group.
usermod -a -G shadow virtual


#modify the systemd unit file
#The unit file needs to have the following content:

#[Unit]
#Description=Virtual Box Web Service
#After=network.target


#[Service]
#Type=forking
#User=virtual
#Group=vboxusers
#ExecStart=/usr/bin/vboxwebsrv --pidfile /home/virtual/vboxweb.pid --host=0.0.0.0 --background
#PIDFile=/home/virtual/vboxweb.pid


#[Install]
#WantedBy=multi-user.target
#So rather than calling the start batch script, we call the executable directly. The options indicate the location of the pidfile as well as the interface it binds to (in the example this is 0.0.0.0, so any interface).
