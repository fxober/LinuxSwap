# LinuxSwap
This is a repository for a new generation of Linux Swap developments, including testing, results and patch snippets.

If you are using Linux Swap you should be on Linux kernel 4.14 or newer, up streamed patches are the following pulled from kernelnewbies.

https://kernelnewbies.org/Linux_4.14
•	Second step of Transparent Huge Page swap optimization. In the first step, the splitting huge page is delayed from almost the first step of swapping out to after allocating the swap space for the THP and adding the THP into the swap cache. In the second step, the splitting is delayed further to after the swapping out finished. Swap out throughput of THP improves 42% in some benchmarks commit, commit, commit, commit, commit, commit, commit, commit, commit, commit, commit, commit
•	Virtual memory based swap readahead. The traditional approach is readahead based on the placement of pages in the swap device; this release does swap readahead based on the placement of swapped pages in virtual memory. This approach causes extra overhead in traditional HDDs, which is why it's only enabled for SSDs. A sysfs knob, /sys/kernel/mm/swap/vma_ra_enabled, has been added that allows to enable it manually; swap readahead statistics are also available commit, commit, commit, commit, commit
•	swap: choose swap device according to numa node to improve performance commit

Best Practices for Configuration:

1. Use one (1) Optane or Storage Class Memory SSD that support high write traffic SSDs for each Numa Node (cpu socket). So in a two socket system you would use two. 

2. The Linux kernel can at most support 28 "swap partitions" so 14 per SSD assuming you use two= SSDs for two socket server. So 28 swap partitions is recommended and set the partition priority equal if you can, using syntax like this, all with the same exact priority/ swapon –p 10 /dev/nvme01p1

3. We need to avoid RCU call back processing in softirq from blocking for a long time and cause long latency. The rcu processings are offloaded to dedicated kthreads.  Set the following kernel config.
a.	CONFIG_RCU_NOCB_CPU=y  
b.	CONFIG_RCU_NOCB_CPU_ALL=y
Or use the following kernel config:
a.	CONFIG_RCU_NOCB_CPU=y
And use the following kernel command line arguments: rcu_nocb=<all cpus>

So configure your kernel with these .config settings if you are able to compile your own kernel.

4. EXPERIMENTAL: Generally speaking you want the nvme scheduler set to [none] on SSD nvme devices, you may want to test the mq block or kyber scheduler in most cases your build shows just [none] and that's fine.
  more /sys/block/nvme1n1/queue/scheduler
  [none]
  
5. Newer kernels allow an nvme queue size of 1023 this should be plenty.

6. If you are seeing nvme block merges you probably don't want these and you probably want to set your nvme block size to 4Kib not 512b sectors, if you are still seeing merges then you might want to try.

First check the nomerges value -
 #cat /sys/block/<nvme>/queue/nomerges
 if it's not already 2, then do:
 echo 2 > /sys/block/<nvme>/queue/nomerges`
