import random, os

LIST_IP = ['10.0.0.1'+str(x) for x in range(1,10)]

# 0 = Real SSH
# 1 = EasyPot1
# 2 = EasyPot2
# 3 = StrangePot1
# 4 = StrangePot2
# 5 = StrangePot3
# 6 = StrangePot4
# 7 = KnownPot1
# 8 = KnownPot2

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
  my_list = [x for x in range(9)]
  random.shuffle(my_list)
  return my_list


def up_ssh(type:int, ip:str):
  """
  Build and run SSH docker.
  """
  os.system("cd /app/ssh/ && docker run -v /logs/"+str(type+1)+"/:/logs -d --name ssh"+str(type)+"_c --net honeynet --ip " + ip + " ssh"+str(type) + " "+str(type))
  pass


services = assign_services()
os.system("docker volume prune -a -f")
for i in range(len(services)):
  f = open("/app/dind/logs/gen-"+str(GEN)+".txt", "w")
  f.write(str(services) + ": " + str(LIST_IP))
  f.close()
  print(LIST_IP[i],":",services[i])
  up_ssh(type=0, ip=LIST_IP[i])

