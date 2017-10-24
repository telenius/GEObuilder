#!/bin/bash

concludeFastqInspection(){
  
    echo
    echo "origR1Count ${origR1Count}"
    echo "origR2Count ${origR2Count}"
    echo "newR1Count  ${newR1Count}"
    echo "newR2Count  ${newR2Count}"
    echo
    
    if [ "${origR1Count}" -ne "${newR1Count}" ];then
        printThis="R1 Fastq file got corrupted in the process !"
        printToLogFile
        printThis="Exiting !"
        printToLogFile
        exit 1
    fi
    
    if [ "${SINGLE_END}" -eq 0 ] ; then
    if [ "${origR2Count}" -ne "${newR2Count}" ];then
        printThis="R2 Fastq file got corrupted in the process !"
        printToLogFile
        printThis="Exiting !"
        printToLogFile
        exit 1    
    fi
    fi  
    
}

inspectFastq(){
    
    printThis="Inspecting fetched fastq files  ..."
    printNewChapterToLogFile
    
    echo "Counting lines in R1 (original file) ${fileList1[$i]}.."
    origR1Count=0
    if [ "${GZIP}" -eq 0 ] ; then
    origR1Count=$(($( cat ${fileList1[$i]} | grep -Pv "^$" | grep -c "" )))
    else
    origR1Count=$(($( zcat ${fileList1[$i]} | grep -Pv "^$" | grep -c "" )))    
    fi
    echo "Found ${origR1Count} lines."    

    if [ "${SINGLE_END}" -eq 0 ] ; then
    
    echo "Counting lines in R2 (original file) ${fileList2[$i]}.."
    origR2Count=0
    if [ "${GZIP}" -eq 0 ] ; then
    origR2Count=$(($( cat ${fileList2[$i]} | grep -Pv "^$" | grep -c "" )))
    else
    origR2Count=$(($( zcat ${fileList2[$i]} | grep -Pv "^$" | grep -c "" )))
    fi
    echo "Found ${origR2Count} lines."
    
    fi

    echo
    echo "Counting lines in R1 (fetched, possible gzipped file) ${nameList[$i]}_R1.fastq(.gz).."
    newR1Count=0
    newR1Count=$(($( zcat ${nameList[$i]}_R1.fastq.gz | grep -c "" )))    
    echo "Found ${newR1Count} lines."    

    if [ "${SINGLE_END}" -eq 0 ] ; then
    echo "Counting lines in R2 (fetched, possible gzipped file) ${nameList[$i]}_R2.fastq(.gz).."
    newR2Count=$(($( zcat ${nameList[$i]}_R2.fastq.gz | grep -c "" )))
    echo "Found ${newR2Count} lines."
    
    fi

    concludeFastqInspection


}

inspectFastqMultilane(){
    
    #folderList=($( cut -f 1 ./PIPE_fastqPaths.txt ))
    #fileList1=($( cut -f 2 ./PIPE_fastqPaths.txt ))
    #fileList2=($( cut -f 3 ./PIPE_fastqPaths.txt ))
    
    printThis="Inspecting fetched fastq files (we have $LANES lanes)..."
    printNewChapterToLogFile
   

    # One lane at a time.. 
    allLanes=${fileList1[$i]}

    echo "Counting lines in R1 (original file) ${fileList1[$i]} .."
    origR1Count=0
    for l in $( seq 1 ${LANES[@]} ); do
        echo "Lane no $l .."
        
        
        currentLane=$( echo ${allLanes} | sed s'/,.*$//' )
        if [ "${GZIP}" -eq 0 ] ; then
           tempCount=$(($( cat ${currentLane} | grep -Pv "^$" | grep -c "" )))
           origR1Count=$((${origR1Count}+${tempCount}))
        else
           tempCount=$(($( zcat ${currentLane} | grep -Pv "^$" | grep -c "" )))
           origR1Count=$((${origR1Count}+${tempCount}))
        fi
        
        # Saving rest and looping to next round..
        removeThis=$( echo ${currentLane} | sed 's/\//\\\//g' )
        restOfLanes=$( echo ${allLanes} | sed s'/'${removeThis}',//' )
        echo "Rest of lanes (still to be counted) : ${restOfLanes}"
        allLanes=${restOfLanes}  
    done
    
    if [ "${SINGLE_END}" -eq 0 ] ; then
    
    # One lane at a time.. 
    allLanes=${fileList2[$i]}

    echo ""
    echo "Counting lines in R2 (original file) ${fileList2[$i]}.."
    origR2Count=0
    for l in $( seq 1 ${LANES[@]} ); do
        echo "Lane no $l .."
        
        currentLane=$( echo ${allLanes} | sed s'/,.*$//' )
        if [ "${GZIP}" -eq 0 ] ; then
           tempCount=$(($( cat ${currentLane} | grep -Pv "^$" | grep -c "" )))
           origR2Count=$((${origR2Count}+${tempCount}))
        else
           tempCount=$(($( zcat ${currentLane} | grep -Pv "^$" | grep -c "" )))
           origR2Count=$((${origR2Count}+${tempCount}))
        fi
        
        # Saving rest and looping to next round..
        removeThis=$( echo ${currentLane} | sed 's/\//\\\//g' )
        restOfLanes=$( echo ${allLanes} | sed s'/'${removeThis}',//' )
        echo "Rest of lanes (still to be counted) : ${restOfLanes}"
        allLanes=${restOfLanes}  
    done
    
    fi
    
    echo
    echo "Counting lines in R1 (fetched, combined, gzipped file) ${nameList[$i]}_R1.fastq.gz .."
    newR1Count=0
    newR1Count=$(($( zcat ${nameList[$i]}_R1.fastq.gz | grep -c "" )))    
    echo "Found ${newR1Count} lines."    

    if [ "${SINGLE_END}" -eq 0 ] ; then
    echo "Counting lines in R2 (fetched, combined, gzipped file) ${nameList[$i]}_R2.fastq.gz .."
    newR2Count=$(($( zcat ${nameList[$i]}_R2.fastq.gz | grep -c "" )))
    echo "Found ${newR2Count} lines."
    fi
        
    concludeFastqInspection
    
}

overwriteItNow(){
        
        printThis="There was an existing file ${overwriteThisFile} in FILES folder !"
        printToLogFile
        printThis="WILL NOW OVERWRITE ! "
        printToLogFile
        
        nowtime=$( date +%d%b%Y_%H_%M )
        echo "Overwritten ${overwriteThisFile} in FILES folder at ${nowtime} - run started at ${timestamp}" >> ../WARNING_some_files_were_overwritten.txt
        
        rm -f ${overwriteThisFile}
        cp ${overwriteWithThisFile} ${overwriteThisFile}
        
}

GEOfetchFastq(){
    
    printThis="Fetching fastq files  ..."
    printNewChapterToLogFile

    printThis="${fileList1[$i]}"
    printToLogFile
    
    if [ "${GZIP}" -eq 0 ] ; then
    
    echo "cp ${fileList1[$i]} ./${nameList[$i]}_R1.fastq"
    rm -f ${nameList[$i]}_R1.fastq
    cp "${fileList1[$i]}" ./${nameList[$i]}_R1.fastq
    
    testedFile="${nameList[$i]}_R1.fastq"
    doTempFileTesting
 
    echo "gzip ${nameList[$i]}_R1.fastq"   
    gzip ${nameList[$i]}_R1.fastq
    
    else
    
    echo "cp ${fileList1[$i]} ./${nameList[$i]}_R1.fastq.gz"
    # We allow overwrite but we give warning here !
    if [ -s ${nameList[$i]}_R1.fastq.gz ]; then
        overwriteThisFile="${nameList[$i]}_R1.fastq.gz"
        overwriteWithThisFile="${fileList1[$i]}"
        overwriteItNow
    else
        cp "${fileList1[$i]}" ./${nameList[$i]}_R1.fastq.gz
    fi
    
    fi
    
    testedFile="${nameList[$i]}_R1.fastq.gz"
    doTempFileTesting
    

    if [ "${SINGLE_END}" -eq 0 ] ; then
    
    printThis="${fileList2[$i]}"
    printToLogFile
    
    if [ "${GZIP}" -eq 0 ] ; then
    
    echo "cp ${fileList2[$i]} ./${nameList[$i]}_R2.fastq"
    rm -f ${nameList[$i]}_R2.fastq
    cp "${fileList2[$i]}" ./${nameList[$i]}_R2.fastq
    
    testedFile="${nameList[$i]}_R2.fastq"
    doTempFileTesting

    echo "gzip ${nameList[$i]}_R2.fastq"
    gzip ${nameList[$i]}_R2.fastq
    
    else
    
    echo "cp ${fileList2[$i]} ./${nameList[$i]}_R2.fastq.gz"
    # We allow overwrite but we give warning here !
    if [ -s ${nameList[$i]}_R2.fastq.gz ]; then
        overwriteThisFile="${nameList[$i]}_R2.fastq.gz"
        overwriteWithThisFile="${fileList2[$i]}"
        overwriteItNow
    else
        cp "${fileList2[$i]}" ./${nameList[$i]}_R2.fastq.gz        
    fi
    
    fi

    testedFile="${nameList[$i]}_R2.fastq.gz"
    doTempFileTesting
    
    fi

    echo
    echo "Fetched fastqs :"
    ls -lh | grep fastq | grep ${nameList[$i]} | cut -d " " -f 1,2,3,4 --complement
    
}

GEOfetchFastqMultilane(){
    
    #folderList=($( cut -f 1 ./PIPE_fastqPaths.txt ))
    #fileList1=($( cut -f 2 ./PIPE_fastqPaths.txt ))
    #fileList2=($( cut -f 3 ./PIPE_fastqPaths.txt ))
    
    printThis="Fetching fastq files (we have $LANES lanes)..."
    printNewChapterToLogFile

    echo "Read1 - generating combined fastq.."
    printThis="${fileList1[$i]}"
    printToLogFile
    
    # Make temp folder to do this
    
    rm -rf TEMP_folderForMultilaneCombining
    mkdir TEMP_folderForMultilaneCombining
    cd TEMP_folderForMultilaneCombining

    # One lane at a time.. catenating files !
    rm -f ./${nameList[$i]}_R1.fastq 
    allLanes=${fileList1[$i]}

    for l in $( seq 1 ${LANES[@]} ); do
        echo ""
        echo "Lane no $l .."
        currentLane=$( echo ${allLanes} | sed s'/,.*$//' )
        echo "Current lane : ${currentLane}"
        
        if [ "${GZIP}" -eq 0 ] ; then
           cat "${currentLane}" >> ./${nameList[$i]}_R1.fastq
        else
           zcat "${currentLane}" >> ./${nameList[$i]}_R1.fastq
        fi
        
        # Saving rest and looping to next round..
        removeThis=$( echo ${currentLane} | sed 's/\//\\\//g' )
        restOfLanes=$( echo ${allLanes} | sed s'/'${removeThis}',//' )
        echo "Rest of lanes (still to be added to the file) : ${restOfLanes}"
        allLanes=${restOfLanes}  
    done
    # Removing empty lines
    grep -Pv "^$" ${nameList[$i]}_R1.fastq >  temp.fastq
    mv -f temp.fastq ${nameList[$i]}_R1.fastq
    
    testedFile="${nameList[$i]}_R1.fastq"
    doTempFileTesting
    
    if [ "${SINGLE_END}" -eq 0 ] ; then
    
    echo ""
    echo "Read2 - generating combined fastq.."
    printThis="${fileList2[$i]}"
    printToLogFile

    rm -f ./${nameList[$i]}_R2.fastq 
    allLanes=${fileList2[$i]}
    for l in $( seq 1 ${LANES[@]} ); do
        echo ""
        echo "Lane no $l .."
        currentLane=$( echo ${allLanes} | sed s'/,.*$//' )
        echo "Current lane : ${currentLane}"
        
        if [ "${GZIP}" -eq 0 ] ; then
           cat "${currentLane}" >> ./${nameList[$i]}_R2.fastq
        else
           zcat "${currentLane}" >> ./${nameList[$i]}_R2.fastq
        fi
        
        # Saving rest and looping to next round..
        removeThis=$( echo ${currentLane} | sed 's/\//\\\//g' )
        restOfLanes=$( echo ${allLanes} | sed s'/'${removeThis}',//' )
        echo "Rest of lanes (still to be added to the file) : ${restOfLanes}"
        allLanes=${restOfLanes}   
    done
    # Removing empty lines
    grep -Pv "^$" ${nameList[$i]}_R2.fastq >  temp.fastq
    mv -f temp.fastq ${nameList[$i]}_R2.fastq
    
    testedFile="${nameList[$i]}_R2.fastq"
    doTempFileTesting
    
    fi
    
    echo "gzip ${nameList[$i]}_R1.fastq"
    gzip ${nameList[$i]}_R1.fastq
    testedFile="${nameList[$i]}_R1.fastq.gz"
    doTempFileTesting
    
    if [ "${SINGLE_END}" -eq 0 ] ; then
    echo "gzip ${nameList[$i]}_R2.fastq"
    gzip ${nameList[$i]}_R2.fastq
    testedFile="${nameList[$i]}_R2.fastq.gz"
    doTempFileTesting
    fi
    
    cd ..
    
    # We allow overwrite but we give warning here !
    if [ -s ${nameList[$i]}_R1.fastq.gz ]; then
        overwriteThisFile="${nameList[$i]}_R1.fastq.gz"
        overwriteWithThisFile="TEMP_folderForMultilaneCombining/${nameList[$i]}_R1.fastq.gz"
        overwriteItNow
    else
        mv -f TEMP_folderForMultilaneCombining/${nameList[$i]}_R1.fastq.gz .
    fi

    if [ "${SINGLE_END}" -eq 0 ] ; then
    if [ -s ${nameList[$i]}_R2.fastq.gz ]; then
        overwriteThisFile="${nameList[$i]}_R2.fastq.gz"
        overwriteWithThisFile="TEMP_folderForMultilaneCombining/${nameList[$i]}_R2.fastq.gz"
        overwriteItNow
    else
        mv -f TEMP_folderForMultilaneCombining/${nameList[$i]}_R2.fastq.gz .
    fi
    fi
    
    rm -rf TEMP_folderForMultilaneCombining
    
    testedFile="${nameList[$i]}_R1.fastq.gz"
    doTempFileTesting   
    testedFile="${nameList[$i]}_R2.fastq.gz"
    doTempFileTesting
    
    echo
    echo "Generated merged fastqs :"
    ls -lh | grep fastq | grep ${nameList[$i]} | cut -d " " -f 1,2,3,4 --complement
    
}

GEOfetchProcessed(){
    
    printThis="Fetching processed file  ..."
    printToLogFile

    printThis="${fileList1[$i]}"
    printToLogFile
    
    if [ "${PACKED_PROCESSED_FILES}" -ne 0 ] ; then
    
    echo "cp ${fileList1[$i]} ./${nameList[$i]}.${fileType}"
    # If we couldn't : there is existing file with the same name !
    # We allow overwrite but we give warning here !
    if [ -s ${nameList[$i]}.${fileType} ]; then
        overwriteThisFile="${nameList[$i]}.${fileType}"
        overwriteWithThisFile="${fileList1[$i]}"
        overwriteItNow
    else
        cp "${fileList1[$i]}" ./${nameList[$i]}.${fileType}
    fi
    
    testedFile="${nameList[$i]}.${fileType}"
    doTempFileTesting
    
    fi
 
    if [ "${PACKED_PROCESSED_FILES}" -eq 0 ] ; then
        
    rm -rf TEMP_folderForGzipping
    mkdir TEMP_folderForGzipping
    cd TEMP_folderForGzipping
    
    echo "cp ${fileList1[$i]} ./${nameList[$i]}.${fileType}"
    cp "${fileList1[$i]}" ./${nameList[$i]}.${fileType}
    
    testedFile="${nameList[$i]}.${fileType}"
    doTempFileTesting
    
    echo "gzip ${nameList[$i]}.${fileType}"   
    gzip ${nameList[$i]}.${fileType}
    
    testedFile="${nameList[$i]}.${fileType}.gz"
    doTempFileTesting
    
    cd ..

    # We allow overwrite but we give warning here ! 
    if [ -s ${nameList[$i]}.${fileType}.gz ]; then
        overwriteThisFile="${nameList[$i]}.${fileType}.gz"
        overwriteWithThisFile="TEMP_folderForGzipping/${nameList[$i]}.${fileType}.gz"
        overwriteItNow
    else
        mv -f TEMP_folderForGzipping/${nameList[$i]}.${fileType}.gz .
    fi
    
    rm -rf TEMP_folderForGzipping
    
    testedFile="${nameList[$i]}.${fileType}.gz"
    doTempFileTesting

    fi

    echo
    echo "Fetched files for sample ${nameList[$i]} :"
    ls -lh | grep ${nameList[$i]} | cut -d " " -f 1,2,3,4 --complement
    
}

inspectProcessed(){
    
    printThis="Inspecting processed file  ..."
    printNewChapterToLogFile
    
    oldSum=0
    newSum=0
    
    oldSum=$( md5sum ${fileList1[$i]} | sed 's/\s.*//' )
    if [ "${PACKED_PROCESSED_FILES}" -eq 0 ] ; then
        rm -f TEMPfile TEMPfile.gz
        cp ${nameList[$i]}.${fileType}.gz TEMPfile.gz
        gzip -d TEMPfile.gz
        newSum=$( md5sum TEMPfile | sed 's/\s.*//' )
        rm -f TEMPfile TEMPfile.gz
    else
        newSum=$( md5sum ${nameList[$i]}.${fileType} | sed 's/\s.*//' )
    fi
    
    echo
    echo "oldSum ${oldSum}"
    echo "newSum ${newSum}"
    echo
    
    if [ "${oldSum}" != "${newSum}" ];then
        printThis="Processed data file got corrupted in the process !"
        printToLogFile
        printThis="Exiting !"
        printToLogFile
        exit 1
    fi
    
}

