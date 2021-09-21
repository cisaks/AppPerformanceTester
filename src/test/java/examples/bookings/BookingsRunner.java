package examples.bookings;

import com.intuit.karate.junit5.Karate;

class BookingsRunner {
    
    @Karate.Test
    Karate testBookings() {
        return Karate.run("bookings").relativeTo(getClass());
    }

}
