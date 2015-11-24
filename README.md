
##### Task 1 - File IO
* Build docker image from Dockerfile. It installs socat and curl utilities.
* Create server container which runs ls command and puts output to file.txt. Also run server on port 9001 to reply file.txt's content
* Create client which does curl to the server on port 9001. It should display ls command output.

```
//task1 is docker image name
sudo docker run --name server3 -d task1  /bin/bash -c 'ls > file.txt; socat TCP-LISTEN:9001,fork SYSTEM:"cat file.txt"' &

// It refers to server with name "server3"
sudo docker run --name client3 --link server3 task1 curl server3:9001 
```

#####  Task 2 - Ambassador pattern
* Create 2 docker image with 2 different vagrant.
* Run these commands in both of the docker images: install pip and installl docker compose
* In one docker image create server container and server-ambassador container with follwing yml file
```
redis-server:
   image: redis
   container_name: server_container

redis-ambassador: 
    image: svendowideit/ambassador
    ports: 
       - "6379:6379"
    links:
       -  redis-server
    container_name: server_ambassador
```

* Expose port 6379 on server redis image and ambassador for comminucation
* Also uncomment following line from vagrant file and reload vagrant.
```
config.vm.network "private_network", ip: "192.168.33.10"
```
* To run both of the container at server run command: ``` sudo docker-compose up -d ```


* In second docker image create client container and server-ambassador container with follwing yml file
```
redis-client:
   image: relateiq/redis-cli
   links:
      - redis-ambassador:redis
   container_name: client_container

redis-ambassador:
    image: svendowideit/ambassador
    expose:
       - "6379"
    container_name: client_ambassador
    environment:
       - REDIS_PORT_6379_TCP=tcp://192.168.33.10:6379
```
* ``` export REDIS_PORT_6379_TCP=tcp://192.168.33.10:6379 ``` to make sure that it finds correct environment variable value
* Run this command to set up both containers and do communication to server:  ``` sudo docker-compose run redis-client ```


#####  Task 3 - Docker Deploy
* Create workshop green blue deployment set up
* In simple Node.js app create post commit hooks with following content
```
sudo docker build -t hw4/task3 .
sudo docker tag -f hw4/task3 localhost:5000/hw4:latest
sudo docker push localhost:5000/hw4:latest

```
* It build docker image, tags with localhost:5000/hw4:latest and pushes
* In green.git added post-receive hook for getting latest copy with following content
```
#!/bin/sh
GIT_ROOT_WORK_TREE=$ROOT/green-www/ git checkout -f
sudo docker pull localhost:5000/hw4:latest
sudo docker stop dockerimage
sudo docker rm -f dockerimage
sudo docker rmi localhost:5000/hw4:current
sudo docker tag localhost:5000/hw4:latest localhost:5000/hw4:current
sudo docker run -p 50100:8080 -d --name dockerimage localhost:5000/hw4:latest
```
* This will remove previous docker image and create a new one with latest copy
* Run "curl localhost:50100" to see latest changes


### Screencast
This [screencast](https://youtu.be/c1lElH1poSI) demonstrates these 3 tasks
