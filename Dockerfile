FROM ubuntu

RUN sudo apt-get -y update
RUN sudo apt-get -y install curl
RUN sudo apt-get -y install socat
