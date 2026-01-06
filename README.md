# certbots-letsencrypt-demo

1. We have docker file which will help to install and run certbots as a container, use the dockerfile and command docker build -t my-certbot .

2. Now create ssl directort
mkdir -p ~/ssl/{certbot/www,certbot/conf,nginx/html}
cd ~/ssl

3. next inside nginx directory create nginx.conf file and put the data

4. Run the nginx container using the nginx.conf file this only have http settings and 
docker run -d --name nginx \
  -p 80:80 \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/nginx/html:/usr/share/nginx/html \
  -v $(pwd)/certbot/www:/var/www/certbot \
  nginx:alpine

The command uses several volume mounts to link directories from the host machine to the container. The first volume, -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro, mounts a custom Nginx configuration file from the host's ./nginx/nginx.conf path to the container's /etc/nginx/nginx.conf

The second volume, -v $(pwd)/nginx/html:/usr/share/nginx/html, mounts a local directory for hosting web content. By linking ./nginx/html on the host to /usr/share/nginx/html in the container

The third volume, -v $(pwd)/certbot/www:/var/www/certbot, is specifically intended for integration with Certbot, a tool for managing SSL certificates from Let's Encrypt. Certbot uses the /var/www/certbot directory to place challenge files for domain validation during the certificate issuance or renewal process.

5. Verify if challenge path works
mkdir -p certbot/www/.well-known/acme-challenge
echo OK | tee certbot/www/.well-known/acme-challenge/test.txt

6. Run the cert bot container -> 
docker run --rm \
  -v $(pwd)/certbot/www:/var/www/certbot \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot certonly \
  --webroot \
  --webroot-path /var/www/certbot \
  -d working-shop.chickenkiller.com \
  --email admin@chickenkiller.com \
  --agree-tos \
  --no-eff-email \
  --non-interactive

7. Verify certificate 
ls certbot/conf/live/working-shop.chickenkiller.com/

8. Last step is replace the content of nginx.conf file with final_nignx.conf file (IMP DONT CHANGE THE NAME OF THE FILE - SHOULD BE ONLY nginx.conf)

Now Run -> 
docker run -d --name nginx \
  -p 80:80 -p 443:443 \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/nginx/html:/usr/share/nginx/html \
  -v $(pwd)/certbot/www:/var/www/certbot \
  -v $(pwd)/certbot/conf:/etc/letsencrypt:ro \
  nginx:alpine

above command will not works as -
Adds -p 443:443 so HTTPS is reachable.
​

Adds -v $(pwd)/certbot/conf:/etc/letsencrypt:ro so inside the container the certs exist at /etc/letsencrypt/live/working-shop.chickenkiller.com/..., matching your nginx.conf.
​

That extra -v .../certbot/conf:/etc/letsencrypt:ro is what fixes the cannot load certificate error.

