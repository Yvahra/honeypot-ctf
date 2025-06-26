USERNAME="nobody1"  # Replace with the actual username
LOG_DIR="/logs/-1" #Log Directory
LOG_FILE="$LOG_DIR/commands_history.log" #Log File
mkdir -p $LOG_DIR #Creates the directory if does not exists

# Trap the DEBUG signal and log the command
trap 'printf "%(%Y-%m-%d %H:%M:%S)T: %s\n" "$BASH_COMMAND" >> "$LOG_FILE"' DEBUG
