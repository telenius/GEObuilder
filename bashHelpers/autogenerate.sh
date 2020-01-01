#!/bin/bash

##########################################################################
# Copyright 2017, Jelena Telenius (jelena.telenius@imm.ox.ac.uk)         #
#                                                                        #
# This file is part of GEObuilder .                                      #
#                                                                        #
# GEObuilder is free software: you can redistribute it and/or modify     #
# it under the terms of the MIT license.
#
#
#                                                                        #
# GEObuilder is distributed in the hope that it will be useful,          #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# MIT license for more details.
#                                                                        #
# You should have received a copy of the MIT license
# along with GEObuilder.  
##########################################################################

autogenerate(){

printThis="Autogenerating the parameter files GEO_fastqFileType.txt GEO_fastqPaths.txt and GEO_processedFilePaths.txt"
printToLogFile

  nameList=($( cut -f 1 ./GEO_piperun.txt ))
folderList=($( cut -f 2 ./GEO_piperun.txt ))

if [ "${PYRAMIDPIPE}" -ne 1 ];then
    echo
    echo "Will autogenerate parameters for these pipeline runs : "
    echo
else
    echo
    echo "Will autogenerate parameters for these PYRAMID pipeline runs : "
    echo
fi

for (( i=0; i<=$(( ${#folderList[@]} -1 )); i++ ))
do
echo "runName ${nameList[$i]}"
echo "runFolder ${folderList[$i]}"
echo
done

# Folder into which put the runtime parameter.log files (for excel sheet fill help)

mkdir logsToHelpInExcelFilling

# Fastq files

rm -f GEO_fastqPaths.txt


for (( i=0; i<=$(( ${#folderList[@]} -1 )); i++ ))
do
cat ${folderList[$i]}/PIPE_fastqPaths.txt | sed 's/^/'${nameList[$i]}'_/' >> GEO_fastqPaths.txt
done

# Run params

rm -f GEO_fastqFileType.txt
echo -e "# name\tSINGLE_END\tGZIP\tLANES" >> GEO_fastqFileType.txt

for (( i=0; i<=$(( ${#folderList[@]} -1 )); i++ ))
do
# As the gz parameter is not printed properly in most dnase pipe versions, we do it like this :
GZIP=$(($( cat ${folderList[$i]}/PIPE_fastqPaths.txt | grep -c "\.gz" )))
if [ "${GZIP}" -gt 0 ];then
GZIP=1
fi

# Other params of interest (these are printed properly)

# SINGLE_END 0  (TRUE=1, FALSE=0)
# LANES 1
    
SINGLE_END=$(($( cat ${folderList[$i]}/parameters.log | grep SINGLE_END | sed 's/.*SINGLE_END\s*//' | sed 's/\s.*//' )))
     LANES=$(($( cat ${folderList[$i]}/parameters.log | grep LANES      | sed 's/.*LANES\s*//' | sed 's/\s.*//' )))

echo -e "${nameList[$i]}\t${SINGLE_END}\t${GZIP}\t${LANES}" >> GEO_fastqFileType.txt

done

# Printing it, and checking that all is fine ..
echo
cat GEO_fastqFileType.txt
echo

singleEndCount=$(($( cat GEO_fastqFileType.txt | grep -v '^#' | cut -f 2 | uniq | grep -c "" )))
     gzipCount=$(($( cat GEO_fastqFileType.txt | grep -v '^#' | cut -f 3 | uniq | grep -c "" )))
    lanesCount=$(($( cat GEO_fastqFileType.txt | grep -v '^#' | cut -f 4 | uniq | grep -c "" )))
    
# Overwriting ..

rm -f GEO_fastqFileType.txt
echo "SINGLE_END ${SINGLE_END}" >> GEO_fastqFileType.txt
echo "LANES ${LANES}" >> GEO_fastqFileType.txt
echo "GZIP ${GZIP}" >> GEO_fastqFileType.txt
sed -i 's/\s\s*/\t/g' GEO_fastqFileType.txt

mixingUp=0
if [ "${singleEndCount}" -ne 1 ];then
        printThis="Single end and Paired end data ran in single GEObuilder run - not supported !"
        printToLogFile
        mixingUp=1
fi

if [ "${gzipCount}" -ne 1 ];then
        printThis="Gzipped and non-gzipped original fastq fata ran in single GEObuilder run - not supported !"
        printToLogFile
        mixingUp=1
fi

if [ "${lanesCount}" -ne 1 ];then
        printThis="Multi-lane and single lane (or different depth multi-lane) data ran in single GEObuilder run - not supported !"
        printToLogFile
        mixingUp=1
fi

if [ "${mixingUp}" -eq 1 ];then
        printThis="Exiting !"
        printToLogFile
        exit 1
fi


# Processed files

rm -f GEO_processedFilePaths.txt

# Windowed or not ?
datafilename="filtered_pileup.bw"
if [ "${WINDOW}" -eq 1 ];then
   datafilename="filtered_window.bw" 
fi

for (( i=0; i<=$(( ${#folderList[@]} -1 )); i++ ))
do

if [ "${PYRAMIDPIPE}" -ne 1 ];then
    
    for file in  ${folderList[$i]}/*/*/BigWigs/${datafilename} 
    do
       removeUptoHere=$( basename ${folderList[$i]})
       echo -en $( echo $file | sed 's/.*'${removeUptoHere}'//' | sed 's/\/BigWigs//' | sed 's/\//_/g' | sed 's/\.bw//' | sed 's/^/'${nameList[$i]}'_/' | sed 's/__*/_/g' )"\t" >> GEO_processedFilePaths.txt ;
       fp $file >> GEO_processedFilePaths.txt ;
    done
    
else
    
    for file in  ${folderList[$i]}/PipeOutput/BigWigs/${datafilename} 
    do
       removeUptoHere=$( basename ${folderList[$i]})
       echo -en $( echo $file | sed 's/.*'${removeUptoHere}'//' | sed 's/\/BigWigs//' | sed 's/\//_/g' | sed 's/\.bw//' | sed 's/^/'${nameList[$i]}'_/' | sed 's/__*/_/g' )"\t" >> GEO_processedFilePaths.txt ;
       fp $file >> GEO_processedFilePaths.txt ;
    done   
    
fi

# Helper files for excel sheet filling ..

cp ${folderList[$i]}/parameters.log logsToHelpInExcelFilling/${nameList[$i]}_pipeRuntimeParameters.log
if [ "${PYRAMIDPIPE}" -eq 1 ];then
cat ${folderList[$i]}/PyramidVersion.txt >> logsToHelpInExcelFilling/${nameList[$i]}_pipeRuntimeParameters.log    
fi

done

# Empty the lists - to not to meddle with the same ones used later.
unset nameList
unset folderList

}

