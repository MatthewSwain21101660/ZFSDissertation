#! /bin/bash

#Timestamp variable
NOW=$( date '+%F_%H' )

#Arrays for the script to recurse through to perform every test in every configuration
raidArray=("" "mirror" "raidz" "raidz2" "raidz3")
arrayCount=0

disks=("/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde" "/dev/sdf" "/dev/sdg")

while [ $arrayCount -lt 5 ]
do
  #Recursing  through an increasing number of disks
  usedDisks="/dev/sdb"
  disksCount=1
  while [ $disksCount -lt 6 ]
  do
    usedDisks+=" ${disks[$disksCount]}"

    #Removing any previous pools
    zpool destroy zfstest

    #Creating the new pool with an ashift of 12 and with the required number of disks
    zpool create -f -o ashift=12 zfstest ${raidArray[arrayCount]} $usedDisks

    zpool status

    #The different operations to be tested against the workload
    fioOperation=("read" "write" "rw" "randread" "randwrite" "randrw")

    for (( f=0;f<=5;f++ ))
    do
      #Worst case scenario test
      fio --name=${fioOperation[f]} --rw=${fioOperation[f]} --size=4g --bs=4k --numjobs=1 --iodepth=1 --ioengine=libaio --runtime=60 --startdelay=60 \
      --time_based --end_fsync=1 --directory=/zfstest --output=$HOME/results/zfsresultsfio/${raidArray[arrayCount]}/${fioOperation[f]}/$((disksCount+1))/worstcase$NOW


      #General use scenario test
      fio --name=${fioOperation[f]} --rw=${fioOperation[f]} --size=256m --bs=64k  --numjobs=16 --iodepth=16 --ioengine=libaio --runtime=60 --startdelay=60 \
      --time_based --end_fsync=1 --directory=/zfstest --output=$HOME/results/zfsresultsfio/${raidArray[arrayCount]}/${fioOperation[f]}/$((disksCount+1))/generaluse$NOW

      #Best case scenario test
      fio --name=${fioOperation[f]} --rw=${fioOperation[f]} --size=16g --bs=1m --numjobs=1 --iodepth=1 --ioengine=libaio --runtime=60 --startdelay=60 \
      --time_based --end_fsync=1 --directory=/zfstest --output=$HOME/zfstest/results/zfsresultsfio/${raidArray[arrayCount]}/${fioOperation[f]}/$((disksCount+1))/bestcase$NOW
    done
    ((disksCount++))
  done
  ((arrayCount++))
done


#Arrays for abnormal configurations that cannot be done for every configuration type and so need to be created and tested seperately
zpoolCreate=("mirror /dev/sdb /dev/sdc mirror /dev/sdd /dev/sde" \
"mirror /dev/sdb /dev/sdc /dev/sdd mirror /dev/sde /dev/sdf" \
"mirror /dev/sdb /dev/sdc /dev/sdd mirror /dev/sde /dev/sdf /dev/sdg" \
"mirror /dev/sdb /dev/sdc /dev/sdd /dev/sde mirror /dev/sdf /dev/sdg" \
"mirror /dev/sdb /dev/sdc mirror /dev/sdd /dev/sde mirror /dev/sdf /dev/sdg" \
"raidz /dev/sdb /dev/sdc raidz /dev/sdd /dev/sde" \
"raidz /dev/sdb /dev/sdc /dev/sdd raidz /dev/sde /dev/sdf" \
"raidz /dev/sdb /dev/sdc /dev/sdd raidz /dev/sde /dev/sdf /dev/sdg" \
"raidz /dev/sdb /dev/sdc /dev/sdd /dev/sde raidz /dev/sdf /dev/sdg" \
"raidz /dev/sdb /dev/sdc raidz /dev/sdd /dev/sde raidz /dev/sdf /dev/sdg" \
"raidz2 /dev/sdb /dev/sdc /dev/sdd raidz2 /dev/sde /dev/sdf /dev/sdg")

zfsConfigFolder=("stripedmirror" "stripedmirror" "stripedmirror" "stripedmirror" "stripedmirror" "raidz" "raidz" "raidz" "raidz" "raidz" "raidz2")

zfsDiskNum=("4disk2vdev" "5disk2vdev" "6disk2vdev" "6disk2vdevUneven" "6disk3vdev" "4disk2vdev" "5disk2vdev" "6disk2vdev" "6disk2vdevUneven" "6disk3vdev" "6disk2vdev")

#Same as above but for the abnormal configurations
for (( i=0; i<=10; i++ ))
do
  zpool destroy zfstest

  zpool create -f -o ashift=12 zfstest ${zpoolCreate[i]}

  zpool status

  fioOperation=("read" "write" "rw" "randread" "randwrite" "randrw")

  for (( f=0;f<=5;f++ ))
  do
    #Worst case scenario test
    fio --name=${fioOperation[f]} --rw=${fioOperation[f]} --size=4g --bs=4k --numjobs=1 --iodepth=1 --ioengine=libaio --runtime=60 --startdelay=60 \
    --time_based --end_fsync=1 --directory=/zfstest --output=$HOME/results/zfsresultsfio/${zfsConfigFolder[i]}/${fioOperation[f]}/${zfsDiskNum[i]}/worstcase$NOW

    #General use scenario test
    fio --name=${fioOperation[f]} --rw=${fioOperation[f]} --size=256m --bs=64k  --numjobs=16 --iodepth=16 --ioengine=libaio --runtime=60 --startdelay=60 \
    --time_based --end_fsync=1 --directory=/zfstest --output=$HOME/results/zfsresultsfio/${zfsConfigFolder[i]}/${fioOperation[f]}/${zfsDiskNum[i]}/generaluse$NOW

    #Best case scenario test
    fio --name=${fioOperation[f]} --rw=${fioOperation[f]} --size=16g --bs=1m --numjobs=1 --iodepth=1 --ioengine=libaio --runtime=60 --startdelay=60 \
    --time_based --end_fsync=1 --directory=/zfstest --output=$HOME/results/zfsresultsfio/${zfsConfigFolder[i]}/${fioOperation[f]}/${zfsDiskNum[i]}/bestcase$NOW
  done
done
