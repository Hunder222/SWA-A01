# SWA assignment-01
Group members:
- Ali Hassan
- Elliot Lyhne
- Jacob Naghdeh
- Mohsen Estakhr
- Sebastian Herler


## Purpose
Building a small, runnable `docker compose` project: a shell script our group wrote, packaged in a container, that **talks to a web service running alongside it**.
Our group has aimed for the optional sidegoal, to also use a MySQL database as a third container.

## Our solution
3 containers that cooperate to serve and save dadjokes.
- Application 
- Webservice
- MySQL database

## How it works
The app container runs the main script, which depend on both a web service and MySQL container.
This script asks for a dadjokes.json from the webserver using curl, prints a random joke in the terminal, and saves that random joke in the sql database. This loops every 10 seconds.
When the contains build, the script will before starting the loop, wait and make sure web and mysql containers are up and responsive.
The script continuesly in makes sure that both the web and mysql container are responsive by checking for healthy HTTP codes.
When a joke is sucessfully saved to the MySQL database, a confirmation is printed in terminal.

## Setup
- Clone the repo to a folder using terminal command: `git clone https://github.com/Hunder222/SWA-A01.git`
- Build and run the containers using terminal command: `docker-compose up --build`
- Wait for the images to download, the script will start afterwards.

Done! a new dadjoke is served to you every 10 seconds, and you can check which jokes you got and when, in the mysql database:
- Connect to MySQL database while containers are running, by using name: `mysql` and password `secret` on port `3307`
