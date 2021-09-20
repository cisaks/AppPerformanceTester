package examples.bookings;

import com.intuit.karate.junit5.Karate;

class BookingsRunner {
    
    @Karate.Test
    Karate testBookings() {
        return Karate.run("bookings").relativeTo(getClass());
    }

    // @Karate.Test
    // Karate testBookingsEdge() {
    //     return Karate.run("bookingsEdge").relativeTo(getClass());
    // }
}
