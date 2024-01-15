#!/bin/bash
set -e

# Start time tracker
start_time=$(date +%s)

# Define colors for terminal output
ICYAN='\033[0;96m'
IPURPLE='\033[0;95m'
IGREEN='\033[0;92m'
IRED='\033[0;91m'
NC='\033[0m'

# Assert that user is running this script from the root directory
if [ ! -e "docker-compose.yml" ]; then
  echo -e "${IRED}Error:${NC} Please run invoke script from the project root directory (where docker-compose.yml is located)."
  exit 1
fi

# =======Prepare=======
# Kill any running processes on port 8080 and 3306
lsof -ti tcp:8080 | xargs kill
lsof -ti tcp:3306 | xargs kill

# Remove build directories
rm -rf memorial-health-jobs-rebuild
rm -rf memorial-health-functions
rm -rf backups

# Create empty backups directory
mkdir backups

# ======Build======
./scripts/build.sh
if [ $? -eq 0 ]; then
  echo -e "${IGREEN}✨  Success: Build completed.${NC}"
else
  echo "${IRED}Error:${NC} Build failed."
  exit 1
fi

# ======Run Job Import======
./scripts/run.sh
if [ $? -eq 0 ]; then
  echo -e "${IGREEN}✨  Success: Job Import completed.${NC}"
else
  echo "${IRED}Error:${NC} Job Import failed."
  exit 1
fi

# ======Run API/iCIMS Tests======
./scripts/icims.sh
if [ $? -eq 0 ]; then
  echo -e "${IGREEN}✨  Success: iCIMS Endpoint Tests completed.${NC}"
else
  echo "${IRED}Error:${NC} iCIMS Endpoint Tests failed."
  exit 1
fi

# ======Run E2E Tests======
./scripts/e2e.sh
if [ $? -eq 0 ]; then
  echo -e "${IGREEN}✨  Success: End-to-end Tests completed.${NC}"
else
  echo "${IRED}Error:${NC} End-to-end Tests failed."
  exit 1
fi

# =======Time Reporting=======
# End time tracker
end_time=$(date +%s)

# End time tracker
elapsed_time=$((end_time - start_time))

# Calculate elapsed time
minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))

echo -e "${ICYAN}Total execution time:${NC} $minutes minutes and $seconds seconds."

# =======Safe Exit=======
exit 0
