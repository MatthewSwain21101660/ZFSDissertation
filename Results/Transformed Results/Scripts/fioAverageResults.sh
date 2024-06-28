#! /bin/bash

#Defining a list of the possible ZFS configs
layout=("stripe" "mirror" "stripedmirror" "raidz" "raidz2" "raidz3")

#Defining a list of the possible test types
testType=("read" "write" "rw" "randread" "randwrite" "randrw")

#Defining a list of the possible disk layouts
diskNumber=("2" "3" "4" "5" "6" "4disk2vdev" "5disk2vdev" "6disk2vdev" "6disk2vdevUneven" "6disk3vdev")

#Defining a list of the different use cases
useCase=("bestcase" "generaluse" "worstcase")

#Defining a list of the different dates of the files
fileDate=("2024-05-15_12" "2024-05-17_12" "2024-05-19_12" "2024-05-21_12" "2024-05-23_12" "2024-05-25_12")

echo "Config, Result" >> fioAveragedResults

#A series of nested for loops to recurse through the directories
for (( layoutCount=0;layoutCount<=5;layoutCount++ ))
do
  for (( testTypeCount=0;testTypeCount<=5;testTypeCount++ ))
  do
    for (( diskNumberCount=0;diskNumberCount<=9;diskNumberCount++ ))
    do
      #First checks that the directory exits
      if [  -d $HOME/results/zfsresultsfio/"${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[$diskNumberCount]}" ]
      then
        #Recurses through the different use cases
        for (( useCaseCount=0;useCaseCount<=2;useCaseCount++ ))
        do
          #Resets all average values to 0
          caseAverage=0
          rwReadCaseAverage=0
          rwWriteCaseAverage=0

          #Recurses through all the repeated tests
          for (( fileDateCount=0;fileDateCount<=5;fileDateCount++ ))
          do
            #Extracts the relevant information to a variable
            extractedResult=$(cat $HOME/results/zfsresultsfio/${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]}${fileDate[fileDateCount]} | grep -A11 "Run status")

            #The rw and randrw tests provide both read and write results and so need to be handled differently
            if [ "$(echo $extractedResult | grep "READ")" ] && [ "$(echo $extractedResult | grep "WRITE")" ]
            then
              #Extracts just the provided number from the rest of the data using regular expression or regex. Looks through the provided input until it reaches the point where "bw=" is behind it,, then outputs all numbers and . until it finds either "MiB" or "KiB"
              readCurrentReading=$(echo "$extractedResult" |  grep -w "READ" | grep -oP "(?<=bw=)[0-9.]+(?=MiB|KiB)")
              writeCurrentReading=$(echo "$extractedResult" | grep -w  "WRITE" | grep -oP "(?<=bw=)[0-9.]+(?=MiB|KiB)")

              #Checks to see whether the current value is in MiB
              if [ "$(echo "$extractedResult" | grep -w "READ" | grep -oP "(?<=bw=)[0-9.]+[KM]iB/s" | grep -o "MiB")" ]
                then
                  #Pipes the values into the bc function to get the running total as bash can only deal with integers
                  rwReadCaseAverage=$(echo "$rwReadCaseAverage" + "$readCurrentReading" | bc -l)
                  rwWriteCaseAverage=$(echo "$rwWriteCaseAverage" + "$writeCurrentReading" | bc -l)

              #Checks to see whether the current value is in KiB
              elif [ "$( echo "$extractedResult" | grep -w "READ" | grep -oP "(?<=bw=)[0-9.]+[KM]iB/s" | grep "KiB")" ]
              then
                #If the value is in KiB, it is first converted to MiB
                readCurrentReading=$(echo "$readCurrentReading / 1024" | bc -l)
                writeCurrentReading=$(echo "$writeCurrentReading / 1024" | bc -l)


                rwReadCaseAverage=$(echo "$rwReadCaseAverage" + "$readCurrentReading" | bc -l)
                rwWriteCaseAverage=$(echo "$rwWriteCaseAverage" + "$writeCurrentReading" | bc -l)
              else
                echo "Unknown conversion"
              fi

            else
              #Does the same as the above, but only deals with one value
              currentReading=$(echo "$extractedResult" | grep -oP "(?<=bw=)[0-9.]+(?=MiB|KiB)")

              if [ "$(echo "$extractedResult" | grep -oP "(?<=bw=)[0-9.]+[KM]iB/s" | grep "MiB")" ]
                then
     	          caseAverage=$(echo "$caseAverage" + "$currentReading" | bc -l)
                elif [ "$( echo "$extractedResult" | grep -oP "(?<=bw=)[0-9.]+[KM]iB/s" | grep "KiB")" ]
                then
                  currentReading=$(echo "$currentReading / 1024" | bc -l)
                  caseAverage=$(echo "$caseAverage + $currentReading" | bc -l)
                else
                  echo "Unknown conversion"
              fi
            fi
          done


          #Checks to see whether it was rw or randrw test, if yes, then the value used by all other tests will be 0
          if [[ "$caseAverage" == 0 ]]
          then
            #Divides the running total by the number of tests to get the average. Scale is set to 1 so the value will be rounded to 1 decimal place
            rwReadCaseAverage=$(echo "scale=3; $rwReadCaseAverage / 6" | bc -l)
            rwWriteCaseAverage=$(echo "scale=3; $rwWriteCaseAverage / 6" | bc -l)

            #Outputs the averaged value
            echo "${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]} Read"",""$rwReadCaseAverage" >> fioAveragedResults
            echo "${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]} Write"",""$rwWriteCaseAverage" >> fioAveragedResults
          elif [[ "$caseAverage" != 0 ]]
          then
            #Does the same as the above with just one value
            caseAverage=$(echo "scale=3; $caseAverage / 6"  | bc -l)

            echo "${layout[layoutCount]}/${testType[testTypeCount]}/${diskNumber[diskNumberCount]}/${useCase[useCaseCount]}"",""$caseAverage" >> fioAveragedResults
          else
           echo "Unknown average" >> fioAveragedResults
          fi
        done
      fi
    done
  done
done
