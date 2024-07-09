#! /bin/bash

#Defining a list of the possible ZFS configs
layout=("stripe" "mirror" "stripedmirror" "raidz" "raidz2" "raidz3")

#Defining a list of the possible disk layouts
diskNumber=("2" "3" "4" "5" "6" "4disk2vdev" "5disk2vdev" "6disk2vdev" "6disk2vdevUneven" "6disk3vdev")

#Defining a list of the different workloads
workload=("fileserver" "videoserver" "mongo")

#Defining a list of the different dates of the files
fileDate=("2024-06-22_20:36:01" "2024-06-23_15:35:01" "2024-06-24_01:03:01" "2024-06-25_00:01:01" "2024-06-26_16:36:01")

#Added headers for ease of manipulating data
echo "Config, Result" >> filebenchAveragedResults.txt

#A series of nested for loops to recurse through the directories
for (( layoutCount=0;layoutCount<=5;layoutCount++ ))
do
  for (( diskNumberCount=0;diskNumberCount<=9;diskNumberCount++ ))
  do
    #First checks that the directory exits
    if [  -d /home/zfstest/results/zfsresultsfilebench/"${layout[layoutCount]}/${diskNumber[$diskNumberCount]}" ]
    then
      #Recurses through the different use cases
      for (( workloadCount=0;workloadCount<=2;workloadCount++ ))
      do
        #Resets all average values to 0
        workloadMbsAverage=0
        workloadIopsAverage=0

        #Recurses through all the repeated tests
        for (( fileDateCount=0;fileDateCount<=4;fileDateCount++ ))
        do
          #Extracts the mb/s value to a variable. Regex does the following. "(?<=\b)" is a positive look behind for a word boundary, meaning it will go through the string until it finds the end of a word behind it. "\d+(\.\d+)?" then checks if the current value is a number, optionally with a decimal. After this, it checks whether the next value is mb/s with "(?=mb/s\b)". If all of these are true, then the value will be returned.
          extractedResultMbs=$(cat /home/zfstest/results/zfsresultsfilebench/${layout[layoutCount]}/${diskNumber[diskNumberCount]}/${workload[workloadCount]}${fileDate[fileDateCount]}.txt | tail -2 | grep -v "Shutting" | grep -oP "(?<=\b)\d+(\.\d+)?(?=mb/s\b)" )
          #Extracts the iop/s value to a variable
          extractedResultIops=$(cat /home/zfstest/results/zfsresultsfilebench/${layout[layoutCount]}/${diskNumber[diskNumberCount]}/${workload[workloadCount]}${fileDate[fileDateCount]}.txt | tail -2 | grep -v "Shutting" | grep -oP "(?<=\b)\d+\.\d+(?= ops/s\b)" )

         #Adds the extracted result to the running total
          workloadMbsAverage=$(echo "$workloadMbsAverage" + "$extractedResultMbs" | bc -l)
          workloadIopsAverage=$(echo "$workloadIopsAverage" + "$extractedResultIops" | bc -l)
        done
        #Running total is divided by 5 to find the average
        workloadMbsAverage=$(echo "scale=3; $workloadMbsAverage / 5" | bc -l)
        workloadIopsAverage=$(echo "scale=3; $workloadIopsAverage / 5" | bc -l)
        #Result and what configuration it was for is outputted into a file
        echo "${layout[layoutCount]}/${diskNumber[diskNumberCount]}/${workload[workloadCount]} mb/s"",""$workloadMbsAverage" >> filebenchAveragedResults.txt
        echo "${layout[layoutCount]}/${diskNumber[diskNumberCount]}/${workload[workloadCount]} ops/s"",""$workloadIopsAverage" >> filebenchAveragedResults.txt
      done
    fi
  done
done
