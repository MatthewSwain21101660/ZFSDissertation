#! /bin/bash

#Arrays for the script to loop through and retrieve all results from the tests
layout=("stripe" "mirror" "stripedmirror" "raidz" "raidz2" "raidz3")

diskNumber=("2" "3" "4" "5" "6" "4disk2vdev" "5disk2vdev" "6disk2vdev" "6disk2vdevUneven" "6disk3vdev")

workload=("fileserver" "videoserver" "mongo")

fileDate=("2024-06-22_20:36:01" "2024-06-23_15:35:01" "2024-06-24_01:03:01" "2024-06-25_00:01:01" "2024-06-26_16:36:01")


for (( layoutCount=0;layoutCount<=5;layoutCount++ ))
do
  for (( diskNumberCount=0;diskNumberCount<=9;diskNumberCount++ ))
  do
    #Checks if the directory exists before proceeding
    if [  -d /home/zfstest/results/zfsresultsfilebench/${layout[layoutCount]}/${diskNumber[$diskNumberCount]} ]
    then
      for (( workloadCount=0;workloadCount<=2;workloadCount++ ))
      do
        #Prints the current configuration to the file
        printf "\n${layout[layoutCount]}/${diskNumber[diskNumberCount]}/${workload[workloadCount]}\n" >> filebenchAggregatedResults.txt
         for ((  fileDateCount=0;fileDateCount<=4;fileDateCount++ ))
        do
          #Prints all 5 test results to the file. Prints the final 2 lines of the result file before piping those into  the grep command which removes all but the results
          tail -2 /home/zfstest/results/zfsresultsfilebench/${layout[layoutCount]}/${diskNumber[diskNumberCount]}/${workload[workloadCount]}${fileDate[fileDateCount]}.txt | grep -v "Shutting" >> filebenchAggregatedResults.txt
        done
      done
    fi
  done
done

