Feature: Tests for User Controller

Background: Define URL
  * def dataGenerator = Java.type('helpers.DataGenerator')
  Given url apiURL 
  ## apiURL is a global config variable, set in karate-config.js

@GetUser
Scenario: Get user: Existing user
  ## Note that this test case is dependent on the provided REST API application (AppPerformanceTest-0.1-SNAPSHOT.jar) 
  ## which starts with two existing users by default (pepe@pepe.pe1-0.1 and pepe@pepe.pe1-0.2).
  ## In a more general environment this test case should be removed/ignored (keyword @ignore).
  Given params { id: "#(existingUser.id)" }
  Given path 'user'
  When method get
  Then status 200
  And match response == { email: "#(existingUser.email)", name: "#(existingUser.name)", id: "#(existingUser.id)", bookings: "#array" }

@GetAllUsers
Scenario: Get all users
  Given path 'user/all'
  When method get
  Then status 200
  And match response == "#array"

  ## Validate schema for each user and their bookings.
  ##
  ## Note: In a real world test, assuming a sufficiently large user database, 
  ## one may want to skip these schema validations when fetching the whole user database
  ## as it would be time consuming and superfluous to validate the user database 
  ## each time you run the API tests (we're doing API tests, not database tests).
  ## It would probably be sufficient to validate the schema for post/get user and booking.
  And match each response == { email: "#string", name: "#string", id: "#string", bookings: "#array" }
  #* def timeValidator = read('classpath:helpers/timeValidator.js')
  And match each response..bookings[*] == 
  """
    {
      idBooking: "#string",
      idUser: "#string",
      origin: "#string",
      destination: "#string",
      date: "#string"
    }
  """

@CreateUser
Scenario: Create a user
  * def user =
    """
    {
      email: #(dataGenerator.getRandomEmail()),
      name: #(dataGenerator.getRandomName())        
    }
    """
  ## Create user
  Given path 'user'
  And request user
  When method Post
  Then status 201
  And match response == { email: #(user.email), name: #(user.name), id: "#string", bookings: "#array" }

  * def userId = response.id

  ## Get user and check that it was successfully created
  Given params { id: #(userId) }
  Given path 'user'
  When method get
  Then status 200
  And match response == { email: "#string", name: "#string", id: "#string", bookings: "#array" }
  And match response contains user
  
## Negative cases: Get user 
@GetUserNegative
Scenario Outline: Get User: <e_description>
  Given params { id: <e_id> }
  Given path 'user'
  When method get
  Then status <e_status>
  And match response == <e_response>

  Examples:
  | e_description       | e_id   | e_status | e_response       |
  | "Indorrect user id" | "*5q/" | 404      | "User not found" |
  | "No user id"        | null   | 500      | "ID erroneus"    |

## Negative cases: Post user
@CreateUserNegative
Scenario Outline: Post user: <e_description>
  Given path 'user'
  And request <e_user>
  When method Post
  Then status <e_status>
  And match response == <e_response>

  Examples:
  | e_description           | e_user                              | e_status | e_response                                                                                                      |
  | "No email"              | {email:"", name:"Karl"}             | 409      | "Check fields"                                                                                                  |
  | "No name"               | {email:"my@email.com", name:""}     | 409      | "Check fields"                                                                                                  |
  | "No email or name"      | {email:"", name:""}                 | 409      | "Check fields"                                                                                                  |
  | "Malformed email"       | {email:"my.email.com", name:"Karl"} | 500      | {"timestamp":"#string","status":500,"error":"Internal Server Error","message":"malformed email","path":"/user"} |
  | "No request parameter"  | null                                | 400      | {"timestamp":"#string","status":400,"error":"Bad Request","message":"#string","path":"/user"}                   |
