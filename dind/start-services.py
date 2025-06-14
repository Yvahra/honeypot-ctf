import random, os

LIST_IP = ['10.0.0.11','10.0.0.12','10.0.0.13','10.20.0.14']

SSH_SERVICE = 1
CONPOT_SERVICE = 2
COWRIE_SERVICE = 3
KIPPO_SERVICE = 4

f = open("/app/dind/.gen","r")
GEN = int(f.readline()[:-1])
f.close()


def assign_services() -> list[int]:
  """
  Generates a list containing the numbers 1, 2, 3, and 4 in a random order.

  Returns:
      list: A list containing the numbers 1, 2, 3, and 4 in a random order.
  """
  f = open("/app/dind/.gen","w")
  f.write(str(GEN+1)+ "\n")
  f.close()
  my_list = [SSH_SERVICE, CONPOT_SERVICE, COWRIE_SERVICE, KIPPO_SERVICE]
  random.shuffle(my_list)
  return my_list


def up_ssh(ind:int):
  """
  Build and run SSH docker.
  """
  os.system("cd /app/ssh/ && docker build -t "+str(ind+1)+" .")
  os.system("cd /app/ssh/ && docker run -v sharedLogs:/sharedLogs -d --name "+str(ind+1)+"_c --net honeynet --ip " + LIST_IP[ind] + " " + str(ind+1))
  pass


def up_conpot(ip:str):
  """
  Build and run CONPOT docker.
  """
  pass


def up_cowrie(ip:str):
  """
  Build and run COWRIE docker.
  """
  pass


def up_kippo(ip:str):
  """
  Build and run KIPPO docker.
  """
  pass


services = assign_services()
for i in range(len(services)):
  f = open("/app/dind/logs/gen-"+str(GEN)+".txt", "w")
  f.write(str(services) + ": " + str(LIST_IP))
  f.close()
  if services[i] == SSH_SERVICE:
    up_ssh(i)
  elif services[i] == CONPOT_SERVICE:
    up_conpot(i)
  elif services[i] == COWRIE_SERVICE:
    up_cowrie(i)
  elif services[i] == KIPPO_SERVICE:
    up_kippo(i)

