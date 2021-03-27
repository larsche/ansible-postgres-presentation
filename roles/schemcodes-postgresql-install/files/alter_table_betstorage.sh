#!/bin/bash

## variables

baseDir=$(dirname $0)
doNotRun=${baseDir}/donotrun.out
confFile=${baseDir}/$(basename -s .sh $0).conf

echo $confFile

log(){
        MSG=$1
        echo "$(date +'%Y-%m-%d %T'): ${MSG}" | tee -a ${_log_file}
}


# writing the step down
# start
# check if postgres is running and not recovery
# check if the databse is present 
# check if the tables are present -- get this information from the file

# if so then run the query!
# soemthing that i realised was to create a  column with : seperate and run table name:  what to set

# 1) which is alter table only 

# table name: autovauum stuff

# 2) column 

# tablename: column name: statitic stuff 


