#!/bin/bash
set -e

# Define colors for terminal output
ICYAN='\033[0;96m'
IPURPLE='\033[0;95m'
IGREEN='\033[0;92m'
IRED='\033[0;91m'
NC='\033[0m'

# Run the iCIMS tests
echo -e "${ICYAN}Running${NC} iCIMS endpoint tests..."
cd example-api-repo/functions
yarn test
cd ../..

exit 0
