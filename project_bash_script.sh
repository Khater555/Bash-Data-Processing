#!/bin/bash

#  ===============================
# Error Handling settings
#  ===============================

set -euo pipefail



# ===============================
# Logging & Output Function 
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
# Input Validation Function
# ===============================

validate_input () {

    local input="$1"
    if [[ -z "$input" ]] ; then
        error "Invalid input: Input cannot be empty."
        return 1
    fi
        return 0

}

# ==============================
# Missing File
# ==============================

check_file(){

    local file="$1"

# 1. Check if file exists
    if [[ ! -e "$file" ]]; then
        error "File does not exist: $file"
        return 1
    fi

# 2. Check if it is a regular file
    if [[ ! -f "$file" ]]; then
        error "Not a regular file: $file"
        return 1
    fi

 # 3. Check if file is readable
    if [[ ! -r "$file" ]]; then
        error "ile is not readable:  $file"
        return 1
    fi

# 4. Check if file is empty
    if [[ ! -s "$file" ]]; then
        error "File is empty: $file"
        return 1
    fi

    success "File passed all validation checks: $file"
    return 0


}

# ==============================
# Missing Commands
# ==============================

check_command() {

    local command_named="$1"

    if ! command -v  "$command_named" >/dev/null 2>&1;then
        error "Command not found: $command_named"
        return 1
    fi

    success "Command available: $command_named"
    return 0
}
# ==============================
# Error Handling Trap
# ==============================
trap 'error "An unexpected error occurred."; exit 1' ERR
trap 'error "User interruption using Ctrl+C."; exit 130' INT

# ===============================
# Main Program
# ===============================