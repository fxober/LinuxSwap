#################################################################################
# Initial parameters

# Number of partitions on device
numparts=14
# Size of  partitions
size="+21G"
# Drives used to create partitions
drivelist="/dev/nvme1n1 /dev/nvme3n1"
# Drives to be tuned
tunedrives="nvme1n1 nvme3n1"

####################################################################################
# swap specific settings

# page cluster    [-1 FOR DEFAULT]
cluster=0
# numa_balancing
numa_balancing=0
# watermark_scale_factor - when to swap (fraction from 10000) [-1 FOR DEFAULT]
watermark_scale_factor=400
# max_sectors_kb  [-1 FOR DEFAULT]
max_sectors_kb=32
#queue_size
queue_size=64
# nomerges        [-1 FOR DEFAULT]
nomerges=2

####################################################################################
# set up log

log=setup-log-`date +%y%m%d-%H%M%S`

###################################################################################

#create partitions on drives

for dev in $drivelist
do
        # Send zap disk command to gdisk
        printf 'x\nz\ny\nn\n' | gdisk $dev
        sleep 1
        input=""

        # Construct add partition commands for OSDs
        for((i=1; i<=numparts; i++ ))
        do
                input+="n\n\n\n${size}\n8200\n"
        done

        # Tack on the write to disk command to the input string
        input+="w\ny\n"

        # Send entire command string to gdisk
        printf $input | gdisk $dev 

        echo "Partitioned $dev" >> $log 2>&1
        sleep 1
        sync


done

/sbin/partprobe; sleep 1; /sbin/partprobe; sleep 1

################################################################################

#setup swap

for dev in $drivelist
do
	# Create swap
	for i in ${dev}p*;
	do
		/sbin/mkswap -f $i 
		/sbin/swapon -p 10 $i
	done
done

###############################################################################

# tunings

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo 0     > /proc/sys/kernel/numa_balancing

grep -H ^ /proc/sys/vm/page-cluster >> $log 2>&1
if [ $cluster -ge 0 ]; then
	echo $cluster > /proc/sys/vm/page-cluster
	grep -H ^ /proc/sys/vm/page-cluster >> $log 2>&1
fi

grep -H ^ /proc/sys/kernel/numa_balancing >> $log 2>&1
if [ $numa_balancing -ge 0 ]; then
	echo $numa_balancing > /proc/sys/kernel/numa_balancing
	grep -H ^ /proc/sys/kernel/numa_balancing >> $log 2>&1
fi

grep -H ^ /proc/sys/vm/watermark_scale_factor >> $log 2>&1
if [ $watermark_scale_factor -ge 0 ]; then
 	echo $watermark_scale_factor > /proc/sys/vm/watermark_scale_factor
	grep -H ^ /proc/sys/vm/watermark_scale_factor >> $log 2>&1
fi

for dev in $tunedrives
do
	echo $drive
	grep -H ^ /sys/block/$dev/queue/max_sectors_kb >> $log 2>&1
	if [ $max_sectors_kb -ge 0 ]; then
     		echo $max_sectors_kb > /sys/block/$dev/queue/max_sectors_kb
		grep -H ^ /sys/block/nvme*/queue/max_sectors_kb >> $log 2>&1
	fi
	
	grep -H ^ /sys/block/$dev/queue/nr_requests >> $log 2>&1
	if [ $queue_size -ge 0 ]; then
       		echo $queue_size > /sys/block/$dev/queue/nr_requests
		grep -H ^ /sys/block/$dev/queue/nr_requests >> $log 2>&1
	fi

	grep -H ^ /sys/block/$dev/queue/nomerges >> $log 2>&1
	if [ $nomerges -ge 0 ]; then
        	echo $nomerges > /sys/block/$dev/queue/nomerges
		grep -H ^ /sys/block/$dev/queue/nomerges >> $log 2>&1
	fi
done

