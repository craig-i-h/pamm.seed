# Getting started

## Cloning the seed

The first step to get up and running is to create a copy of the project files in the local file system as shown below: 

```bash
# copy the project files to the local directory using git
$ git clone https://github.com/gatblau/pamm.seed
# navigate into the newly created project folder
$ cd pamm.seed
# list the files in the project
$ ls -l
```
Now that the project files are in the local file system, you can either:
- package the application, run it and execute the feature tests, or
- import the file in an IDE for development

## Package the application, run it and execute the feature tests

The commands required to package the application, run it and execute the feature tests, are included in the [apprun.sh](../apprun.sh) bash script.

The scripts does the following steps:
- Checks that the application is not already running, and if it is, then shut the relevant services down by calling the [shutdown.sh](../shutdown.sh) script. Relevant services are the **application** (on port 8080), the **test setup** web service (on port 8081) and the **Selenium** server (on port 4444).
- Initialises the MariaDb database server, creates the PAMM database and creates the necessary tables. This is done by calling [sqlrun.sh](../sqlrun.sh). The script needs to run in a linux host, such as [Europa](https://github.com/gatblau/europa), as it creates the database server in a Docker container. If the MariaDb image is not cached locally, it pulls it from Docker Hub and then creates a container called *pamm-sql*.
- Packages the PAMM seed application using activator. The application is packaged as an uber-jar with all dependencies included in the package to facilitate deployment and execution. The output packages can be found in the **svc/target/scala-2.11** folder.
- Launches the application on port 8080.
- Packages the Test Setup web service in a similar way as the application seed. This service provides an API for saving test data by the Protractor tests. Is only needed for running feature (integration) tests. The output packages can be found in the **testsetup/target/scala-2.11** folder.
- Launches the Test Setup web service on port 8081.
- Install all javascript packages required to run the tests.
- Updates the Selenium web driver.
- Starts the Selenium server on port 4444.
- Runs the tests using Protractor by calling [testrun.sh](../testrun.sh).

If everything goes ok, you should see the web browser popping up and running the tests.

After this, you can call [shutdown.sh](../shutdown.sh) to kill the application processes.

The database is kept running within the pamm-sql container. You can check it by calling **docker ps**.

## Import the file in an IDE for development

### In Intellij
- import project 
- sbt


## Running the Application in Development mode

### SQL database

To start the containerised SQL database, open a command line and type the following:
``` bash
# check if the pamm-sql database is running
docker ps -f name=pamm-sql

# you should see the container running
# if not, check if the container is stopped
docker ps -a -f name=pamm-sql

# if you see the container now, start it
docker start pamm-sql

# if the container is not created, run the following script
sh sqlrun.sh

# now check if the container is running again
```

The pamm-sql container is mapped to port 3306 on the localhost. You can connect to the server and see the database and tables using for example MySQL Workbench.

### Running the web application
Start the Play Server by typing the following:
``` bash
activator svc/run
```
To see the application open a browser on http://localhost:8080


The PAMM login page should be presented. The seed has no authentication configured for this initial draft version, so by entering any username and password, the PAMM dashboard should be displayed. The angular client is integrated with the Play backend and any actions on the Angular client will be routed to the Play backend.

The sample application requires registration that will sent an activation email to create an account.  However, as the email will reference localhost and therefore your email client must be on the same host as the play server.

### Packaging the web application

Open a command window at the PAMM seed root folder and enter the following command

``` bash
activator svc/assembly
```

The output can be seen within the **svc/target/scala-2.11 folder**.

