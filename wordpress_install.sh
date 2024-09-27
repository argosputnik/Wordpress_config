#!/usr/bin/bash

# Check if MySQL is running
if ! pgrep -x "mysqld" > /dev/null; then
    echo "MySQL server is not running."
    exit 1
fi

echo "MySQL Username:"
read mysql_user

echo "MySQL Password:"
read -s mysql_pass

echo "Database Name:"
read db_name

# Using MySQL command and checking the return status
mysql -u"$mysql_user" -p"$mysql_pass" <<EOF
CREATE DATABASE IF NOT EXISTS $db_name; 
USE $db_name;
CREATE USER IF NOT EXISTS 'jai'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON $db_name.* TO 'jai'@'localhost';
FLUSH PRIVILEGES;
EOF

# Check the result of the MySQL commands
if [ $? -eq 0 ]; then 
    echo "Database '$db_name' and privileges have been created successfully!"
else
    echo "Failed to create database."
    exit 1  # Exit if MySQL commands fail
fi

# Download WordPress
curl -o wordpress-latest.tar.gz https://wordpress.org/latest.tar.gz

# Check if the download was successful
if [ $? -eq 0 ]; then 
    echo "WordPress downloaded successfully!"
else
    echo "Failed to download WordPress."
    exit 1  # Exit if the download fails
fi

# Create the directory for WordPress
sudo mkdir -p /var/www/html/remoteworkers

# Extract the WordPress tarball
sudo tar -xzf wordpress-latest.tar.gz -C /var/www/html/remoteworkers

# Check if the extraction was successful
if [ $? -eq 0 ]; then 
    echo "WordPress extracted successfully!"
else
    echo "Failed to extract WordPress."
    exit 1  # Exit if the extraction fails
fi

# Optional: Clean up the downloaded tarball
#rm wordpress-latest.tar.gz
