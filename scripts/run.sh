#!/bin/bash
set -e

# Define colors for terminal output
ICYAN='\033[0;96m'
IPURPLE='\033[0;95m'
IGREEN='\033[0;92m'
IRED='\033[0;91m'
NC='\033[0m'

# Create .env file to include e2e pre-requisites:
#   DEBUG=true
#   MOCK_DATA=true
#   WP_BASE_URL=http://localhost:8080/wp-json/wp/v2
echo -e "${ICYAN}Creating${NC} env file..."
ENV_CONTENT=$(cat <<EOF
DEBUG=true
MOCK_DATA=true
WP_BASE_URL=http://localhost:8080/wp-json/wp/v2
WP_APPLICATION_USER_NAME=override
WP_APPLICATION_USER_PASSWORD=override

ICIMS_USER_NAME=realUserName
ICIMS_USER_PASSWORD=realSecretPassword123!

FUNCTIONS_PROJECT_IDENTIFIER="123abc-uc.a.run.app"

EOF
)
echo "$ENV_CONTENT" > example-api-repo/functions/.env

# Build the project
echo -e "${ICYAN}Building${NC} Job Import project..."
cd example-api-repo/functions && yarn build && cd ../..

# Run the project
echo -e "${ICYAN}Running${NC} Job Import..."
cd example-api-repo/functions && node lib && cd ../..

exit 0
