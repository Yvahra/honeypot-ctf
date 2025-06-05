import random, os

LIST_IP = ['172.20.0.11','172.20.0.12','172.20.0.13','172.20.0.14']

SSH_SERVICE = 1
CONPOT_SERVICE = 2
COWRIE_SERVICE = 3
KIPPO_SERVICE = 4

f = open("/app/dind/.gen","r")
GEN = int(f.readline()[:-1]) + 1
f.close()


def assign_services() -> list[int]:
  """
  Generates a list containing the numbers 1, 2, 3, and 4 in a random order.

  Returns:
      list: A list containing the numbers 1, 2, 3, and 4 in a random order.
  """
  f = open("/app/dind/.gen","w")
  f.write(str(GEN)+ "/n")
  f.close()
  my_list = [SSH_SERVICE, CONPOT_SERVICE, COWRIE_SERVICE, KIPPO_SERVICE]
  random.shuffle(my_list)
  return my_list


def up_ssh(ind:int):
  """
  Build and run SSH docker.
  """
  os.system("docker build -t "+str(ind)+" --build-arg SSH_USER=user --build-arg SSH_PASS=ilovessh .")
  os.system("docker run --name "+str(ind)+"_c --net mynetwork" +str(ind))
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


services = generate_random_list()
for i in range(services):
  f = open("/app/dind/logs/gen-"+str(GEN)+".txt", "w")
  f.write(str(services) + ": " + str(LIST_IP))
  if services[i] == SSH_SERVICE:
    up_ssh(LIST_IP[i])
  elif services[i] == CONPOT_SERVICE:
    up_conpot(LIST_IP[i])
  elif services[i] == COWRIE_SERVICE:
    up_cowrie(LIST_IP[i])
  elif services[i] == KIPPO_SERVICE:
    up_kippo(LIST_IP[i])

