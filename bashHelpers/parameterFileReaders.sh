#!/bin/bash

makeProcessedFileList(){
    
    # We fake SINGLE_END here : the visualisation files are "one per sample", i.e. they look like single end data reading .

    # Check how many columns we have.
    test=0
    test=$( cut -f 3 ./GEO_processedFilePaths.txt | grep -vc "^\s*$" )

    # If we have 2 columns single end :
    if [ "${test}" -eq "0" ]; then
    fileList1=($( cut -f 2 ./GEO_processedFilePaths.txt ))
    cut -f 2 ./GEO_processedFilePaths.txt > forRead1.txt
        
    # If we have 3 columns single end :
    else
    cut -f 2,3 ./GEO_processedFilePaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//' > forRead1.txt
    fileList1=($( cat ./forRead1.txt ))    
    fi
    
}

processedParameterFileReader(){

    nameList=($( cut -f 1 ./GEO_processedFilePaths.txt ))

    makeProcessedFileList
    
    rm -f forRead1.txt

}

processedParameterFileTester(){

rm -f PROCESSEDfile_LOAD.err

# Here, simple uniq tests (and file existence tests) are fine.

makeProcessedFileList

    TEMPcount1=$(($( cut -f 1 GEO_processedFilePaths.txt | grep -c "" )))
    TEMPcount2=$(($( cat ./forRead1.txt | grep -c "" )))

# Printing possible errors..

if [ "${TEMPcount1}" -ne "${TEMPcount2}" ]; then
  echo "Found different amount of file NAMES (found ${TEMPcount1}) and file PATHS (found ${TEMPcount2}), . Correct your GEO_processedFilePaths.txt file !" >> PROCESSEDfile_LOAD.err ;processedDataOK=0; 
fi

    TEMPcount1=$(($( cut -f 1 GEO_processedFilePaths.txt | grep -v '^\s*$' | grep -c "" )))
TEMPuniqcount1=$(($( cut -f 1 GEO_processedFilePaths.txt | grep -v '^\s*$' | sort | uniq -c | grep -c "" )))

    TEMPcount2=$(($( cat ./forRead1.txt | grep -v '^\s*$' | grep -c "" )))
TEMPuniqcount2=$(($( cat ./forRead1.txt | grep -v '^\s*$' | sort | uniq -c | grep -c "" )))

if [ "${TEMPcount1}" -ne "${TEMPuniqcount1}" ]; then
  echo "Some names ( column 1 ) describing your files are not unique ( you have same name more than once ). Correct your GEO_processedFilePaths.txt file !" >> PROCESSEDfile_LOAD.err ;processedDataOK=0;
fi
if [ "${TEMPcount2}" -ne "${TEMPuniqcount2}" ]; then
  echo "Some file paths ( column 2 ) of your files are not unique ( you have same file path more than once ). Correct your GEO_processedFilePaths.txt file !" >> PROCESSEDfile_LOAD.err ;processedDataOK=0;
fi

# Then, file existence tests ..

for k in $( seq 0 $((${#fileList1[@]} - 1)) ); do
    if [ ! -s "${fileList1[$k]}" ]; then
        echo "File ${fileList1[$k]} does not exist. Correct your GEO_processedFilePaths.txt file !" >> PROCESSEDfile_LOAD.err ;processedDataOK=0;
    fi
done

echo "Found these names and file paths :"
cut -f 1 GEO_processedFilePaths.txt | paste - forRead1.txt


unset fileList1
rm -f forRead1.txt

}

fastqParameterFileReader(){
    
    nameList=($( cut -f 1 ./GEO_fastqPaths.txt ))
    SINGLE_END=($( cat GEO_fastqFileType.txt | grep SINGLE_END | cut -f 2 ))
          GZIP=($( cat GEO_fastqFileType.txt | grep GZIP       | cut -f 2 ))
         LANES=($( cat GEO_fastqFileType.txt | grep LANES      | cut -f 2 ))
         
echo
echo "Pipeline was ran (previously) with parameters :"
echo ""
echo "SINGLE_END ${SINGLE_END}" 
echo "LANES ${LANES}" 
echo "GZIP ${GZIP}"
echo ""

    # Check how many columns we have.
    test=0
    if [ "${SINGLE_END}" -eq 0 ] ; then  
    test=$( cut -f 4 ./GEO_fastqPaths.txt | grep -vc "^\s*$" )
    else
    test=$( cut -f 3 ./GEO_fastqPaths.txt | grep -vc "^\s*$" )
    fi

    # If we have 3 columns paired end, or 2 columns single end :
    if [ "${test}" -eq "0" ]; then

    fileList1=($( cut -f 2 ./GEO_fastqPaths.txt ))
    
    if [ "${SINGLE_END}" -eq 0 ] ; then
    fileList2=($( cut -f 3 ./GEO_fastqPaths.txt ))
    fi
    
    # If we have 4 columns paired end, or 3 columns single end :
    else

    if [ "${SINGLE_END}" -eq 0 ] ; then
    cut -f 2,4 ./GEO_fastqPaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//' > forRead1.txt
    cut -f 3,4 ./GEO_fastqPaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//'  > forRead2.txt
    
    fileList1=($( cat ./forRead1.txt ))
    fileList2=($( cat ./forRead2.txt ))
    else
    cut -f 2,3 ./GEO_fastqPaths.txt | awk '{ print $2"\t"$1 }' | tr "," "\t" | awk '{for (i=2;i<=NF;i++) printf "%s/%s,",$1,$i; print ""}' | sed 's/,$//' | sed 's/\/\//\//' > forRead1.txt
    fileList1=($( cat ./forRead1.txt ))
    fi
    
    fi

    rm -f forRead1.txt forRead2.txt
    
    
}