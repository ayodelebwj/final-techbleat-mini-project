#!/bin/bash
cd ~ 
sudo apt install nginx -y 
sudo systemctl daemon-reload 
sudo systemctl enable nginx 
sudo systemctl start nginx 
sudo rm -rf fruits-veg_market 
cd ~
git clone --branch mini-project --single-branch https://github.com/techbleat/fruits-veg_market.git
cd fruits-veg_market/
cd frontend/
sudo mv /var/www/html/index.nginx-debian.html abc
sudo rm /var/www/html/index.html
sudo cp index.html /var/www/html/
sudo systemctl daemon-reload
sudo sed -i "s|http://localhost:8000/api/products|/api/products|g" /var/www/html/index.html
aws ec2 describe-instances --filters "Name=tag:Name,Values=python-instance" --query 'Reservations[].Instances[].PrivateIpAddress | [0]' --output text >> python_private_ip.txt 
read -r PYTHON_PRIVATE_IP < python_private_ip.txt 
sudo sed -i "s|http://app-server-IP:8000|http://${PYTHON_PRIVATE_IP}:8000|g" /home/ubuntu/fruits-veg_market/frontend/nginx.conf_sample
sudo sed -i "s|server_name _|server_name lennipsss.org www.lennipsss.org|g" /etc/nginx/sites-enabled/default
                
awk '
/location \/api\/ {/ {copy=1; brace=1; print; next}
copy {
    print
    if (/{/) brace++
    if (/}/) brace--
    if (brace==0) copy=0
}
' /home/ubuntu/fruits-veg_market/frontend/nginx.conf_sample > /tmp/api_block.conf

if ! grep -q "location /api/" /etc/nginx/sites-enabled/default; then
    awk -v block="/tmp/api_block.conf" '
    /server {/ && !done {
        print
        system("cat " block)
        done=1
        next
    }
    {print}
    ' /etc/nginx/sites-enabled/default > target.new \
    && sudo mv target.new /etc/nginx/sites-enabled/default
fi

sysctl net.ipv6.bindv6only
sudo systemctl daemon-reload
sudo systemctl restart nginx
cd ~
sudo chmod +x namecheap-ddns.sh
./namecheap-ddns.sh
sudo certbot --nginx -d lennipsss.org -d www.lennipsss.org --agree-tos --email lennipsss@gmail.com --redirect --non-interactive

