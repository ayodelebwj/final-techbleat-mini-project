#!/bin/bash
sudo cp /tmp/fruits.service /etc/systemd/system/fruits.service
cd ~ 
sudo rm -rf fruits-veg_market 
git clone --branch mini-project --single-branch https://github.com/techbleat/fruits-veg_market.git
cd fruits-veg_market/
cd backend-api/
sudo apt install python3 python3-pip python3-venv -y
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
pip install fastapi uvicorn sqlalchemy psycopg2-binary python-dotenv
aws rds describe-db-instances   --db-instance-identifier my-postgres-db   --query "DBInstances[0].Endpoint.Address"   --output text  >> rds_postgres_databasename.txt
read -r RDS_POSTGRES_DATABASENAME < rds_postgres_databasename.txt
sudo sed -i "s|postgresql+psycopg://user:pass@db.server:5432/postgres|postgresql+psycopg://username:password@${RDS_POSTGRES_DATABASENAME}:5432/mydb|g" main.py
sudo systemctl daemon-reload 
sudo systemctl enable fruits.service 
sudo systemctl start fruits.service 