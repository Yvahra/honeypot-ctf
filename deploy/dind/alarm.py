#!/usr/bin/env python3

import re
import os

# Define patterns that indicate suspicious commands (expand this list!)
suspicious_patterns = [
    r".*rm -rf \/.*",     # Attempt to delete everything
    r".*wget.*",           # Download files
    r".*curl.*",           # Download files
    r".*dd if=\/dev\/.*",  # Low-level disk access
    r".*nc -l.*",          # Start a listening netcat
    r".*python -m http\.server.*", # Start a web server
    r".*perl.*",            # Run Perl scripts
    r".*lua.*",             # Run Lua Scripts
    r".*whoami.*",         # Getting the current user
    r".*uname -a.*",        # Kernel Version Information
    r".*id.*",              # Get User IDs and Group IDs
    r".*ps aux.*",        # Process Listing
    r".*netstat -ant.*", # List Network Connections
    r".*ifconfig.*",    # Interface information
    r".*service ssh start.*",  # Attempt to start ssh service
    r".*sudo.*",           # Try to use sudo commands
    r".*su.*",             # Switch User
]

NB_CONTAINERS = 9

def init_log(container:int):
    if os.path.exists("/logs/"+str(container)+"/command_history.log"):
        os.system("rm /logs/"+str(container)+"/command_history.log")
    os.system("touch /logs/"+str(container)+"/command_history.log")
    os.system("chmod 666 /logs/"+str(container)+"/command_history.log")

def backup():
    for container in range(1, NB_CONTAINERS+1):
        if not os.path.exists("/logs_bck/"+str(container)+"/"):
            os.system("mkdir -p /logs_bck/"+str(container))
        os.system("cp /logs/"+str(container)+"/command_history.log /logs_bck/"+str(container)+"/last_history.log")

def alarm():
    print("Alarm!")
    os.system("ps -ef | grep \"10.0.0.\" | grep -v grep | awk '{print $1}' | xargs kill")
    os.system("echo 'An Intruder has been detected!\nReconfiguring the network...' | wall")
    os.system("python /app/dind/stop-services.py")
    os.system("python /app/dind/start-services.py")
    os.system("echo 'Network reconfigured!' | wall")

def send_logs(container:int):
    pass

def analyze_logs(container:int) -> bool:
    log_file = open("/logs_bck/"+str(container)+"/last_history.log", "r")
    logs = log_file.readlines()
    log_file.close()
    if len(logs) > 5:
        logs = logs[-5:]
    for log in logs:
        for pattern in suspicious_patterns:
            if re.search(pattern, log, re.IGNORECASE):
                print(f"ALARM: Suspicious command detected in "+str(container)+": "+log)
                alarm()
                return True
    return False

def check_logs():
    for container in range(1, NB_CONTAINERS+1):
        history_size = os.path.getsize("/logs/"+str(container)+"/command_history.log")
        if history_size != 0:
            backup()
            print("Log found")
            alarm = analyze_logs(container)
            init_log(container)
            
        

def main():
    # Keep the script running
    for container in range(1, NB_CONTAINERS+1):
        init_log(container)
    while True:
        check_logs()

if __name__ == "__main__":
    main()
