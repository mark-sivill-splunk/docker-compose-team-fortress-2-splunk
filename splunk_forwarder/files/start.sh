#!/bin/bash

#
# Author: Mark Sivill - Splunk
#
# Splunk forwarder start up script when docker image runs
#

#
# SPLUNK_HOME is set in docker image
#

  #
  # optionally override location of Splunk Server where data will be sent
  # this should be done if universal forwarder configuration has not been
  # baked in docker image already
  #
  if [ -z ${SPLUNK_FORWARDER_SERVER_PORT+x} ]
  then

    echo "***** Not setting up local outputs for Splunk Forwarder"

  else

    echo "***** Setting up local outputs for Splunk Forwarder"

    {
      echo "[tcpout]"
      echo "defaultGroup = default-autolb-group"
      echo "[tcpout:default-autolb-group]"
      echo "server = $SPLUNK_FORWARDER_SERVER_PORT"
      echo "[tcpout-server://${SPLUNK_FORWARDER_SERVER_PORT}]"
    } > $SPLUNK_HOME/etc/apps/tf2_forwarder_app/local/outputs.conf

  fi

  #
  # record if there is a valid outputs.conf
  #
  if [ ! -f $SPLUNK_HOME/etc/apps/tf2_forwarder_app/default/outputs.conf ] && [ ! -f $SPLUNK_HOME/etc/apps/tf2_forwarder_app/local/outputs.conf ]
  then

    echo "***** File /default/outputs.conf or /local/outputs.conf not defined for Splunk Forwarder"

  else

    SPLUNK_FORWARDER_OUTPUTS_DEFINED=true
    export SPLUNK_FORWARDER_OUTPUTS_DEFINED 

  fi

  #
  # if correct values provided then start splunk forwarder
  #
  if [ -z ${SPLUNK_FORWARDER_INDEX+x} ] || [ -z ${SPLUNK_FORWARDER_SOURCETYPE+x} ] || [ -z ${SPLUNK_FORWARDER_HOST+x} ] || [ -z ${SPLUNK_FORWARDER_OUTPUTS_DEFINED+x} ]
  then

    echo "***** Not all inputs/outputs are defined for Splunk Forwarder, so not starting Forwarder"
    exit 1

  else

    echo "***** Setting up Splunk Forwarder"

    # create splunk forwarder config
    {
      echo "[monitor:/var/log/team_fortress_2]"
      echo "disabled = false"
      echo "index = $SPLUNK_FORWARDER_INDEX"
      echo "sourcetype = $SPLUNK_FORWARDER_SOURCETYPE"
      echo "host = $SPLUNK_FORWARDER_HOST"
    } > $SPLUNK_HOME/etc/apps/tf2_forwarder_app/local/inputs.conf

    # debugging if needed - for SSL connection
    # sed -i -e 's/category.TcpOutputProc=INFO/category.TcpOutputProc=DEBUG/g' $SPLUNK_HOME/etc/log.cfg

    echo "***** Splunk Forwarder starting"

    # start splunk forwarder
    $SPLUNK_HOME/bin/splunk start
   
  fi

  echo "***** Running in loop to prevent docker container from stopping"

  while [ 1 ]
  do
    echo "***** Awake at `date -u`"
    sleep 10m
  done

