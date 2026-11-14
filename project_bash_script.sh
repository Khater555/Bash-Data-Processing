#!/bin/bash

# ===============================
# Logging # Output Function 
# ===============================

info() {

    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [INFO] $message"

    local BLUE='\033[0;34m'
    local NC='\033[0m' # No Color

    echo -e "${BLUE}${log_entry}${NC}"
    echo "$log_entry" >> logs/project.log

}

success() {

    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [SUCCESS] $message"

    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color

    echo -e "${GREEN}${log_entry}${NC}"
    echo "$log_entry" >> logs/project.log

}

warning() {

    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [WARNING] $message"

    local YELLOW='\033[0;33m'
    local NC='\033[0m' # No Color

    echo -e "${YELLOW}${log_entry}${NC}"
    echo "$log_entry" >> logs/project.log

}

error() {

    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [ERROR] $message"

    local RED='\033[0;31m'
    local NC='\033[0m' # No Color

    echo -e "${RED}${log_entry}${NC}"
    echo "$log_entry" >> logs/project.log


}

# ===============================
# Main Program
# ===============================

info "Starting data processing..."
success "File processed successfully."
warning "File contains empty values."
error "File not found."