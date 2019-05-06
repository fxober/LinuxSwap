#### Change these accordingly
# IMPORTANT : 1. Make sure you mention the threads and reads in the same order as mentioned in runpmbench.sh script
# 2. Mention log files of one particular run
# 3. Mention path to directory where log files are located

files=['log-190503-174421','log-190503-174421-1']
threads=[1,2,4,8,16,32]
reads=[0,50]
path="/home/pmbench"

#### No change from here
import os

filename=[]
i=0
for r in reads:
    for t in threads:
        if r==100:
            name="readratio-"+str(r)+"-threads-"+str(t)+"-read"
            filename.append(name)

        elif r==0:
            name="readratio-"+str(r)+"-threads-"+str(t)+"-write"
            filename.append(name)

        else:
            name="readratio-"+str(r)+"-threads-"+str(t)+"-read"
            filename.append(name)
            name="readratio-"+str(r)+"-threads-"+str(t)+"-write"
            filename.append(name)

count=len(filename)

with open("sum.txt","w") as myzerofile:
    i=0

array1=[]
array2=[]
array3=[]

filecount=0
flag=0

# write all histogram values to corresponding files
for x in files:
    filecount=filecount+1
    filepath=os.path.join(path,x)
    with open (x,"r") as myreadfile:
        for line in myreadfile:
            if line.startswith("PMBENCH: cpus=1 -"):
                flag=1
            
            if line.startswith("PMBENCH: cpus=2"):
                flag=0

            if flag==0 and line.startswith("2^"):
                 word=line.split()
                 if filecount==1:
                    array1.append(int(word[2]))
                 if filecount==2:
                    array2.append(int(word[2]))
            
            if flag==1 and line.startswith("2^"):
                 word=line.split()
                 if filecount==1:
                    array3.append(int(word[2]))
 
# add histogram values of both files
sum=map(sum,zip(array1,array2))

# copy values to file
for i in filename:
    with open (i,"w") as myzerofile:
        zero=0
    
other_iter=other_itercount=0    

singlethread_iter=singlethread_itercount=0
for i in filename:
    if "-threads-1-" in i:
        with open (i,"a") as myappendfile:
            for j in range(singlethread_iter+0,singlethread_iter+24):
                myappendfile.write(str(array3[j])+"\n")
                singlethread_itercount=singlethread_itercount+1
                if singlethread_itercount>23:
                    singlethread_iter=singlethread_iter+24
                    singlethread_itercount=0
    else: 
        with open (i,"a") as myappendfile:
            for j in range(other_iter+0,other_iter+24):
                myappendfile.write(str(sum[j])+"\n")
                other_itercount=other_itercount+1
                if other_itercount>23:
                    other_iter=other_iter+24
                    other_itercount=0
