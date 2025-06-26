import os

# 0 = Real SSH
# 1 = EasyPot1
# 2 = EasyPot2
# 3 = StrangePot1
# 4 = StrangePot2
# 5 = StrangePot3
# 6 = StrangePot4
# 7 = KnownPot1
# 8 = KnownPot2

for x in range(9):
  container = "ssh"+str(x)+"_c"
  os.system("docker kill "+container)
  os.system("docker remove "+container)


