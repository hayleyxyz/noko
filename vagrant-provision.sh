# This script is run (privileged) on the vagrant guest after running "vagrant up" for the first time.
# It will:
# * Install required packages
# * Install composer
# * Update OS hostname
# * Add apache vhost for this application and update any other required config
# * Create the mysql database
# * Generate a .env config file for the application and run other required tasks
#
# You can set this script to run by modifying your Vagrantfile as follows,
# changing the "args" parameter to suit your project:
#
#    config.vm.provision "shell" do |s|
#        s.path = "vagrant-provision.sh"
#        s.args = [
#            "noko-vm", # Hostname
#            "noko" # DB name
#        ]
#    end

# Project-specific variables (from arguments)
NEW_HOSTNAME=$1
MYSQL_DB=$2
MYSQL_PASSWORD=$3

# Set defaults if arguments are not set or empty
if [ -z "$NEW_HOSTNAME" ]; then NEW_HOSTNAME="jessie64"; fi
if [ -z "$MYSQL_DB" ]; then MYSQL_DB="vagrant"; fi
if [ -z "$MYSQL_PASSWORD" ]; then MYSQL_PASSWORD="vagrant"; fi

# Set mysql password upfront to disable prompt from asking while installing mysql-server package
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"

# Install packages
apt-get update
apt-get -y install apache2 php5 php5-mysql php5-mcrypt php5-curl mysql-server curl

# Install composer
curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin

# Install rocketeer
# wget http://rocketeer.autopergamene.eu/versions/rocketeer.phar -O /usr/local/bin/rocketeer
# chmod +x /usr/local/bin/rocketeer

# Update hostname
# TODO: check this is the proper way
echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
echo "$NEW_HOSTNAME" > /etc/hostname
hostname -F /etc/hostname

# Set ServerName directive on apache globally to suppress warnings on start
echo "ServerName $(hostname)" > /etc/apache2/conf-available/server-name.conf
a2enconf server-name

# Run "composer install" on application folder
cd /vagrant
composer install

# Enable apache modules
a2enmod rewrite

# Add apache vhost config for application
cat << 'EOF' > /etc/apache2/sites-available/vagrant.conf
<VirtualHost *:80>
    DocumentRoot /vagrant/public

    <Directory /vagrant/public>
        Require all granted

        RewriteEngine On

        # Redirect Trailing Slashes If Not A Folder...
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)/$ /$1 [L,R=301]

        # Handle uploaded files
        RewriteCond /vagrant/storage/uploads/$1 -f
        RewriteRule (.*) /uploads/$1 [L]

        # Handle Front Controller...
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^ index.php [L]
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Disable the default apache vhost and enable our new one
a2dissite 000-default
a2ensite vagrant

# Add www-data user to the vagrant group
# Allows access to /vagrant shared mount
usermod --append --groups vagrant www-data

# Reload changes
apache2ctl -k restart

# Set mysql client creds for automatic login
tee > ~vagrant/.my.cnf <<EOF
[client]
user=root
password=$MYSQL_PASSWORD
EOF

# Update owner and remove access for other users
chmod go-rwx,u-x ~vagrant/.my.cnf
chown vagrant:vagrant ~vagrant/.my.cnf

# Create DB
# Run as vagrant user so it uses the user's .my.cnf
sudo -u vagrant mysql -e "CREATE DATABASE $MYSQL_DB"

# Set .env
replace "DB_DATABASE=homestead" "DB_DATABASE=$MYSQL_DB" \
    "DB_USERNAME=homestead" "DB_USERNAME=root" \
    "DB_PASSWORD=secret" "DB_PASSWORD=$MYSQL_PASSWORD" < /vagrant/.env.example > /vagrant/.env

# Application setup
cd /vagrant
php artisan migrate
php artisan key:generate
