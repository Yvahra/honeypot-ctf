#!/usr/bin/env python3

import re
import os
import datetime
import subprocess
import time

# Define patterns that indicate suspicious commands (expand this list!)
suspicious_patterns = [
    r"rm",          # Recursive and force delete (dangerous!)
    r"wget",            # Downloading files from the web
    r"curl",            # Similar to wget
    r"nc -l",           # Netcat listen (potential backdoors)
    r"chmod",       # Making files executable
    r"eval",           # Dangerous execution of code
    r"python -c",      # Running Python one-liners (can be malicious)
    r"bash -i",        # Interactive bash shell (potential access)
    r"cat /etc/shadow", # Viewing password hash file
    r"find .* -perm",    # Finding files with specific permissions
    #r"ps aux",          # Examining running processes
    r"> /dev/null 2>&1", # Redirection to hide output (can be used maliciously)
    r"apt-get install",  # Installing packages (potentially malicious)
    r"apt install",  # Modern apt install command.
    r"dpkg -i",         # Installing .deb packages (can install malware)
    r"addgroup",      # Adding a group. Usually harmless, but can be part of an attack.
    r"adduser",       # Adding a user. Similar to addgroup.
    r"crontab -e",    # Editing crontab (persistent backdoor)
    r"service.*restart", # Restarting services
    r"systemctl.*(start|stop|restart)", # Systemd control (start, stop, restart).  Can be abused.
    r"passwd",        # Changing passwords (could indicate account compromise)
    #r"ssh.*(root|user@)",  # Attempts to SSH to root or a user@host.  Important to check.
    r"sudo su",         # Using sudo to get root shell
    r"echo.*>>.*\.bashrc",  # Modifying .bashrc
    r"echo.*>>.*\.zshrc",  # Modifying .zshrc
    r"ifconfig",      # (deprecated but still used) - network configuration. Check for malicious configuration changes.
    r"ip addr",       # Modern replacement for ifconfig.
    r"iptables",       # Firewall manipulation
    r"ufw",           # Uncomplicated Firewall control (Ubuntu default).
    r"netstat",         # Network connections.  Check for suspicious connections.
    r"tcpdump",        # Packet capture (could be used for sniffing)
    r"wget .*--spider", # Spidering, potentially malicious
    r"screen",         # Screen session (can be used to hide activity)
    r"tmux",           # Tmux session (similar to screen)
    r"history.*-c",    # Clear shell history (attempting to hide activity)
    r"killall",       # Kill all process of some name (can be used maliciously)
    r"kill -9",          # Forcefully kill processes (can disrupt services)
    r"\.pyc",         # Attempt to run compiled python files.
    r"perl -e",        # Running Perl one-liners (can be malicious)
    r"ruby -e",        # Running Ruby one-liners (can be malicious)
    r"sed -i",        # In-place text substitution (can be used to inject code)
    r"awk",            # Powerful text processing tool, can be misused.
    r"tail -f",        # Following a log file, can be used to monitor.
    r"whoami",         # Typically harmless, but useful to check.
    r"id",           # Similar to whoami. Useful to check.
    r"uname -a",       # Get system information, can be a recon step.
    r"mount",          # Check for malicious mount operations.
    r"umount",         # Unmount (can be used to disrupt services)
    r"tar.*-cf",        # Creating tar archives (can be used to exfiltrate data)
    r"zip",            # Compressing files, could be used to exfiltrate data.
    r"unzip",          # Unzipping archives.
    r"find .* -name \.ssh", # Find .ssh directories
    r"ssh-keygen",      # SSH key generation (often a precursor to exploitation)
    r"ssh-copy-id",     # Copying SSH keys to a server
    r"cat /root/.ssh/authorized_keys", # Viewing authorized keys.
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


def reset_logs():
    if os.path.exists("/logs/-1/.ash_history"):
            os.system("rm /logs/-1/.ash_history")
    os.system("touch /logs/-1/.ash_history")
    os.system("chmod 666 /logs/-1/.ash_history")
    for container in range(-1,NB_CONTAINERS):
            if os.path.exists("/app/dind/logs/history_ssh"+str(container)+".log"):
                 os.system("rm /app/dind/logs/history_ssh"+str(container)+".log")
    
    

def send_logs():
    try:  
        GEN = load("/app/dind/.gen")
        log_name = "log_" + DID + "_" + GEN + ".log"
        cmd = "scp "
        cmd+= "-o StrictHostKeyChecking=no "
        cmd+= "-o UserKnownHostsFile=/dev/null "
        cmd+= "-i /app/config/log_key "
        cmd+= "/app/dind/logs/agg_logs_" + GEN + ".csv "
        cmd+= LOG_USER + "@" + LOG_SERVER + ":" + REMOTE_LOG_PATH + log_name
        os.system(cmd)
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

def aggregate_logs():
    GEN = load("/app/dind/.gen")
    agg_log_file = open("/app/dind/logs/agg_logs_" + GEN + ".csv", "w")
    agg_log_file.write("docker_id;generation;full_time;service;command\n")
    for container in range(-1,NB_CONTAINERS):
        if os.path.exists("/app/dind/logs/history_ssh"+str(container)+".log"):
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
    send_logs()
    

def analyze_logs(container:int):
    aggregate_logs()
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
                return 1
        if re.search("myshell", log, re.IGNORECASE) and container != 0:
            print(f"ALARM: Suspicious command detected in "+str(container)+": "+log)
            alarm()
            return 1
        return 0
               
def check_logs():
    for container in range(-1,NB_CONTAINERS):
        history_size = os.path.getsize("/logs/"+str(container)+"/command_history.log")
        if history_size != 0:
            backup(container)
            print("Log found")
            analyze_logs(container)
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
        GEN = load("/app/dind/.gen")
        save_dind_log()
        check_logs()

if __name__ == "__main__":
    main()
