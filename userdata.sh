#!/bin/bash
echo "[Unit]
Description=Webapp Service
After=network.target

[Service]
Environment="DATABASE_URL=postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_ADDRESS}:5432/${DB_DATABASE}"
Environment="S3_BUCKET_NAME=${AWS_BUCKET_NAME}"
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/webapp
ExecStart=/home/ec2-user/.local/bin/uvicorn main:app --reload --workers 4 --host 0.0.0.0 --port 8001
Restart=on-failure
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/webapp.service
sudo systemctl daemon-reload
sudo systemctl restart webapp.service