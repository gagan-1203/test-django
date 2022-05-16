#!/bin/bash 

deactivate


echo " [Unit] 
Description=gunicorn socket
[Socket]
ListenStream=/run/gunicorn.sock
[Install]
WantedBy=sockets.target" > /etc/systemd/system/gunicorn.socket

echo " [Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target
[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/myproject
ExecStart=/home/ubuntu/myproject/env/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          first_page.wsgi:application

[Install]
WantedBy=multi-user.target" >  /etc/systemd/system/gunicorn.service

sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket

echo "server {
    listen 80;
    server_name 43.204.107.99;
    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/ubuntu/myproject;
    }
    location / {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}" > /etc/nginx/sites-available/first_page


sudo ln -s /etc/nginx/sites-available/first_page  /etc/nginx/sites-enabled/

sudo rm /etc/nginx/sites-enabled/default


sudo systemctl restart nginx
sudo systemctl restart gunicorn
