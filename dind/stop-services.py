import os, time

for i in range(4):
  os.system("docker stop "+str(i+1)+"_c")

time.sleep(30)

for i in range(4):
  os.system("docker remove "+str(i+1)+"_c")
