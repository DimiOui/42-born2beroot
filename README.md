# born2beroot
born2beroot  - 42 Paris - December 2021
# Files to turn in

```
shasum born2beroot.vdi | awk '{print $1}'> signature.txt
```
Turn in the signature.txt

Make sure to snapshot your VM before you turn in your signature file :)

# To setup a viable 42 Virtual Machine, follow these steps :

 - Make sure VirtualBox is installed on the current system and download the latest debian disk image
 - Create a new Virtual Machine - Linux - Debian 64Bits - 1Go RAM - create VDI - Dynamically allocated - 8GB
 (Make sure to install your VM in sgoinfre folder if your working from a school computer)
 - Download a Debian stable distribution iso from the internet (debian-XX.X.X-amd64-netinst.iso)
 - Settings > Storage > IDE > Optical Drive (select Debian iso)
 - Run your VM and run install
 - Continue until configuring the hostname (login42), domain name (empty), username (login)

# Partitioning your virtual disk :

### Manual partitioning
- Select SCI2/SCI3 (0,0,0)
- Select pri/log > create new partition, 500 MB, primary, beginning, ext4, /boot, done
- Select pri/log > create new partition, max, logical, do not mount it, done

### Configure encrypted volumes
- Yes, create encrypted volumes, /dev/sda5, done, finish, yes (you can cancel the encryption if you desire)
- Enter the encryption passphrase (btw, do not lose any of your pwd, passphrases)

### Configure the LVM (Logical Volume Manager)
- Chose yes
- Create Volume Group, LVMGroup, sda5_crypt
- Create Logical Volume :
```
 1. root      2GB       ext4    /(root)
 2. swap      1024MB    swap
 3. home      1GB       ext4    /home
 4. var       1GB       ext4    /var
 5. srv       1GB       ext4    /srv
 6. tmp       1GB       ext4    /tmp
 7. var-log   1056MB    ext4    /var/log (manually)
```
- Done setting up the partition, write changes (yes), scan another CD or DVD (no), Debian archive mirror (France), proxy info (none), survey (no)
- Uncheck SSH server and Standard System utilities, install GRUB (yes), /dev/sda (continue)

Congrats, your VM is all set and ready to run.

# List of tasks to be done after setting up the VM (details below the list) :

1. sudo apt install sudo
2. sudo apt install vim
3. sudo apt install openssh-server
4. sudo apt install ufw
5. sudo apt install apparmor
6. sudo apt install libpam-pwquality
7. sudo apt install lighttpd (bonus)
8. sudo apt install mariadb-server (bonus)
9. sudo apt install php-cgi php-mysql (bonus, sudo mysql_secure_installation)
10. sudo apt install wget (bonus)
11. sudo apt install mailutils
12. sudo apt install postfix

Copy all the repo files in these directories :

### Ssh config file (disable root login, change port to 4242)
sshd_config (/etc/ssh/sshd_config)

You have to portforward your VM in VirtualBox > Settings > Network > Advanced

### Password policy config file
common-password (/etc/pam.d/common-password)

More on this below.

### Sudo rules
dpaccagn_sudo_config (/etc/sudoers.d/dpaccagn_sudo_config)

More on this below.

### Password expiration
login.defs (/etc/login.defs)

More on this below.

### Cron
monitoring.sh (/root/monitoring.sh)

MAKE SURE TO MODIFY CRONTAB WITH ```sudo crontab -u root -e``` and ```*/10 * * * * sh /root/monitoring.sh | wall```
```
crontab -l to check crontab tasks
crontab -r to delete tasks
crontab -e to edit
```

All is well ? Okay, now let's carry on.

# Debian Terminal tweaks

### Sudo log dir

```
sudo mkdir /var/log/sudo
sudo touch /var/log/sudo/sudo.log
sudo chmod 755 /var/log/sudo
sudo chmod 755 /var/log/sudo/sudo.log
```

### UFW

```
sudo ufw enable
sudo ufw allow 4242
```

### Pwd Policy

```
chage -M 30 -m 2 -W 7 username
chage -M 30 -m 2 -W 7 root
# Remember to update your user & root password
# To check wether pwd policies are active, check login.defs or chage -l username/root
```

# Bonus Wordpress

```
#install lighttpd, mariadb-server and ufw allow 80 to open ports
sudo mysql_secure_installation
set no password
sudo mariadb
[(none)]CREATE DATABASE wordpress;
[(none)]GRANT ALL ON wordpress.* TO 'root'@'localhost' IDENTIFIED BY ''(this is 2 single quotes) WITH GRANT OPTION;
[(none)]FLUSH PRIVILEGES;
[(none)]exit

# check your database with mariadb -u root -p SHOW DATABASES;

sudo apt install php-cgi php-mysql
sudo apt install wget
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html

#extract tar and copy everything into /var/www/html and create the WP config file from its sample

sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#change these lines

'DB_NAME', 'wordpress';
'DB_USER', 'root';
'DB_PASSWORD', '';

sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
sudo vim /etc/lighttps/lighttpd.conf 
# add "mod_rewrite", to the top of the file
sudo systemctl restart lighttpd.service
```
Now you can portforward your VM, open a webpage and put 127.0.0.1:XXXX, your wordpress page awaits you :)

# Bonus Mailbox

```
sudo apt install mailutils
sudo apt install postfix (chose internet)
systemctl status postfix
echo "Mail body" | mail -s "subject" address@mail.com
cd /var/log
sudoo cat mail.log
```

# Defense

### how a virtual machine works and its purpose
Do I really need to explain it to you guys ?

### why chosing Debian over CentOS
Debian is fully opensource, more portable

CentOS has 10 years long support for each releases

CentOS is more stable than Debian, although Ubuntu is catching up and more packages avalaible

Debian is easier to upgrade, GUI is more friendly

CentOS doesn't support many architectures

### what's the difference between aptitude and apt
Aptitude provides a terminal menu interface, apt doesn't

They share the same database of packages

Aptitude will automatically remove packages

Aptitude will provide solutions if you try to remove/install/update packages that cause conflicts

### what APPARMOR is
Apparmor is a firewall, the idea is to lock down an app and the files to be accessed with absolute path names,
followed by the common read/write accesss modes

### how to view the partitions in the system
```lsblk```

### how LVM works
More flexible than traditional partitioning, virtual disk partitions

### Explain the password policy
Sudo is configured with strict rules :
- 3 attempts to get the PW right
- custom message when the PW is wrong
- each sudo cmd is archived in /var/log/sudo/sudo.log
TTY : https://stackoverflow.com/questions/67985925/why-would-i-want-to-require-a-tty-for-sudo-whats-the-security-benefit-of-requi
```login.defs``` rules :
- expire every 30 days
- warning 7 days before expiration
- minimum of 2 days before allowing to change PW
```common-password``` policies :
- at least 10 characters long
- one uppercase letter, one lowercase, one digit
- no more than 3 retries
- can't include username
- no more than 3 identical characters in a row
- at least 7 characters different from old PW

### how to add a user 
```
sudo adduser <user>
#to delete use
sudo deluser <user>
#to see list of user
cat /etc/passwd
```

### how to add a group
```
sudo addgroup <group>
#to delete use
sudo delgroup <group>
```

### how to add that user to a group
```
sudo adduser <user> <group>
getent group sudo
#to delete use
sudo deluser <user> <group>
#to change users
su <login> or su - for root
```

### how to ssh a session with that user
```ssh user@127.0.0.1 -p 2222```
 
### how to change the hostname
```
hostnamectl set-hostname <hostname>
modify /etc/hosts
```
 
### how to add a rule to UFW
```
ufw allow rule
ufw status
#to delete use
ufw delete <rule number>
```
 
### how to show the changes you made
```
# See all the repo files
```
### how to show your monitoring script
```/monitoring.sh```

### explain how it works

### what is MariaDB, lighttpd and php

MariaDB and Mysql are server database ressources to manage webservers.

MariaDB is a fork of Mysql.

Lighttpd is a lightweght web server.

Php is a general-purpose scripting language that can be used to develop dynamic and interactive websites. 

# Usefull commands

```
who
hostname
ip a
uname -a
chage -l <user>
ssh -V
sudo sysstemctl list-unit-files | grep enabled | grep ssh
sudo crontab -u root -l
aa-status
ss -tunlp
readlink -f <file>
sudo passwd <user>
```
