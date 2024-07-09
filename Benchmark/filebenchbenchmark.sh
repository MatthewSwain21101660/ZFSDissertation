#! /bin/bash

#Timestamp variable
NOW=$( date '+%F_%H:%M:%S' )

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

    rm -rf /zfstest

    #Creating the new pool with an ashift of 12 and with the required number of disks
    zpool create -f -o ashift=12 zfstest ${raidArray[arrayCount]} $usedDisks

    zpool status

    #The three benchmarks scenarios to be run
    filebench=("fileserver" "videoserver" "mongo")

    #Recurses through all three benchmarks
    for (( f=0; f<=2; f++ ))
    do
      #Outputs the array type and benchmark
      echo "${raidArray[$arrayCount]} ${filebench[f]}"

      #Runs the filebench workload and saves the output to the specified directory
      filebench -f /home/zfstest/benchmark/filebenchworkloads/${filebench[f]}.f | tee "/home/zfstest/results/zfsresultsfilebench/${raidArray[$arrayCount]}/$((disksCount+1))/${filebench[f]}$NOW.txt"
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

  rm -rf /zfstest

  zpool create -f -o ashift=12 zfstest ${zpoolCreate[i]}

  zpool status

  filebench=("fileserver" "videoserver" "mongo")

    for (( f=0; f<=0; f++ ))
    do
      echo "${raidArray[$arrayCount]} ${filebench[f]}"
      filebench -f /home/zfstest/benchmark/filebenchworkloads/${filebench[f]}.f | tee "/home/zfstest/results/zfsresultsfilebench/${zfsConfigFolder[i]}/${zfsDiskNum[i]}/${filebench[f]}$NOW.txt"
    done
done
