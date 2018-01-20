#!/bin/bash

#clear the screen
clear

#update and upgrade
apt-get -y update
apt-get -y upgrade

#firewall
ufw enable
ufw deny 22
ufw deny 23
ufw deny 2049
ufw deny 515
ufw deny 111
ufw deny 102

#antivirus
apt-get -y install clamav
freshclam
clamscan
apt-get -y autoremove

#uninstall software
apt-get -y purge apache2
apt-get -y purge nginx
apt-get -y purge hydra
apt-get -y purge netcat

#guest account
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf

#password age
sed -i '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS 90' /etc/login.defs
sed -i '/^PASS_MIN_DAYS/ c\PASS_MIN_DAYS 10' /etc/login.defs
sed -i '/^PASS_WARN_AGE/ c\PASS_WARN_AGE 7' /etc/login.defs

#strong passwords
apt-get -y install libpam-cracklib
sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password

#password authentication
sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' etc/pam.d/common-auth

#disable root
sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config

#lock out root
passwd -l root 

#audit
apt-get -y install auditd

#updating FIREFOX
add-apt-repository -y ppa:ubuntu-mozilla-security/ppa
apt-get -y install firefox
