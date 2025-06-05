import os

for i in range(4):
  os.system("docker stop "+str(i+1)+"_c")

for i in range(4):
  os.system("docker remove "+str(i+1)+"_c")
