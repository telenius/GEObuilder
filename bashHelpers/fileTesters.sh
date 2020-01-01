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

doTempFileTesting(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFile=""    
    
    if [ ! -r "${testedFile}" ] || [ ! -e "${testedFile}" ] || [ ! -f "${testedFile}" ] || [ ! -s "${testedFile}" ]; then
      echo "Temporary file not found or empty file : ${testedFile}" >&2
      echo "EXITING!!" >&2
      exit 1
    fi
}

doTempFileInfo(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFile=""    
    
    if [ ! -r "${testedFile}" ] || [ ! -e "${testedFile}" ] || [ ! -f "${testedFile}" ] || [ ! -s "${testedFile}" ]; then
      echo "Temporary file not found or empty file : ${testedFile}" >&2
      echo "Continuing, but may create some NONSENSE data.." >&2
      #echo "EXITING!!" >&2
      #exit 1
    fi
}

doTempFileFYI(){
    
    # NEEDS THIS TO BE SET BEFORE CALL :
    # testedFile=""    
    
    if [ ! -r "${testedFile}" ] || [ ! -e "${testedFile}" ] || [ ! -f "${testedFile}" ] || [ ! -s "${testedFile}" ]; then
      echo "Probably harmless : file not found or empty file : ${testedFile}" >&2
      
      #echo "EXITING!!" >&2
      #exit 1
    fi
}
