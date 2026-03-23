package com.sportx.repository;

import com.sportx.model.Booking;
import com.sportx.model.enums.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {
    Optional<Booking> findByBookingId(String bookingId);
    List<Booking> findByPlayer_IdOrderByBookingTimeDesc(Long playerId);
    List<Booking> findBySlot_Court_Venue_IdOrderByBookingTimeDesc(Long venueId);
    List<Booking> findByStatus(BookingStatus status);
    long countBySlot_Court_Venue_Id(Long venueId);
}

