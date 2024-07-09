#! /bin/bash

#Arrays for the script to loop through and retrieve all results from the tests
layout=("stripe" "mirror" "stripedmirror" "raidz" "raidz2" "raidz3")

testType=("read" "write" "rw" "randread" "randwrite" "randrw")

diskNumber=("2" "3" "4" "5" "6" "4disk2vdev" "5disk2vdev" "6disk2vdev" "6disk2vdevUneven" "6disk3vdev")

useCase=("bestcase" "generaluse" "worstcase")

fileDate=("2024-05-15_12" "2024-05-17_12" "2024-05-19_12" "2024-05-21_12" "2024-05-23_12" "2024-05-25_12")


for (( layoutCount=0;layoutCount<=5;layoutCount++ ))
do
  for (( testTypeCount=0;testTypeCount<=5;testTypeCount++ ))
  do
    for (( diskNumberCount=0;diskNumberCount<=9;diskNumberCount++ ))
    do
      #Checks if the directory exists before proceeding
      if [  -d /home/zfstest/results/zfsresultsfio/"${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[$diskNumberCount]}" ]
      then
        for (( useCaseCount=0;useCaseCount<=2;useCaseCount++ ))
        do
          #Prints the current configuration to the file
          printf "\n${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]}\n" >> fioAggregatedResults.txt
          for ((  fileDateCount=0;fileDateCount<=5;fileDateCount++ ))
          do
            #Prints all 6 results to the file. Entire file is printed, then piped into grep to remove all but the results lines
            cat /home/zfstest/results/zfsresultsfio/${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]}${fileDate[fileDateCount]} | grep -A11 "Run status" >> fioAggregatedResults.txt
          done
        done
      fi
    done
  done
done

