#!/bin/bash

usage(){

echo
echo
echo "GEObuilder.sh - helper script to generate GEO submission archives."
echo
echo "-h/--help     Show this help "
echo "--unpackedProcessedFiles  -If your visualisation files are human-readable (not bw,bb,bam tar,gz,zip)"
echo "--onlyParamFiles          -If you only want parameter files, not a full run (to customise the input file paths yourself)"
echo "--noTarring               -If you will run several GEObuilder runs, and this is not the last of them"
echo "--window                  -If you run for pipeline output, and want the filtered_windowed.bw instead of filtered_pileup.bw "
echo
echo "Details below :"
echo
echo "Run the script in an empty folder (or a folder where you have previous GEObuilder output(s) ) "
echo
echo "This script needs 1 (a) or 3 (c) parameter files"
echo
echo "a) PIPELINE output auto-geo ( only DNase/ATAC/ChIP pipe or PYRAMID : CC3/CC4 pipes not supported yet - 15Feb2017 )"
echo "b) PIPELINE output auto-geo - customised !"
echo 
echo "c) CUSTOM LOCATION auto-geo"
echo
echo "d) UPDATING existing GEO data collection "
echo "  (running the script multiple times to a same folder)"
echo
echo "-----------------------------------------"
echo
echo "a) PIPELINE output auto-geo"
echo
echo "you need to just point to the folder(s) where you ran your pipe "
echo "(where your PIPE_fastqPaths.txt parameters.log and run.sh are) , like this :"
echo
echo "GEO_piperun.txt"
echo
echo "runname1    /this/is/where/I/run/the/pipe <- this folder contains the PIPE_fastqPaths.txt parameters.log and run.sh"
echo "runname2    /this/is/where/I/run/the/pipeAsWell <- ( for PYRAMID runs this is the /PipeRun/ folder )"
echo "runname3    /this/is/where/I/run/the/pipeThirdRun"
echo "runname4    /this/is/where/I/run/the/pipeFourth"
echo
echo "To use PYRAMID pipe output, give flag --pyramid"
echo
echo "You can select to use the filtered_window.bw as the processed file, instead of filtered_pileup.bw "
echo "by giving flag --window "
echo
echo "-----------------------------------------"
echo
echo "b) PIPELINE output auto-geo - customised !"
echo
echo "The above (a) user case will auto-generate parameter files GEO_fastqPaths.txt and GEO_processedDataPaths.txt and GEO_fastqFileType.txt"
echo
echo "If you want to MODIFY these before proceeding further in the GEO generation (changing the processed data files, changing sample names etc),"
echo "you can stop the pipe at this point, and manually edit the files before actually running GEO generation."
echo
echo "Add flag --onlyParamFiles"
echo
echo
echo "-----------------------------------------"
echo
echo "c) CUSTOM LOCATION auto-geo"
echo
echo "The above (a) user case will auto-generate parameter files GEO_fastqPaths.txt , GEO_processedDataPaths.txt , and GEO_fastqFileType.txt"
echo "You can PREVENT that, by giving them manually, instead of the default parameter file GEO_piperun.txt"
echo
echo "optional GEO_fastqPaths.txt         (read in data from custom locations)"
echo "optional GEO_processedDataPaths.txt (read in processed files from custom locations)"
echo "optional GEO_fastqFileType.txt      (read in the lane count, gzip status, single-endedness)"
echo
echo "The pipe will store fastqs (GEO_fastqPaths.txt,GEO_fastqFileType.txt) and/or"
echo "processed data files (GEO_processedDataPaths.txt) ."
echo
echo "__GEO_fastqPaths.txt ______________________________________"
echo
echo "  You can use the pipeline output PIPE_fastqPaths.txt as the GEO_fastqPaths.txt :"
echo "  cp /where/you/run/it/PIPE_fastqPaths.txt GEO_fastqPaths.txt"
echo
echo "  If you didn't run the pipeline, construct the GEO_fastqPaths.txt, like you would build PIPE_fastqPaths.txt"
echo "  Instructions here : http://sara.molbiol.ox.ac.uk/public/telenius/NGseqBasicManual/intraWIMM/DnaseCHIPpipe_TUTORIAL_intraWIMM.pdf"
echo
echo
echo "__GEO_fastqFileType.txt ______________________________________"
echo
echo "  You can check the correct GEO_fastqFileType.txt values from our run.sh (with which you ran the pipeline) :"
echo "  Or, if you didn't run the pipeline, fill it up, like this :"
echo
echo "  SINGLE_END      0"
echo "  GZIP            1 (0 : files are not .gz packed, 1: files are .gz packed)"
echo "  LANES           2"
echo
echo "NOTE !!! all samples have to have the same values for all 3 of these."
echo "        (i.e. ALL pe or ALL se, ALL gzipped or ALL not gzipped, all 2 lanes, or all 1 lane)"
echo "         If all your samples are not the same here - see (d) below : to run several GEObuilder runs to a single folder !"
echo
echo
echo "__GEO_processedFilePaths.txt ______________________________________"
echo
echo "  The GEO_processedFilePaths.txt point to bigwig/bigbed/region-bam etc analysed files, "
echo "  If these human-readable files (not bw,bb,bam tar,gz,zip), tell it by using flag --unpackedProcessedFiles"
echo
echo "  Provide GEO_processedFilePaths.txt in this format :"
echo
echo "  Samplename_genome_filedescription    /this/is/where/my/file/is.bw"
echo
echo "  For example : "
echo "  CD34pos_hg19_pileup    /this/is/where/my/file/is/pileup.bw"
echo
echo
echo "-----------------------------------------"
echo
echo "d) UPDATING existing GEO data collection "
echo "  (running the script multiple times to a same folder)"
echo
echo "If your GEO_fastqFileType.txt parameters (SINGLE_END, GZIP, LANES) differ between your samples,"
echo "you need to run the generator multiple times in the same folder, to store all your data."
echo
echo "For the first runs (when you are still missing some data sets from the archive-to-be),"
echo "you can speed up the run by disabling the 'generation of the final archive' by setting flag --noTarring "
echo


echo
exit 0

}




