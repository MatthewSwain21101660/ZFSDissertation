#! /bin/bash

#zfsresultsfio/mirror

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
      if [  -d $HOME/results/zfsresultsfio/"${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[$diskNumberCount]}" ]
      then
        for (( useCaseCount=0;useCaseCount<=2;useCaseCount++ ))
        do
          printf "\n${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]}\n" >> fioAggregatedResults

          for ((  fileDateCount=0;fileDateCount<=5;fileDateCount++ ))
          do
            cat $HOME/results/zfsresultsfio/${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]}${fileDate[fileDateCount]} | grep -A11 "Run status" >> fioAggregatedResults
          done
        done
      fi
    done
  done
done

