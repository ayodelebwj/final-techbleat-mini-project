#!/bin/bash
cd ~ 
#INSTALL LETS ENCRYPT SSL CERTIFICATE
sudo certbot --nginx -d lennipsss.org -d www.lennipsss.org --agree-tos --email lennipsss@gmail.com --redirect --non-interactive

