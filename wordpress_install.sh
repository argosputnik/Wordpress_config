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
mkdir -p /var/www/html/

# Extract the WordPress tarball
tar -xzf wordpress-latest.tar.gz -C /var/www/html/

# Check if the extraction was successful
if [ $? -eq 0 ]; then 
    echo "WordPress extracted successfully!"
else
    echo "Failed to extract WordPress."
    exit 1  # Exit if the extraction fails
fi

# Optional: Clean up the downloaded tarball
rm wordpress-latest.tar.gz

chmod 775 /var/www/html/wordpress
chmod o+w /var/www/html/wordpress

cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

chmod 666 /var/www/html/wordpress/wp-config.php
chmod ugo+x /var/www/html/wordpress/wp-config.php


sed -i "0,/database_name_here/s/database_name_here/${db_name}/" /var/www/html/wordpress/wp-config.php


sed -i "0,/username_here/s/username_here/${mysql_user}/" /var/www/html/wordpress/wp-config.php

sed -i "0,/password_here/s/password_here/${mysql_pass}/" /var/www/html/wordpress/wp-config.php


# Ask the user if they want to change the name of the wordpress folder
echo "Do you want to rename the WordPress folder?"
echo "1. Yes"
echo "2. No, use the default 'wordpress' folder"
read -p "Select an option (1 or 2): " choice

if [ "$choice" == "1" ]; then
    # Ask the user for the new folder name
    read -p "Enter the new name for the WordPress folder: " new_folder_name
    
    # Check if the folder exists and rename it
    if [ -d "/var/www/html/wordpress" ]; then
        mv /var/www/html/wordpress /var/www/html/"$new_folder_name"
        echo "The folder has been renamed to '$new_folder_name'."
        
        # Launch the browser with the new folder name
        xdg-open "http://localhost/$new_folder_name" >/dev/null 2>&1
        echo "Launching http://localhost/$new_folder_name"
    else
        echo "WordPress folder not found. Please ensure it's correctly installed."
        exit 1
    fi
elif [ "$choice" == "2" ]; then
    # Launch the default wordpress folder
    xdg-open "http://localhost/wordpress/wp-admin/install.php" >/dev/null 2>&1
    echo "Launching http://localhost/wordpress"
else
    echo "Invalid option. Please choose 1 or 2."
    exit 1
fi

