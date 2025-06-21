import os

for container in ["ssh_c", "kippo_c", "cowrie_c"]:
  os.system("docker stop "+container)
  os.system("docker remove "+container)

#os.system("rm /jail/home/player/.ssh/known_hosts")
#os.system("touch /jail/home/player/.ssh/known_hosts")
