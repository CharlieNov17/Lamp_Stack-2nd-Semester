Automation of LAMP (Linux, Apache, MySQL, PHP) stack deployment using a Bash Script in Ansible

1. Created and provisioned two vagrant virtual machines (master and slave). Below is the configuration of their vagrantfiles. The configuration had the ip addresses of my machines and disabling of the ssh insert key 
![image1](/screenshots/1.png)


2.  Created public keys in both machines and had them saved to enable connection between both machines. i.e the public key of master's machine was saved in the authorized key of the slave machine and vice versa. I generated the key using the command
![image2](/screenshots/2.png)

ssh-keygen

3. Encountered some issues initally ssh into the slave from the master however, it was resolved by copying the keys and changing the permission on the slave node
![image3](/screenshots/3.png)

4. installed ansible using sudo apt install ansible -y
![image4](/screenshots/4.png)

5. created an inventory file in the Ansible directory created, saved the slave address in it and pinged to verify connectivity using ansible all -m ping -i inventory
![image5](/screenshots/5.png)

6. created a script Lamp.sh which contained intstallation and configuration of all dependencies for the LAMP (Linux, Apache, MySQL and PHP) stack script
![image6](/screenshots/6.png)
   
    A reusable script is a piece of code that is designed to be easily used in multiple contexts or scenarios without modification. It should be well-structured, modular, and customizable to fit different use cases.


:Script content.


`#!/bin/bash
#update your repositories
sudo apt update

#upgrade your missing packages
sudo apt upgrade -y
echo "Packages Upgraded"

#install your apache webserver
sudo apt install apache2 -y

#add the php ondrej repository
echo -e "\n" | sudo add-apt-repository ppa:ondrej/php

#update your repositories
sudo apt update

#install php8.2
sudo apt install php8.2 -y

#install php dependencies that are needed for laravel to work
sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

#enable the apache rewrite module
sudo a2enmod rewrite

#restart the apache server
sudo systemctl restart apache2

#Install Git
sudo apt install git -y
echo "Git complete"

#change directory to /usr/bin
cd /usr/bin

#download the composer installer
install composer
sudo curl -sS https://getcomposer.org/installer | sudo php

#move the content of the default composer.phar to composer
sudo mv composer.phar composer

#change directory in /var/www directory for cloning laravel
cd /var/www/
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R $USER:$USER /var/www/laravel
cd laravel/
install composer autoloader --no-interaction
composer install --optimize-autoloader --no-dev --no-interaction  
composer update --no-interaction

#copy the content of the default env file to .env and assign permissions
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache
cd
cd /etc/apache2/sites-available/
sudo touch new.conf
sudo echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/new.conf
sudo a2ensite new.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
cd
# Install MySQL and create the Database
sudo apt install mysql-server -y
sudo apt install mysql-client -y
echo "MySQL COMPLETE"

sudo systemctl start mysql
sudo mysql -uroot -e "CREATE DATABASE Altschool_DB;"
sudo mysql -uroot -e "CREATE USER 'chibuzo'@'localhost' IDENTIFIED BY 'batman';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON Altschool_DB.* TO 'chibuzo'@'localhost';"
cd /var/www/laravel
sudo sed -i "23 s/^#//g" /var/www/laravel/.env
sudo sed -i "24 s/^#//g" /var/www/laravel/.env
sudo sed -i "25 s/^#//g" /var/www/laravel/.env
sudo sed -i "26 s/^#//g" /var/www/laravel/.env
sudo sed -i "27 s/^#//g" /var/www/laravel/.env
sudo sed -i '22 s/=sqlite/=mysql/' /var/www/laravel/.env
sudo sed -i '23 s/=127.0.0.1/=localhost/' /var/www/laravel/.env
sudo sed -i '24 s/=3306/=3306/' /var/www/laravel/.env
sudo sed -i '25 s/=laravel/=Altschool_DB/' /var/www/laravel/.env
sudo sed -i '26 s/=root/=chibuzo/' /var/www/laravel/.env
sudo sed -i '27 s/=/=batman/' /var/www/laravel/.env
sudo php artisan key:generate --no-interaction
sudo php artisan storage:link --no-interaction
sudo php artisan migrate --no-interaction
sudo php artisan db:seed --no-interaction
sudo systemctl restart apache2

uptime > /var/log/uptime.log`


snippet of the script
![image7](/screenshots/7.png)


7. Created the playbook and automated the script in it 

`---
- hosts: all
  become: yes
  tasks:
    - name: Change the User of script
      copy:
        src: /home/vagrant/Ansible_Laravel_Exam/Lamp.sh
        dest: /home/vagrant/Lamp.sh
        mode: 0755

    - name: install LAMP stack
      shell: ./Lamp.sh
 
    - name: Add cron job for system uptime
      cron:
        name: "system uptime"
        minute: "0"
        hour: "0"
        job: "uptime >> /home/vagrant/uptime.log"
        
    - name: Check if application homepage is accessible
      uri:
        url: "http://192.168.44.22"
        method: GET
      register: homepage_response

    - name: Assert that homepage returns HTTP 200 OK
      assert:
        that: homepage_response.status == 200
        fail_msg: "Homepage is not accessible"
        success_msg: "Homepage is accessible"`

![image8](/screenshots/8.png)

![image9](/screenshots/9.png)
playbook ran suceccfully error free 
![image10](/screenshots/10.png)




