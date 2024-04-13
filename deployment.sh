#!/bin/bash

#!/bin/bash

# Remove conflicting Docker packages
sudo apt-get remove -y docker.io containerd runc

# Add Docker's official GPG key and repository to Apt sources
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker and related packages
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker service
sudo systemctl start docker

# Create Docker network
sudo docker network create cyntax

# Pull Nginx and Certbot images
sudo docker pull nginx:latest
sudo docker pull certbot/certbot

# Obtain SSL certificate using Certbot
sudo docker run -it --rm -p 80:80 -p 443:443 \
    -v "/etc/letsencrypt:/etc/letsencrypt" \
    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
    certbot/certbot certonly --standalone \
    --agree-tos -m me@b3po.io -d api.b3po.io

# Run Nginx container
sudo docker run --name nginx -d --network cyntax -p 80:80 -p 443:443 \
   -v ~/nginx.conf:/etc/nginx/nginx.conf:ro \
   -v /etc/letsencrypt:/etc/letsencrypt \
   nginx

# Build and run Express application container
if [ -f "Dockerfile" ]; then
    sudo docker buildx build -t api-b3po-io .
    sudo docker run --name api-b3po -d --network cyntax --env-file ~/.env -p 6000:6000 \
        -v api-b3po-home:/var/api-b3po-home \
        api-b3po-io
else
    echo "Error: Dockerfile not found."
    exit 1
fi

sudo docker run --name nginx -d --network cyntax  -p 80:80 -p 443:443 \
   -v ~/nginx.conf:/etc/nginx/nginx.conf:ro \
   -v /etc/letsencrypt:/etc/letsencrypt \
   nginx

# for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# # Add Docker's official GPG key:
# sudo apt-get update
# sudo apt-get install ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc

# # Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update

# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# sudo systemctl start docker

# sudo docker network create B3PO

# # Used to setup jenkins and nginx with certbot
# sudo docker pull nginx
# sudo docker pull certbot/certbot

# sudo docker run -it --rm -p 80:80 -p 443:443 \
#     -v "/etc/letsencrypt:/etc/letsencrypt" \
#     -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
#     certbot/certbot certonly --standalone \
#     --agree-tos -m me@b3po.io -d api.b3po.io

# sudo docker run --name nginx -d --network B3PO -p 80:80 -p 443:443 \
#    -v ~/crytpo-data/nginx.conf:/etc/nginx/nginx.conf:ro \
#    -v /etc/letsencrypt:/etc/letsencrypt \
#    nginx

# sudo docker buildx build api-b3po-io .

# sudo docker run --name api-b3po -d --network B3PO -p 60000:0000 --group-add $(stat -c '%g' /var/run/docker.sock) -v api-b3po-home:/var/api-b3po-home -v /var/run/docker.sock:/var/run/docker.sock api-b3po-io 
