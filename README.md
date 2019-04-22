# docker-compose-team-fortress-2-splunk

Use docker-compose to create a Team Fortress 2 server that can optionally send data to an external Splunk Server using a Splunk Forwarder. One docker instance running Team Fortress 2 and the other instance running a Splunk Forwarder.

# Overview

Use docker-compose to build docker instances for Team Fortress 2 and Splunk Frowarder. This work decomposes https://github.com/mark-sivill-splunk/docker-team-fortress-2-splunk by seperating Team Fortress 2 and Splunk Forwarder into their own repsective docker containers and then coordinating the interaction between the containers by using a volume mapping. 

Configuring the location of the Splunk Server can be determined at runtime for simple examples, for more complex examples some of the forwarder configuration can be baked into the docker image itself. Useful for when dealing with certificates in the forwarder.

# To Build

Run ```docker-compose build ``` in the same directory as the docker-compose.yml file.

Optionally a Splunk Forwarder app can be baked into the docker image by updating the contents of ```.splunk_forwarder/files/splunk/tf2_forwarder_app```
This is useful when more complex forwarder configurations are required for example including certificates ( if using certificates ensure the correct path names are defined in outputs.conf )

# To Run

First set the required enviroment variables

- ```SPLUNK_FORWARDER_INDEX``` => required to send data to Splunk, the index that data is written to in Splunk
- ```SPLUNK_FORWARDER_SOURCETYPE``` => required to send data to Splunk, the sourcetype that data is written to in Splunk 
- ```SPLUNK_FORWARDER_HOST``` => required to send data to Splunk, the forwarder that data is written to in Splunk
- ```SPLUNK_FORWARDER_SERVER_PORT``` => required to send data to Splunk if not baked into Splunk Forwarder app. It will be in the format of splunk.example.com:9997
- ```TEAM_FORTRESS_2_CONFIG``` => setting the default game mode. Current modes are casual, tournament, training (training is default)
- ```TEAM_FORTRESS_2_SV_PASSWORD``` => Team Fortress 2 game password for games clients to connect to Team Fortress 2 server. By default no password is required
- ```TEAM_FORTRESS_2_RCON_PASSWORD```  => Team Fortress 2 admin password for RCON console

For example to set source type on Linux
```SPLUNK_FORWARDER_SOURCETYPE=tf2server; export SPLUNK_FORWARDER_INDEX```

Then to run Team Fortress 2 server and Splunk Forwarder

From same directory as the docker-compose.yml file run ```docker-compose up```

# Housekeeping

The Team Fortress 2 logs are sent to the Splunk Forwarder container using a mapped volume. This volume may need to periodically removed between restarts of the containers. Useful volume commands -

- List of volumes ```docker volume ls```
- Remove all volumes ```docker volume prune```
- Remove specific volume ```docker volume rm <volume>```

# Notes

* Tested on Linux host
* Checks for Team Fortress 2 server updates on container start up and every 10 minutes
* when configured to send data to Splunk in default mode (training) a constant stream of events will be sent to the Splunk Server due to Team Fortress 2 bots fighting

# Other links

- https://wiki.teamfortress.com/wiki/Servers - wiki for setting up Team Fortress 2
- https://linuxgsm.com/ - ease Team Fortress 2 server set up
- https://store.steampowered.com/app/440/Team_Fortress_2/ - setting up Team Fortress 2 client in Steam
- https://docs.splunk.com/Documentation/Forwarder/latest/Forwarder/Abouttheuniversalforwarder - documentation on setting up Splunk Forwarder
- https://splunkbase.splunk.com/app/1605/ - Splunk app (for Splunk Server) that works against data created by Team Fortress 2
