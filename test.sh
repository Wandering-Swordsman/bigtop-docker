#!/bin/bash

# run N slave containers
N=$1

# the defaut node number is 3
if [ $# = 0 ]
then
	N=3
fi
	

# delete old master container and start new master container
sudo docker rm -f master &> /dev/null
echo "start master container..."
docker run -d -t --dns 127.0.0.1 -P --name master -h namenode -w /root bigtop-hadoop-master:ubuntu-15.04-x86_64 bash -l -c "/etc/start_bigtop_services.sh  namenode resourcemanager -d" &> /dev/null

# get the IP address of master container
FIRST_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" master)

# delete old slave containers and start new slave containers
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f slave$i &> /dev/null
	echo "start slave$i container..."
	sudo docker run -d -t --dns 127.0.0.1 -P --name slave$i -h slave$i -e JOIN_IP=$FIRST_IP bigtop-hadoop-node:ubuntu-15.04-x86_64 bash -l -c "/etc/start_bigtop_services.sh datanode nodemanager -d" &> /dev/null
	((i++))
done 


# create a new Bash session in the master container