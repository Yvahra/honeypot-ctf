#!/usr/bin/env python3

import re
import os
import datetime
import subprocess
import time

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

def load(path):
    f = open(path,"r")
    res = str(f.readline()[:-1])
    f.close()
    return res

GEN = load("/app/dind/.gen")
DID = load("/app/dind/.container_id")
LOG_USER = load("/app/config/log_user")
LOG_SERVER = load("/app/config/log_server")
REMOTE_LOG_PATH = load("/app/config/remote_log_path")


def init_log(container:int):
    if os.path.exists("/logs/"+str(container)+"/command_history.log"):
        os.system("rm /logs/"+str(container)+"/command_history.log")
    os.system("touch /logs/"+str(container)+"/command_history.log")
    os.system("chmod 666 /logs/"+str(container)+"/command_history.log")

def backup(container:int):
    if not os.path.exists("/logs_bck/"+str(container)+"/"):
        os.system("mkdir -p /logs_bck/"+str(container))
    os.system("cp /logs/"+str(container)+"/command_history.log /app/dind/logs/history_ssh"+str(container)+".log")

def save_dind_log():
    """Logs the last command typed by the user to the specified file, along with a timestamp."""
    try:
        # 1. Get the last command from .ash_history
        #    Use 'tail -n 1' to reliably get only the *last* line, even with multi-line commands.
        #    'shell=True' is necessary because the shell is expanding the tilde (~).
        #    'text=True' decodes the bytes to a string.

        last_modified = load("/app/dind/.last_dind_log").split("\n")[0]
        
        (mode, ino, dev, nlink, uid, gid, size, atime, mtime, ctime) = os.stat("/jail/home/nobody1/.ash_history")

        # result = subprocess.run(
        #         ["stat","-c", "%y", "/jail/home/nobody1/.ash_history"],
        #         capture_output=True,
        #         text=True,
        #         shell=False  # Use shell=False for security, unless you need shell features.
        #     )
        # last_command = result.stdout.strip()
        
        if last_modified != time.ctime(mtime):
        
            result = subprocess.run(
                ["tail", "-n", "1", "/jail/home/nobody1/.ash_history"],
                capture_output=True,
                text=True,
                shell=False  # Use shell=False for security, unless you need shell features.
            )
            command = result.stdout.strip()
            # 2. Get the current timestamp
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            # 3. Format the log entry
            log_entry = f"    X  {timestamp} {command}\n"
    
            # 4. Append the log entry to the log file
            
            with open("/logs/-1/.ash_history", "a") as f:
                f.write(log_entry)
            os.system("cp /logs/-1/.ash_history /logs/-1/command_history.log")
    
            with open("/app/dind/.last_dind_log", "w") as f:
                f.write(time.ctime(mtime)+"\n")
    
            #except Exception as e:
            #    print(f"Error writing to log file {log_file}: {e}")

    except Exception as e:
        print(f"An unexpected error occurred: {e}")

def send_logs():
    try:  
        os.system("scp -i /app/config/log_key " + LOG_USER + "@" + LOG_SERVER + ":" + REMOTE_LOG_PATH)
    except Exception as e:
        print(str(e))

def alarm():
    print("Alarm!")
    os.system("ps -ef | grep \"10.0.0.\" | grep -v grep | awk '{print $1}' | xargs kill")
    os.system("echo 'An Intruder has been detected!\nReconfiguring the network...' | wall")
    os.system("python /app/dind/stop-services.py")
    send_logs()
    os.system("python /app/dind/start-services.py")
    os.system("echo 'Network reconfigured!' | wall")

def analyze_logs(container:int) -> bool:
    log_file = open("/app/dind/logs/history_ssh"+str(container)+".log", "r")
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
    agg_log_file = open("/app/dind/logs/agg_logs_" + GEN + ".csv", "w")
    agg_log_file.write("docker_id;generation;full_time;service;command\n")
    for container in range(-1,NB_CONTAINERS):
        if os.path.exists("/app/dind/logs/history_ssh"):
            log_file = open("/app/dind/logs/history_ssh"+str(container)+".log", "r")
            logs = log_file.readlines()
            for log in logs:
                docker_id = str(DID) + ";"
                generation = str(GEN) + ";"
                time = log.split(" ")[6] + " " + log.split(" ")[7] + ";"
                command = ""
                for arg in log.split(" ")[8:]:
                    command += arg + " "
                command= command[:-1]
                agg_log_file.write(docker_id + generation + time + str(container) + ";" + command)
            log_file.close()        
    agg_log_file.close()
    return False

def check_logs():
    for container in range(-1,NB_CONTAINERS):
        history_size = os.path.getsize("/logs/"+str(container)+"/command_history.log")
        if history_size != 0:
            backup(container)
            print("Log found")
            alarm = analyze_logs(container)
            init_log(container)
            
        

def main():
    f = open("/app/dind/.last_dind_log", "w")
    f.write("-1\n")
    f.close()
    # Keep the script running
    for container in range(-1,NB_CONTAINERS):
        init_log(container)
    os.system("touch /logs/-1/.ash_history")
    while True:
        save_dind_log()
        check_logs()

if __name__ == "__main__":
    main()
