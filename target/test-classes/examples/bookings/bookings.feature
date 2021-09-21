Feature: Tests for Booking Controller

Background: Define URL
  * def timeValidator = read('classpath:helpers/timeValidator.js')
  * def dataGenerator = Java.type('helpers.DataGenerator')
  * def currentDate = dataGenerator.getCurrentDate()
  * def r_destination = dataGenerator.getRandomAirport()
  * def r_origin = dataGenerator.getRandomAirport()

  Given url apiURL 
  ## apiURL is a global config variable, set in karate-config.js

@CreateBookingEU
Scenario: Post booking: Existing user
  ## Note that this test case is dependent on the provided REST API application (AppPerformanceTest-0.1-SNAPSHOT.jar) 
  ## which starts with two existing users by default (pepe@pepe.pe1-0.1 and pepe@pepe.pe1-0.2).
  ## In a more general environment this test case should be removed/ignored (keyword @ignore).


  Given path 'booking'
  And request { date: "#(currentDate)", destination: "#(r_destination)", id: "#(existingUser.id)", origin: "#(r_origin)" }
  When method Post
  Then status 201
  And match response == { idBooking: "#string", idUser: "#(existingUser.id)", origin: "#(r_origin)", destination: "#(r_destination)", date: "#? timeValidator(_)" }
  
  #Save booking ID
  * def bookingId = response.idBooking

  #Get booking and verify that it was successfully created
  Given params { id: "#(existingUser.id)", date: "#(currentDate)" }
  Given path 'booking'
  When method Get
  Then status 200
  And match response == "#array"
  And match response[*] contains 
  """
    {
      date: "#? timeValidator(_)",
      destination: "#(r_destination)",
      idBooking: "#(bookingId)",
      idUser: "#(existingUser.id)",
      origin: "#(r_origin)"
    }
  """

@CreateBooking
Scenario: Post booking: New user 
  
  #Create user under which we can create a new booking
  * def user =
  """
    {
      email: #(dataGenerator.getRandomEmail()),
      name: #(dataGenerator.getRandomName())        
    }
  """
  Given path 'user'
  And request user
  When method Post
  Then status 201

  #Save userId
  * user.id = response.id
  
  #Define booking to be created
  * def booking =
  """
    {
      date: #(currentDate),
      destination: "#(r_destination)",
      id: "#(user.id)",
      origin: "#(r_origin)"
    }
  """

  #Create booking
  Given path 'booking'
  And request booking
  When method Post
  Then status 201

  #Validate Schema
  And match response == { idBooking: "#string", idUser: #(user.id), origin: #(booking.origin), destination: #(booking.destination), date: "#? timeValidator(_)" }

  #Save booking ID
  * def bookingId = response.idBooking
  
  #Get booking and verify that it was successfully created
  Given params { id: #(user.id), date: #(booking.date) }
  Given path 'booking'
  When method Get
  Then status 200
  And match response == "#array"
  And match response[*] contains 
  """
    {
      date: "#? timeValidator(_)",
      destination: "#(booking.destination)",
      idBooking: "#(bookingId)",
      idUser: "#(booking.id)",
      origin: "#(booking.origin)"
    }
  """


## Get booking scenarios
@GetBooking
Scenario Outline: Get booking: <e_description>
  Given params { id: <e_id>, date: <e_date> }
  Given path 'booking'
  When method Get
  Then status 200
  And match response == "#array"
  And match each response[*] == { date: "#? timeValidator(_)", destination: "#string", idBooking: "#string", idUser: "#string", origin: "#string" }
  Examples:
  | e_description             | e_id                  | e_date         |
  | "Filter by user"          | "#(existingUser.id)"  | null           |
  | "Filter by date"          | null                  | #(currentDate) |
  | "Filter by user & date"   | "#(existingUser.id)"  | #(currentDate) |


## Negative cases: Get booking
@NegativeGetBooking
Scenario Outline: Get booking: <e_description>
  Given params { id: <e_id>, date: <e_date> }
  Given path 'booking'
  When method Get
  Then status <e_sc>
  And match response == <e_errorResponse>

  Examples:
    | e_description                   | e_id                     | e_date                            | e_sc | e_errorResponse!                                                                                                    |
    | "Empty date and id"             | null                     | null                              | 400  | "Bad request: date and id empty"                                                                                    |
    | "Incorrect date: ABCD-09-19"    | "#(existingUser.id)"     | "ABCD-09-19"                      | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"Format date not valid", path: "/booking"} |
    | "Incorrect date: 2021-0ABC9-19" | "#(existingUser.id)"     | "2021-0ABC9-19"                   | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"Format date not valid", path: "/booking"} |
    | "Incorrect date: 2021-09-xyz19" | "#(existingUser.id)"     | "2021-09-xyz19"                   | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"Format date not valid", path: "/booking"} |
    | "Incorrect date: 2021-09-31"    | "#(existingUser.id)"     | "2021-09-31"                      | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"Format date not valid", path: "/booking"} |
    | "Incorrect date: 2021-13-15"    | "#(existingUser.id)"     | "2021-13-15"                      | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"Format date not valid", path: "/booking"} |
    
    ## Here is a Negative scenarios that return 200 (even though it perhaps shouldn't)
    | "Incorrect date: 2021-09-19xyz" | "#(existingUser.id)"     | "2021-09-19xyz"                   | 200  | "#array"                                                                                                            |

    
## Negative cases: Post booking (empty id/date, etc...)
@NegativePostBooking
Scenario Outline: Post booking: <e_description>
  Given path 'booking'
  And request { date: <e_date>, destination: <e_destination>, id: <e_id>, origin: <e_origin> }
  When method Post
  Then status <e_sc>
  And match response contains <e_errorResponse>

  Examples:
    | e_description                  | e_id                 | e_date           | e_destination | e_origin | e_sc | e_errorResponse                                                                                                   |
    | "No user id"                   | null                 | "#(currentDate)" | "ARN"         | "MAD"    | 400  | "User id should be valid"                                                                                         |
    | "No date"                      | "#(existingUser.id)" | null             | "ARN"         | "MAD"    | 400  | "Date format not valid"                                                                                           |
    | "No date or user id"           | null                 | null             | "ARN"         | "MAD"    | 400  | "Date format not valid"                                                                                           |
    | "Invalid date format"          | "#(existingUser.id)" | "20ABC20-04-08"  | "ARN"         | "MAD"    | 400  | "Date format not valid"                                                                                           |
    | "No destination"               | "#(existingUser.id)" | "#(currentDate)" | null          | "MAD"    | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"No message available", path:"/booking"} |
    | "No origin"                    | "#(existingUser.id)" | "#(currentDate)" | "ARN"         | null     | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"No message available", path:"/booking"} |
    | "Incorrect user id"            | "XYZXYZXYZ"          | "#(currentDate)" | "ARN"         | "MAD"    | 500  | {timestamp:"#string", status:500, error:"Internal Server Error", message:"#string",              path:"/booking"} |
    | "Incorrect destination format" | "#(existingUser.id)" | "#(currentDate)" | "ABBA"        | "MAD"    | 409  | "Origin or Destination is not a IATA code (Three Uppercase Letters)"                                              |
    | "Incorrect destination format" | "#(existingUser.id)" | "#(currentDate)" | "ARN"         | "MADRID" | 409  | "Origin or Destination is not a IATA code (Three Uppercase Letters)"                                              |