Importing to Intellij
--
- Clone the repository
- In Intellij -> import project -> sbt


Running the Application
--

Open a command window at the PAMM seed root folder and enter the following command

Start the H2 DB:

	For Windows: buildscripts\batch\startDatabase

This will start the H2 database server on port 8082.  You can access the console on 

    http://localhost:8082
    Ensure that the JDBC URL is Jdbc:h2:tcp://localhost/~/pamm
    Accept the default user name and password

Start the Play Server
	activator svc/run

Access the sample application
	activator svc/run

    http://localhost:9000

The PAMM login page should be presented. The seed has no authentication configured for this initial draft version, so by entering any username and password, the PAMM dashboard should be displayed. The angular client is integrated with the Play backend and any actions on the Angular client will be routed to the Play backend.

The sample application requires registration that will sent an activation email to create an account.  However, as the email will reference localhost and therefore your email client must be on the same host as the play server 

**Packaging the Application
--

Open a command window at the PAMM seed root folder and enter the following command

	activator svc/dist
