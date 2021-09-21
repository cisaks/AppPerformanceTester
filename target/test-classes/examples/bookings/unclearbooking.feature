Feature: Unclear booking scenarios

Background: Define URL
    Given url apiURL 



@UnclearBooking @UnclearGetBookingNullParameters
Scenario:
    ## Current API behaviour is to return status: 400, with message "Bad request: date and id empty"
    ## when no User ID or Booking Date is provided
    ##
    ## However, given the method description on the API:
    ## - "Get bookings. Yo can apply several filters: by date, by user, by user and date, and all of them."
    ##
    ## We would expect the Get booking method to be able to return all bookings for all users ('and all of them')
    ## I would argue that the expected way to achieve this would be to provide no User ID and no Booking Date.
    ##
    ## This Scenario is to test the behaviour we would expect, if the API would allow to search for bookings
    ## by providing no User ID and no Booking Date.
    ##
    ## However, as is, this test case will FAIL
    Given params { id: null, date: null }
    Given path 'booking'
    When method Get
    Then status 200
    And match response == "#array"
    And match each response[*] == { date: "#string", destination: "#string", idBooking: "#string", idUser: "#string", origin: "#string" }



@UnclearBooking @UnclearGetBookingIncorrectDate
Scenario: Get booking: Incorrect date format: 2021-09-19xyz
    ## While the API tries to make sure that a strict date format is followed,
    ## it fails to detect incorrect date formats of type 'yyyy-MM-ddXXX'
    ## (Where yyyy=year, MM=month, dd=day and XXX=Any number of characters)
    ##
    ## This creates a problem where bookings with this incorrect date format
    ## don't show up with the Get /booking method for a given date if the user
    ## had a typo at the end of their date, unless you Get the bookings with
    ## that exact same typo. 
    ##
    ## Additionally, if bookings are created with an incorrect date format
    ## then subsequent tests that gets all bookings for a particular userID
    ## that has bookings with incorrect date format, then the @GetBooking
    ## test will fail since it uses a more robust function for detecting
    ## incorrect date formats.
    ## 
    ## This Scenario is to test the behaviour we would expect, if the API
    ## was able to also detect incorrect date formats of this type.
    ##
    ## However, as is, this test case will FAIL!
    Given params { id: "#(existingUser.id)", date: "2021-09-19xyz" }
    Given path 'booking'
    When method Get
    Then status 500
    And match response == {timestamp:"#string", status:500, error:"Internal Server Error", message:"Format date not valid", path: "/booking"}



@UnclearBooking @UnclearPostBookingIncorrectDate
Scenario: Post booking: Incorrect date format: 2021-09-19xyz
    ## Given the same API problem with incorrect date formats outlined in the above Scenario,
    ## this Scenario is to test the behaviour we would expect, if the API was able to also
    ## detect incorrect date formats of this type when creating new bookings.
    ##
    ## However, as is, this test case will FAIL!
    * def dataGenerator = Java.type('helpers.DataGenerator')
    * def user =
    """
      {
        email: "IncorrectDateTestEmail@email.com",
        name: "#(dataGenerator.getRandomName())"        
      }
    """
    Given path 'user'
    And request user
    When method Post
    Then status 201

    #Save userId
    * user.id = response.id

    Given path 'booking'
    And request { date: "2020-02-03 XXX", destination: "ARN", id: "#(user.id)", origin: "MAD" }
    When method Post
    Then status 400
    And match response contains "Date format not valid"
