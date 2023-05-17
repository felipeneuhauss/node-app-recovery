#!/bin/bash

# Add a log entry indicating cron execution
echo "$(date): Cron job executed" >> /var/log/configs-backup.log

zip -r -D /tmp/configs.zip /usr/local/bin/configs

# Upload the backup to S3 using AWS CLI Docker image
aws s3 cp /tmp/configs.zip s3://$S3_BUCKET/$S3_CONFIGS_PREFIX/$(date +%Y%m%d-%H%M%S).zip
