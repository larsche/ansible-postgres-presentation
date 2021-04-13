#! /bin/bash

function banner()
{
    message=$1
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  printf "| %-40s |\n" "${message}"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

function log_info(){ 
    _error=${2:-INFO}
    _msg=$1   

    if [ "$_error" == "ERROR" ]; then
        _error="\033[37;41;5;1mERROR\033[0m"
    fi
    
    _msg_timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${_msg_timestamp} ${_error}: ${_msg}"
    
    
}

function exit_function(){
    log_info "exiting ...."
    exit $1
}

function create_recovery_conf(){
    # this will create a recovery file taht will be used to start off a standby script
    original_recovery_file=$1
    primary_hostname=$2

    echo "in function create_recovery_conf ${original_recovery_file} ${primary_hostname}"

}

function create_primary_hostname(){
    # get the hosts parameter fro the primary configuration in the original_recovery_file    
    original_recovery_file=$1
    hostfile=$2

    primary_host=$(cat $original_recovery_file | grep host | grep -v "^#.*" | sed  's/.*host=\(.*\) port.*/\1/')
    echo ${primary_host} > "${hostfile}"
    chown postgres:postgres ${hostfile}

}

function compare_recovery(){
    tmp_path=$1
    original_recovery_file=$2
    
    

    diff $original_recovery_file $tmp_path/recovery.conf_regenerated > diff_found.output 

    
    if [[ $(diff $original_recovery_file $tmp_path/recovery.conf_regenerated) ]]; then   
        log_info "Change found! Will take a copy and overwrite the recovery.conf file in the data folder"
        
        mkdir -p ${rec_file_backup}
        
        recovery_bu_filename="recovery.conf_backup_$(date +'%y%m%d_%H%M%S')"

        cp $original_recovery_file ${rec_file_backup}/${recovery_bu_filename}

        cp $tmp_path/recovery.conf_regenerated $original_recovery_file
        if [ $? -ne 0 ]; then
            log_info "There was an issue while moving the new recovery.conf file" "ERROR"
            log_info "Restoring the old file"
            cp ${rec_file_backup}/${recovery_bu_filename} $original_recovery_file
            exit_function 3
        else
            echo "A restart is required" > "$alert_restart"
        fi
        
    else
        log_info "No change found... can exit now!"
        exit_function 0
    fi
    

}


function generating_recovery_file(){
    tmp_path=$1
    recovery_file_template=$2
    primary_hostfile=$(cat $3)


    log_info "Generating the recovery.conf templated"

    sed -e "s/\${PRIMARY_HOST}/${primary_hostfile}/" ${recovery_file_template} > ${tmp_path}/recovery.conf_regenerated
}


function extract_pw(){
    
    recovery_file_template=$1

    test -f ${recovery_file_template} && cat $recovery_file_template | grep password | grep -v "^#.*" | sed  's/.*password=\(.*\) .*/\1/' || echo file does not exsits; exit 1

    ${recovery_file_template} 
}



function _psql(){
    su - postgres -c "psql -Aqt -U postgres -p 5432 -c \"$1\""
}

function ispostgresrunning(){
    _psql "select 1"
    if [ $? -eq 0 ]; then 
        return 1
    else
        return 0
    fi
}

function isstandby(){
    _psql "select  pg_is_in_recovery()"
}

# function start_backup(){
#     pws=$(extract_pw ${recovery_file_template})
#     su - postgres -c "export PGPASSWORD=${pws} && /usr/lib/postgresql/{{ postgres_version }}/bin/pg_basebackup -h $(cat ${primary_hostfile}) -U replication -P  -R -X s -D /var/lib/postgresql/{{ postgres_version }}/main" || return 1
# }

function missingPrimaryHostfileMessage(){
    log_info "This is either a primary or the primary_hostfile is not set"
    log_info "If this is suppose to be a Stand-by, then create the primary_hostfile with the hostname inside the file"
    log_info "Hint: run the following"
    log_info "##################################################"
    log_info "echo <primary_hostname> > ${primary_hostfile} "
    log_info "##################################################"
    
}