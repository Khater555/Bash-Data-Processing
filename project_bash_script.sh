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
        error "File is not readable:  $file"
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
# 6.1 Count Lines Function
# ==============================

count_lines(){

    local file="$1"

    if ! check_file "$file"; then
        return 1
    fi

    info "counting lines in file: $file"

    local line_count=$(wc -l < "$file")

    success "Line count for file '$file': $line_count"

    return 0

}

# ==============================
# Extract Columns Function
# =============================

extract_columns() {
    local file="$1"
    local columns="$2"

    # Validate file
    if ! check_file "$file"; then
        return 1
    fi

    # Validate column numbers format
    if [[ ! "$columns" =~ ^[1-9][0-9]*(,[1-9][0-9]*)*$ ]]; then
        error "Invalid column numbers: $columns"
        return 1
    fi

    # Get total number of columns
    local total_columns
    total_columns=$(awk -F',' 'NR == 1 { print NF; exit }' "$file")

    # Check requested columns
    local column
    local -a selected_columns
    IFS=',' read -r -a selected_columns <<< "$columns"

    for column in "${selected_columns[@]}"; do
        if (( column > total_columns )); then
            error "Column number $column does not exist."
            return 1
        fi
    done

    info "Extracting columns $columns from $file"

    awk -F',' -v cols="$columns" '
        BEGIN {
            count = split(cols, selected, ",")
        }
        {
            for (i = 1; i <= count; i++) {
                printf "%s", $selected[i]
                if (i < count) printf ","
            }
            printf "\n"
        }
    ' "$file"

    success "Columns extracted successfully."

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
# filter Data Function
# ==============================

filter_data() {
    local file="$1"
    local pattern="$2"

    # Validate file
    if ! check_file "$file"; then
        return 1
    fi

    # Validate pattern
    if [[ -z "$pattern" ]]; then
        error "Search pattern cannot be empty."
        return 1
    fi

    info "Filtering data in $file using pattern: $pattern"

    local result

    if result=$(grep -E -- "$pattern" "$file"); then
        echo "$result"
        success "Matching records found."
    else
        local status=$?

        if [[ "$status" -eq 1 ]]; then
            warning "No matching records found."
        else
            error "An error occurred while filtering data."
            return 1
        fi
    fi

    return 0
}

# ==============================
# calculate Stats Function
# ==============================

calculate_stats() {
    local file="$1"

    # Validate file
    if ! check_file "$file"; then
        return 1
    fi

    info "Calculating statistics from $file"

    local stats

    if ! stats=$(awk -F',' '
        BEGIN {
            count = 0
            sum = 0
        }
        {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^-?[0-9]+([.][0-9]+)?$/) {
                    value = $i
                    count++
                    sum += value

                    if (count == 1 || value < min)
                        min = value

                    if (count == 1 || value > max)
                        max = value
                }
            }
        }
        END {
            if (count == 0)
                exit 1

            printf "%d %g %g %.1f\n", count, min, max, sum / count
        }
    ' "$file"); then
        warning "No valid numeric data found."
        return 1
    fi

    local count minimum maximum average
    read -r count minimum maximum average <<< "$stats"

    echo "Statistics"
    echo "----------------"
    echo "Count   : $count"
    echo "Minimum : $minimum"
    echo "Maximum : $maximum"
    echo "Average : $average"

    success "Statistics calculated successfully."

    return 0
}
# ==============================
# merge Files Function
# ==============================


merge_files() {
    # Check number of input files
    if (( $# < 2 )); then
        error "At least two input files are required."
        return 1
    fi

    local file
    local output_file="output/merged.txt"

    # Validate all input files
    for file in "$@"; do
        if ! check_file "$file"; then
            error "Merge operation cancelled."
            return 1
        fi
    done

    # Create output directory
    if ! mkdir -p output; then
        error "Failed to create output directory."
        return 1
    fi

    info "Merging input files..."

    # Combine all files into one output file
    if ! cat -- "$@" > "$output_file"; then
        error "Failed to merge files."
        return 1
    fi

    success "Files merged successfully: $output_file"

    return 0
}

# ============================
# Deduplicate Files Function
# ============================

deduplicate() {
    local file="$1"

    # Validate input file
    if ! check_file "$file"; then
        return 1
    fi

    # Get input filename
    local filename="${file##*/}"
    local output_file="output/$filename"

    # Create output directory
    if ! mkdir -p output; then
        error "Failed to create output directory."
        return 1
    fi

    info "Removing duplicate lines from $file"

    # Count original lines
    local original_lines
    original_lines=$(wc -l < "$file")

    # Remove duplicate lines
    if ! awk '!seen[$0]++' "$file" > "$output_file"; then
        error "Failed to remove duplicate lines."
        return 1
    fi

    # Count unique lines
    local unique_lines
    unique_lines=$(wc -l < "$output_file")

    # Calculate duplicates
    local duplicates=$((original_lines - unique_lines))

    success "Original lines: $original_lines"
    success "Unique lines: $unique_lines"
    success "Duplicates removed: $duplicates"

    return 0
}

# ==============================
# Command Exists Function
# ==============================

command_exists() {
    local command_line="$1"

    if command -v "$command_line" > /dev/null 2>&1; then
        success "$command_line is installed."
        return 0
    else
    error "$command_line is not installed."
        return 1
    fi
}

# ==============================
# Check Dependencies Function
# ==============================

check_dependencies() {
    info "Checking dependencies..."

    local commands=("awk" "grep" "wc" "cat" "mkdir" "date")
    local command_name
    local missing=0

    for command_name in "${commands[@]}"; do
        if command -v "$command_name" >/dev/null 2>&1; then
            success "$command_name found."
        else
            error "Required command '$command_name' not found."
            missing=1
        fi
    done

    if (( missing == 1 )); then
        error "Some required dependencies are missing."
        return 1
    fi

    success "All required dependencies are available."
    return 0
}


# ==============================
# Init Directories Function
# ==============================

init_directories() {
    info "Initializing directories..."

    local directories=("data" "output" "logs")
    local directory

    for directory in "${directories[@]}"; do
        if ! mkdir -p "$directory"; then
            error "Failed to create directory: $directory"
            return 1
        fi
    done

    success "Required directories are ready."
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


while true; do
    echo "========================================"
    echo "     Bash Data Processing Toolkit"
    echo "========================================"
    echo "1. Count Lines"
    echo "2. Extract CSV Columns"
    echo "3. Filter Data"
    echo "4. Calculate Statistics"
    echo "5. Merge Files"
    echo "6. Remove Duplicates"
    echo "7. Check Dependencies"
    echo "8. Initialize Directories"
    echo "9. Exit"
    echo "========================================"

    read -rp "Choose an option: " choice

    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        error "Invalid option. Please enter a number between 1 and 9."

    elif (( choice < 1 || choice > 9 )); then
        error "Invalid choice."

    else
        case "$choice" in
            1)
                count_lines "data/data.txt" || true
                ;;
            2)
                extract_columns "data/data.csv" 1,2 || true
                ;;
            3)
                filter_data "data/data.txt" "Linux" || true
                ;;
            4)
                calculate_stats "data/data.csv" || true
                ;;
            5)
                merge_files "data/data.txt" "data/sample.txt" || true
                ;;
            6)
                deduplicate "data/data.txt" || true
                ;;
            7)
                check_dependencies || true
                ;;
            8)
                init_directories || true
                ;;
            9)
                success "Exiting Bash Data Processing Toolkit."
                break
                ;;
        esac
    fi

    echo
    read -rp "Press Enter to continue..."
    clear
done
