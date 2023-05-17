FROM mongo:latest

# Set the working directory
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
