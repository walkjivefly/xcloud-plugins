FROM ubuntu:bionic
COPY requirements.txt /
RUN apt update
RUN apt install -y curl python3 python3-pip
RUN python3 -m pip install -r requirements.txt
RUN rm requirements.txt
