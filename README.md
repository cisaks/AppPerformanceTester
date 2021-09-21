# Karate Test App
## Prerequisites
* Java 8 SDK
* Maven
* A copy of AppPerformanceTest-0.1-SNAPSHOT.jar

## Instructions

* Download and install Java 8 SDK (https://www.oracle.com/java/technologies/downloads/).
    * Make sure that the JAVA_HOME environment variable point to the folder where you installed the Java 8 SDK.
    * Make sure that the PATH environment variable includes the path to the /bin folder of Java 8.
    * Verify that the Java installation was successful by typing `java -version` in a terminal.

* Download and install Maven (https://maven.apache.org/index.html).
    * Follow instructions on the website for your OS.
    * Verify that the Maven installation was successful by typing `mvn -version` in a terminal.

* Launch the AppPerformanceTest-0.1-SNAPSHOT.jar application.
    * Open a terminal and navigate to the folder of the AppPerformanceTest-0.1-SNAPSHOT.jar.
    * Launch it by typing `java -Dserver.port=8900 -jar AppPerformanceTest-0.1-SNAPSHOT.jar`.

* Clone this repository to your local hard drive.
    * In a terminal, navigate to the folder where you want to clone this repository to.
    * Type `git clone https://github.com/cisaks/AppPerformanceTester.git`.
    * Execute the tests by typing `mvn clean test`.
    * Please note that by default, there will be 3 failing scenarios.
        * These scenarios are defined in `src\test\java\examples\bookings\unclearbooking.feature`.
        * You can ignore these scenarios by executing the tests with the command `mvn clean test "-Dkarate.options=--tags ~@UnclearBooking"`.

* You can find the generated Cucumber Reports in HTML format in the folder `target\cucumber-html-reports`.