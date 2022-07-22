# Selfoss Docker
 A docker file to create an image for Selfoss
 
 The main branch is using the latest changes of Selfoss as it clones the git repo from Selfoss.

## How-to
- `git clone https://github.com/MatthK/Selfoss-Docker` Clone it to your disk
- Run `docker build . -t selfoss:latest` to build the image. This should create the image on your machine and based on your architecture.
- Run `docker run -d --name Selfoss -v data:/var/www/html/data -p 8877:80 selfoss:latest` to start the docker container. Adjust the "data" volume to your likings, and the 8877 port.