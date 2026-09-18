#!/usr/bin/env bash

### Use environment variables set in docker-compose + fallbacks just in case.
TARGET="${TARGET:-http://web}"
DB_HOST="${DB_HOST:-mysql}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASSWORD:-secret}"
DB_NAME="${DB_NAME:-jokes_db}"

echo "### Starting Dad Joke poller ###"



### Wait for MySQL is ready
echo "Waiting for MySQL at $DB_HOST:3306..."
# --skip-ssl skips requirement of ssl certificate, used on all mySQL commands.
until mysqladmin --skip-ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" ping; do
  echo "MySQL engine initializing... retrying in 2 seconds"
  sleep 2
done
# if ping to sql pong back exit loop and annouce its ready
echo "MySQL is online and accepting queries!"



### init the MySQL database
echo "Applying db-init.sql schema..."
mysql --skip-ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" < db-init.sql

# $? is exit code from last command, checks if code is 0, meaning no errors.
if [ $? -eq 0 ]; then
  echo "Database and table created successfully."
else
  echo "[Error] Failed to execute db-init.sql."
fi



### Wait for the Web service to respond with HTTP code 200 meaning is ready to serve.
echo "Waiting for web service at $TARGET/dadjokes.json..."
until [ "$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/dadjokes.json")" -eq 200 ]; do
  echo "Web service not returning 200 OK yet... retrying in 2 seconds"
  sleep 2
done
echo "Web service is responding!"



### poller loop that fetches data
while true; do
    # Check status code to survive drops or slow responses
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/dadjokes.json")

    if [ "$HTTP_STATUS" -ne 200 ]; then
        echo "[$(date '+%H:%M:%S')] Web service unreachable (HTTP $HTTP_STATUS). Retrying in 5s..."
        sleep 5
        continue
    fi


    # Fetch JSON and select a random item using shuffle
    JOKE=$(curl -s "$TARGET/dadjokes.json" | grep '"' | cut -d'"' -f2 | shuf -n 1)
    
    # if a joke is saved to variable (not empty), print joke and save it to db
    if [ -n "$JOKE" ]; then
        echo "--------------------------------------------------"
        echo -e "[$(date '+%H:%M:%S')] Fetched:\n\t\"$JOKE\""

        # Insert into MySQL using the CLI client
        mysql --skip-ssl -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" \
        -e "INSERT INTO saved_jokes (joke) VALUES ('$JOKE');"

        # Validate SQL exit code was a success using $?
        if [ $? -eq 0 ]; then
            echo "Well definitely using that when im a dad, saved to db!"
        else
            echo "[Warning] Database write failed. Retrying next cycle..."
        fi
    fi

    sleep 10
done