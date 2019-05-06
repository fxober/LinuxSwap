#!/bin/bash


########### GENERAL SETTINGS ###################################################################
# size in GB. Should be 2X amount of memory or more.
testsize="170"
# test time. Should be long enough to be stable.
time=120
# Percentage read/write ratio (0 = write only, 100 = read only). "0 50" will run both cases.
readpct="0 50"
# CPUs to use for the run. "1 18 36" will run in each of the cpu counts.
# It is recommended to run on 1, cores/socket, cores/system
cpustorun="1 2 4 8 16 32"
###################################################################################################
log=log-`date +%y%m%d-%H%M%S`
log1=log-`date +%y%m%d-%H%M%S`-1
echo UNAME >> $log
uname -a >> $log
echo >> $log
echo FREE >> $log 2>&1
free -g >> $log 2>&1
numactl --hardware >> $log 2>&1
dmesg | egrep "Memory:|totalpages" >> $log 2>&1

# Test
for si in $testsize; do
	half=$((si/2))
	#echo $half
	halfsize=$((half*1024))
	fullsize=$((si*1024))
	#echo $halfsize
	echo PMBENCH: size=$si - `date +%y%m%d-%H:%M:%S` >> $log 2>&1
	echo PMBENCH: size=$si - `date +%y%m%d-%H:%M:%S` >> $log1 2>&1
	
	for r in $readpct; do
      	echo PMBENCH: read=$r - `date +%y%m%d-%H:%M:%S` >> $log 2>&1
       	echo PMBENCH: read=$r - `date +%y%m%d-%H:%M:%S` >> $log1 2>&1
       	for cpus in $cpustorun; do
           	echo >> $log 2>&1
		    echo >> $log1 2>&1
              	 	    
           	echo PMBENCH: cpus=$cpus - `date +%y%m%d-%H:%M:%S` >> $log 2>&1
		    echo PMBENCH: cpus=$cpus - `date +%y%m%d-%H:%M:%S` >> $log1 2>&1
			    
			echo "cpu=$cpus"
		    if [[ "$cpus" -eq 1 ]]; then
			/home/pmbench/pmbench -z -r $r -a histo -j $cpus -s $((si*1024)) -m $((si*1024)) $time >> $log 2>&1 
		    else  
			#numactl -m 1 -N 1 -- ./pmbench -z -r $r -a histo -j $cpus -s $fullsize -m $fullsize $time >> $log1 2>&1 &
			#numactl -m 0 -N 0 -- ./pmbench -z -r $r -a histo -j $cpus -s $fullsize -m $fullsize $time >> $log 2>&1 &
                        numactl -m 0 -N 0 -- /home/pmbench/pmbench -z -r $r -a histo -j $((cpus/2)) -s $halfsize -m $halfsize $time >> $log 2>&1 &
			numactl -m 1 -N 1 -- /home/pmbench/pmbench -z -r $r -a histo -j $((cpus/2)) -s $halfsize -m $halfsize $time >> $log1 2>&1 &
			wait
	     	    fi	
       	done
	done
done
