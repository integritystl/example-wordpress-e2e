#!/bin/bash
set -e

# Define colors for terminal output
ICYAN='\033[0;96m'
IRED='\033[0;91m'
NC='\033[0m'

# Clone the WordPress custom themes repository
echo -e "${ICYAN}Cloning${NC} example-wordpress-repo github repo..."
git clone git@github.com:integritystl/example-wordpress-repo.git
cd example-wordpress-repo
echo -e "${ICYAN}Installing${NC} example-wordpress-repo dependencies..."
npm install
cd ..

# Clone the API JavaScript functions repository
echo -e "${ICYAN}Cloning${NC} example-api-repo github repo..."
git clone git@github.com:integritystl/example-api-repo.git
cd example-api-repo/functions
echo -e "${ICYAN}Installing${NC} example-api-repo dependencies..."
yarn install
cd ../..

# Create and run the Docker containers
echo -e "${ICYAN}Starting${NC} docker containers..."
docker-compose up -d

# Install some container dependencies and WP-CLI
echo -e "${ICYAN}Installing${NC} wordpress cli..."
docker-compose exec -T wordpress /bin/bash -c "\
    apt-get update -q && apt-get install -y -q default-mysql-client \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
"

# Wait for the apt-get updating/downloading to finish
# TODO: Find a better way to do this - use until do; maybe...
sleep 6

# Setup the WordPress site info and admin user and password
echo -e "${ICYAN}Configuring${NC} wordpress admin..."
docker-compose exec -T wordpress /bin/bash -c "wp core install --url=localhost:8080 --title=e2e --admin_user=exampleuser --admin_password=examplepass --admin_email=exampleuser@example.com --allow-root"

# Activate all currently inactive Wordpress plugins
echo -e "${ICYAN}Activating${NC} all inactive WordPress plugins..."
docker-compose exec -T wordpress /bin/bash -c "wp plugin activate --all --allow-root" || echo -e "${IRED}WARNING:${NC} Failed to activate one or more plugins, continuing with the script..."

# Activate the WordPress custom theme
echo -e "${ICYAN}Activating${NC} my-custom-theme custom theme..."
docker-compose exec -T wordpress /bin/bash -c "wp theme activate my-custom-theme --allow-root"

# SSH into the staging WPEngine environment and create a database backup
echo -e "${ICYAN}SSHing${NC} into the WordPress server and creating a database backup..."
ssh wpengineuser@stagingsite.ssh.wpengine.net "\
    cd /sites/stagingsite \
    && wp db export backup.sql --force \
"

# Copy the staging database backup to the host machine/mapped docker volume
echo -e "${ICYAN}Copying${NC} staging database backup to host machine..."
scp -O wpengineuser@stagingsite.ssh.wpengine.net:/sites/stagingsite/backup.sql ./backups/backup.sql

# Import the staging database backup into the docker WordPress database
echo -e "${ICYAN}Importing${NC} staging database backup into docker WordPress database..."
docker-compose exec -T wordpress /bin/bash -c "wp db import /var/www/html/wp-content/backups/backup.sql --allow-root"

# Update database using wp-cli
echo -e "${ICYAN}Updating${NC} new database for Wordpress..."
docker-compose exec -T wordpress /bin/bash -c "wp core update-db --allow-root"

# Change the home and siteURL to localhost:8080 after importing the database
echo -e "${ICYAN}Changing${NC} site URL to localhost:8080..."
docker-compose exec -T wordpress /bin/bash -c "wp option update siteurl 'localhost:8080' --allow-root"
docker-compose exec -T wordpress /bin/bash -c "wp option update home 'localhost:8080' --allow-root"

# Search and replace URLs in WordPress content and settings
echo -e "${ICYAN}Updating${NC} URLs in the WordPress content and settings..."
docker-compose exec -T wordpress /bin/bash -c "wp search-replace 'https://stagingsite.wpengine.com' 'http://localhost:8080' --allow-root"

# Delete all Job and Recruiter custom post types completely and silently
echo -e "${ICYAN}Deleting${NC} all Job and Recruiter custom post types, silently..."
docker-compose exec -T wordpress /bin/bash -c "wp post delete \$(wp post list --post_type=job --field=ID --post_status=any --allow-root) --force --allow-root > /dev/null 2>&1 && echo 'Success: Deleted all '\''Job'\'' custom post types.'"
docker-compose exec -T wordpress /bin/bash -c "wp post delete \$(wp post list --post_type=recruiter --field=ID --post_status=any --allow-root) --force --allow-root > /dev/null 2>&1 && echo 'Success: Deleted all '\''Recruiter'\'' custom post types.'"

# Disable wordpress REST api authentication
echo -e "${ICYAN}Disabling${NC} REST api authentication..."
docker-compose exec -T wordpress /bin/bash -c "echo -e '\n/*' \
    '\n * Automagically authorize every request' \
    '\n * INSECURE! DANGER! ONLY USE IN LOCAL ENVIRONMENT.' \
    '\n */' \
    '\nadd_filter( \"rest_authentication_errors\", function(){' \
    '\n    wp_set_current_user( 1 ); // replace with the ID of a WP user with the authorization you want' \
    '\n}, 101 );' \
    '\n' >> ./wp-content/themes/my-custom-theme/functions.php
"

# Flush the cache
echo -e "${ICYAN}Flushing object cache${NC} so that WordPress is aware of all CLI changes..."
docker-compose exec -T wordpress /bin/bash -c "wp cache flush --allow-root"

exit 0
