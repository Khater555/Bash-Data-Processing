
# Bash Data Processing & Automation Toolkit

## Description

Bash Data Processing & Automation Toolkit is a Linux-based shell scripting project designed to automate common file and data processing operations.

The toolkit provides an interactive menu that allows users to count lines, extract CSV columns, filter data, calculate statistics, merge files, remove duplicate lines, check system dependencies, and initialize project directories.

The project focuses on practical Bash scripting concepts, automation, input validation, and error handling.

## Requirements

The project requires:

- Linux operating system
- Bash
- awk
- grep
- wc
- cat
- mkdir
- date

## Installation

Clone the repository:

```bash
git clone https://github.com/Khater555/Bash-Data-Processing.git
```

Navigate to the project directory:

```bash
cd Bash-Data-Processing
```

Give the script execute permission:

```bash
chmod +x project_bash_script.sh
```

## Usage

Run the script:

```bash
./project_bash_script.sh
```

The interactive menu provides the following operations:

1. Count Lines
2. Extract CSV Columns
3. Filter Data
4. Calculate Statistics
5. Merge Files
6. Remove Duplicates
7. Check Dependencies
8. Initialize Directories
9. Exit

Choose an option to execute the corresponding operation.

## Functions

### 1. `count_lines()`
Counts the total number of lines in a specified file.

### 2. `extract_columns()`
Extracts selected columns from a CSV file using `awk`.

### 3. `filter_data()`
Searches for lines matching a specified pattern using `grep`.

### 4. `calculate_stats()`
Calculates basic statistics for numeric data, including minimum, maximum, and average values.

### 5. `merge_files()`
Merges two or more input files into a single output file.

### 6. `deduplicate()`
Removes duplicate lines from a file and saves the unique lines in the output directory.

### 7. `command_exists()`
Checks whether a specified Linux command is installed and available.

### 8. `check_dependencies()`
Checks whether all required system commands are available.

### 9. `init_directories()`
Creates the required project directories if they do not already exist.

## Examples

### Count Lines

```bash
count_lines "data/data.txt"
```

### Extract CSV Columns

```bash
extract_columns "data/data.csv" 1,2
```

### Filter Data

```bash
filter_data "data/data.txt" "Linux"
```

### Calculate Statistics

```bash
calculate_stats "data/data.csv"
```

### Merge Files

```bash
merge_files "data/data.txt" "data/sample.txt"
```

### Remove Duplicate Lines

```bash
deduplicate "data/data.txt"
```

### Check Dependencies

```bash
check_dependencies
```

### Initialize Directories

```bash
init_directories
```

## Project Structure

```text
Bash-Data-Processing/
├── data/
│   ├── data.csv
│   ├── data.txt
│   └── sample.txt
├── logs/
│   └── project.log
├── output/
├── project_bash_script.sh
├── README.md
└── LICENSE
```

## License

This project is licensed under the MIT License.
