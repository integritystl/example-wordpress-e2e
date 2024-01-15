#!/bin/bash
set -e

# Define colors for terminal output
ICYAN='\033[0;96m'
IPURPLE='\033[0;95m'
IGREEN='\033[0;92m'
IRED='\033[0;91m'
NC='\033[0m'

# Build the project
echo -e "${ICYAN}Building${NC} e2e project..."
yarn install

# Run the project
echo -e "${ICYAN}Running${NC} e2e project..."
yarn e2e-tests

exit 0
