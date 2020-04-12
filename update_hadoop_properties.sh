#!/usr/bin/env bash

#
# Script Name	  : update_hadoop_properties.sh
# Description	  : This Script is developed to update bulk properties in hdp cluster
# Author        : Gulshad Ansari
# LinkedIn      : https://linkedin.com/in/gulshad/
#
#

LOC=`pwd`
CLUSTER_PROPERTIES=mycluster.properties
_TARGETSCRIPT=/var/lib/ambari-server/resources/scripts/configs.py
source $LOC/$CLUSTER_PROPERTIES

_CMD="${_TARGETSCRIPT} -a set -l localhost -n ${CLUSTER_NAME} -t ${AMBARI_PORT} -s ${AMBARI_PROTOCOL} -u ${AMBARI_ADMIN_USER} -p ${AMBARI_ADMIN_PASSWORD}"

function checkforTarget () {
   if [ ! -d $_TARGETSCRIPT ]; then
      echo "$(date) Missing ($_TARGETSCRIPT). Make sure you execute this script from ambari-server node"
      exit 1
   fi
}

function checkRequiredFields() {
   if [ -z "$CLUSTER_NAME" ||  ]; then
      echo "Required fields are missing. Kindly update 'mycluster.properties' file"
      exit 1
   fi 
}

function updateProperties() {
  for i in `cat updateme.txt`
    do
      _KEY=`echo $i | cut -d "=" -f 1`
      _VALUE=`echo $i | cut -d "=" -f 2`
      ${_CMD} -k ${_KEY} -v "${_VALUE}"
      if [ $? -eq 0 ]; then
        echo "Updated ${_KEY} to ${_VALUE} successfully"
      else
        echo "Something went wrong, Property ${_KEY} update failed..."
        exit 1
      fi
    done
}

function restartAllRequiredServices() {
  echo "$(date +"%Y-%m-%d %H:%M:%S,%3N") Command submitted to restart all required services..." 1>&2
  curl -ikv -u ${AMBARI_ADMIN_USER}:"${AMBARI_ADMIN_PASSWORD}" -H "X-Requested-By:ambari" "${AMBARI_PROTOCOL}://${AMBARI_HOST}:${AMBARI_PORT}/api/v1/clusters/${$CLUSTER_NAME}/requests" -X POST --data '{"RequestInfo":{"command":"RESTART","context":"Restart all required services","operation_level":"host_component"},"Requests/resource_filters":[{"hosts_predicate":"HostRoles/stale_configs=true"}]}'
}



# Action starts here!
checkforTarget
checkRequiredFields
updateProperties
restartAllRequiredServices

#End of Script
