#! /bin/bash


function _main(){
    ######################
    #### variables
    ######################
    # postgres related variables
    
    source $(dirname $0)/db_variables.sh
    source $(dirname $0)/include_function.sh

    banner "Creating or updating recovery.conf" "" 
     
    mkdir -p ${rec_file_backup}

    RECOVERY_TMP=$(mktemp -d)

    if  ! test -f "$original_recovery_file" && ! test -f "$primary_hostfile"; then 

        missingPrimaryHostfileMessage

    elif  test -f "$original_recovery_file" && test -f "$primary_hostfile"; then 

        log_info  "Both recovery file and primary hostfile is found"
        log_info  "creating the temporary recovery file"
               
        RECOVERY_TMP=$(mktemp -d)

        generating_recovery_file $RECOVERY_TMP $recovery_file_template $primary_hostfile
        log_info "Comparing the orginial with the temporary"
        compare_recovery $RECOVERY_TMP $original_recovery_file $alert_restart
        rm -rf $RECOVERY_TMP
        log_info "To check the file run: less ~postgres/11/main/recovery.conf"
    elif test -f "$original_recovery_file" ; then
        
        echo "Will create the primary_hostname only"

        create_primary_hostname ${original_recovery_file} ${primary_hostfile}
        #exec $(basename $0)
        # To rerun the script once the primary host file is created
        $(dirname $0)/$(basename $0) && exit


    fi

}




_main