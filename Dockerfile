FROM debian:stable-slim

WORKDIR /app

# Install library of tools via apt, curl and mysql client specifically.
RUN apt-get update && apt-get install -y curl default-mysql-client

# copy local files over to the app container
COPY script.sh db-init.sql ./
# make script executable
RUN chmod +x script.sh

# run file like a bash command
CMD ["./script.sh"]