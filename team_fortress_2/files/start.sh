#!/bin/bash

#
# Author: Mark Sivill - Splunk
#
# Team Fortress 2 start up script when docker image runs
#

#
# TF2_HOME is set in docker image
#

  #
  # if correct tf2 config provided use it, or use default
  #
  if [ -z ${TEAM_FORTRESS_2_CONFIG+x} ]
  then

      echo "***** Team Fortress 2 config not set, using default instead"

  else

    if [ ! -f $TF2_HOME/serverfiles/tf/cfg/tf2server_${TEAM_FORTRESS_2_CONFIG}.cfg ]
    then

      echo "***** Team Fortress 2 config \"$TEAM_FORTRESS_2_CONFIG\" does not exist, using default instead"

    else

      echo "***** Changing default Team Fortress 2 config"

      # copy file across
      cp $TF2_HOME/serverfiles/tf/cfg/tf2server_${TEAM_FORTRESS_2_CONFIG}.cfg $TF2_HOME/serverfiles/tf/cfg/tf2server.cfg

    fi

  fi

  #
  # check if need to set password to play game
  #
  # create new file
  #
  if [ -z ${TEAM_FORTRESS_2_SV_PASSWORD+x} ]
  then

    echo "***** Team Fortress 2 removing player password"

    {
      echo "sv_password \"\""
    } > $TF2_HOME/serverfiles/tf/cfg/passwords.cfg

  else

    echo "***** Team Fortress 2 setting player password"

    {
      echo "sv_password \"${TEAM_FORTRESS_2_SV_PASSWORD}\""
    } > $TF2_HOME/serverfiles/tf/cfg/passwords.cfg

  fi

  #
  # check if need to set password for console,
  # if not set a long random password is used
  # so effectively stopping access to console
  #
  # append to file
  #
  if [ -z ${TEAM_FORTRESS_2_RCON_PASSWORD+x} ]
  then

    echo "***** Team Fortress 2 rcon password randomly set"

    {
      echo "rcon_password \"`head /dev/urandom | tr -cd 'a-zA-Z' | head -c 32`\""
    } >> $TF2_HOME/serverfiles/tf/cfg/passwords.cfg

  else

    echo "***** Team Fortress 2 rcon password set"

    {
      echo "rcon_password \"${TEAM_FORTRESS_2_RCON_PASSWORD}\""
    } >> $TF2_HOME/serverfiles/tf/cfg/passwords.cfg

  fi

  # check for team fortress 2 updates
  echo "***** Team Fortress 2 checking for update"
  ./tf2server update


  # start team fortress 2
  echo "***** Team Fortress 2 starting"
  ./tf2server start


  # forever loop to stop script from exiting and therefore stopping docker
  # loop to check for a tf2 updates

  echo "***** Team Fortress 2 now periodically checking for updates"

  while [ 1 ]
  do
    echo "***** Awake at `date -u`"
    ./tf2server update
    sleep 10m
  done

