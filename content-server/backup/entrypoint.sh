#!/bin/bash

# Start cron
service cron start

# Run the backup script in an infinite loop
while true; do
  /usr/local/bin/configs-backup.sh
  /usr/local/bin/mongodb-backup.sh
  sleep 1h  # Adjust the sleep duration as needed
done
