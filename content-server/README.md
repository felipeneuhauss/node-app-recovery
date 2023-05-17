# node-app-recovery

Node App with backup strategy for mongodb backup and config files

### Introduction

This document can be used as a tool to implement a backup process in the Hedera Guardian application. The guidelines and instructions applied to devise this document have been mentioned in the RFP Discussion document (22. Backup tools, documentation, and methodologies).

### MongoDB and .env Files Backup

Backups are an important part of application development. In order to ensure this feature in the Guardian application the following steps could be taken if you want to save the backups in the Amazon S3. This repo contains an example of how to simulate in detail the process to backup the mongodb collections and .env files. The same could be applied to the Guardian application.

Create a new folder called backup in the root folder of the Guardian Application.
The current docker-compose.yml contains this service:

`backup:
build: ./backup
environment:
- AWS_ACCESS_KEY_ID=AKIAXC*******D6QV7
  - AWS_SECRET_ACCESS_KEY=Ipk6*****************sfMV
  - S3_BUCKET=application-backups
  - AWS_DEFAULT_REGION=eu-central-1
  - S3_MONGODB_PREFIX=mongodb
  - S3_CONFIGS_PREFIX=configs
  - BACKUP_NAME_FORMAT=mongodb-%Y-%m-%d-%H-%M-%S.archive
    volumes:
  - ./backup:/data
  - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
  - mongodb`


Create this folder structure inside the backup folder:


The dockerfile will look like this:
```dockerfile
FROM mongo:latest

### Set the working directory

WORKDIR /usr/local/bin

COPY . .

# Install required tools
RUN apt-get update && apt-get install -y \
curl unzip cron zip

# Install AWS CLI dependencies
RUN apt-get update && apt-get install -y \
python3 \
python3-pip \
groff \
less \
--no-install-recommends

# Install AWS CLI
RUN pip3 install awscli

# Add AWS CLI to the system path
ENV PATH="/usr/local/aws-cli/bin:${PATH}"

# Copy your backup script to the container
COPY mongodb-backup.sh /usr/local/bin/mongodb-backup.sh
COPY configs-backup.sh /usr/local/bin/configs-backup.sh

# Set execute permissions for the backup script
RUN chmod +x /usr/local/bin/mongodb-backup.sh
RUN chmod +x /usr/local/bin/configs-backup.sh

# Copy the entrypoint script to the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set execute permissions for the entrypoint script
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
```

Mongodb-backup.sh script:
```shell
#!/bin/bash
# Add a log entry indicating cron execution
echo "$(date): Cron job executed" >> /var/log/mongodb-backup.log
# Dump the MongoDB data
mongodump --uri="mongodb://host.docker.internal:27017" --gzip --archive=/tmp/mongo.gz

# Upload the backup to S3 using AWS CLI Docker image
aws s3 cp /tmp/mongo.gz s3://$S3_BUCKET/$S3_MONGODB_PREFIX/$(date +%Y%m%d-%H%M%S).gz
```

Configs-backup.sh script:

```shell
#!/bin/bash

# Add a log entry indicating cron execution
echo "$(date): Cron job executed" >> /var/log/configs-backup.log

zip -r -D /tmp/configs.zip /usr/local/bin/configs`

# Upload the backup to S3 using AWS CLI Docker image
aws s3 cp /tmp/configs.zip s3://$S3_BUCKET/$S3_CONFIGS_PREFIX/$(date +%Y%m%d-%H%M%S).zip``
```

entrypoint.sh script:

The script below will execute hourly to backup the database and the configuration files.

```shell

#!/bin/bash

# Start cron
service cron start

# Run the backup script in an infinite loop
while true; do
/usr/local/bin/configs-backup.sh
/usr/local/bin/mongodb-backup.sh
sleep 1h  # Adjust the sleep duration as needed
done
```

Remember that inside the config files we have .env files which are invisible unless you run ls -lha command.

The final result will look like the image above. After that you can easily download the last file of the configuration or of the database to be reintroduced in the application.
