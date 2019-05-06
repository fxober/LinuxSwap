import os
path="/home/pmbench"
files=[]
for i in os.listdir(path):
    if os.path.isfile(os.path.join(path,i)) and 'log-' in i:
        with open (i,"r") as myfile:
           files.append(i)

files.sort()
count=0
flag=0
check=1
sum=calculate=0

my_iter=iter(files)
next(my_iter)

for x in files:
     count=count+1
     
     try:
      next_item=(next(my_iter))
      if next_item.endswith("-1"):
          flag=1
      else:
          flag=0
     except StopIteration:
        flag=0
        #print "flag disabled"
        pass
     print " "    
     print "Log name                 Readratio   CPU's     Pages accessed per second"
     filepath=os.path.join(path,x)
     with open (x,"r") as myfile:
        for line in myfile:
           if line.strip():
               
               if line.startswith("PMBENCH: size"):
                    word=line.split()
                    sizeofworkload=word[1]

               if line.startswith("PMBENCH: read"):
                    word=line.split()
                    readratio=word[1]

               if line.startswith("PMBENCH: cpu"):
                     word=line.split()
                     cpu=word[1]
                     
               if "Benchmark done" in line:
                    word=line.split()
                    
                    add=int(word[8])
                    sum=sum+add 

               if line.startswith("All threads joined"):
                        if cpu=="cpus=8":
                            print str(x) +"    "+str(readratio)+"    ",str(cpu)+"     "+str(sum/180)
                            sum=0
                        else:
                            print str(x) +"    "+str(readratio)+"    ",str(cpu)+"    "+str(sum/180)
                            sum=0


