#!/bin/bash

# Add a log entry indicating cron execution
echo "$(date): Cron job executed" >> /var/log/mongodb-backup.log

# Dump the MongoDB data
mongodump --uri="mongodb://host.docker.internal:27017" --gzip --archive=/tmp/mongo.gz

# Upload the backup to S3 using AWS CLI Docker image
aws s3 cp /tmp/mongo.gz s3://$S3_BUCKET/$S3_MONGODB_PREFIX/$(date +%Y%m%d-%H%M%S).gz
