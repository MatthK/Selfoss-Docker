# Selfoss Docker
 A docker file to create an image for Selfoss
 
 The main branch is using the latest changes of [Selfoss](https://github.com/fossar/selfoss/) as it clones the git repo from Selfoss.

## How-to
- Clone it to your disk with `git clone https://github.com/MatthK/Selfoss-Docker`.
- Run `docker build . -t selfoss:latest` to build the image. This should create the image on your machine and based on your architecture.
- Run `docker run -d --name Selfoss -v data:/var/www/html/data -p 8877:80 selfoss:latest` to start the docker container. Adjust the "data" volume to your likings, and the 8877 port. Be patient after starting the container, as it has to initialize for a bit.