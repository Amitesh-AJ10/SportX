package com.sportx.service;

import com.sportx.config.PaymentContext;
import com.sportx.model.*;
import com.sportx.model.enums.BookingStatus;
import com.sportx.model.enums.SlotStatus;
import com.sportx.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * BookingService — orchestrates slot booking, payment, and notifications.
 *
 * Design Patterns:
 *   - Facade: hides multi-step booking flow from the controller
 *   - Observer: after booking is confirmed, NotificationService is triggered
 * Design Principles:
 *   - SRP: only booking business logic here
 *   - DIP: depends on repository interfaces, not implementations
 */
@Service
@Transactional
public class BookingService {

    @Autowired private BookingRepository bookingRepository;
    @Autowired private SlotRepository slotRepository;
    @Autowired private PaymentRepository paymentRepository;
    @Autowired private NotificationService notificationService;
    @Autowired private PaymentContext paymentContext;

    /**
     * Book a slot for a player — the core use case.
     * Steps: validate slot → create booking → process payment → notify (Observer)
     */
    public Booking bookSlot(Player player, String slotId, String paymentMethod) {
        Slot slot = slotRepository.findBySlotId(slotId)
                .orElseThrow(() -> new RuntimeException("Slot not found: " + slotId));

        if (!slot.isAvailable()) {
            throw new IllegalStateException("Slot is no longer available");
        }

        // 1. Create Booking
        Booking booking = new Booking();
        booking.setBookingId("BKG-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        booking.setBookingTime(LocalDateTime.now());
        booking.setTotalAmount(slot.getPrice());
        booking.setPlayer(player);
        booking.setSlot(slot);
        booking.setStatus(BookingStatus.PENDING);
        bookingRepository.save(booking);

        // 2. Process Payment (Strategy Pattern via PaymentContext)
        String txnId = paymentContext.executePayment(paymentMethod, slot.getPrice());
        Payment payment = new Payment();
        payment.setTransactionId(txnId);
        payment.setAmount(slot.getPrice());
        payment.setStatus("SUCCESS");
        payment.setPaymentMethod(paymentMethod);
        payment.setBooking(booking);
        paymentRepository.save(payment);

        // 3. Confirm Booking
        booking.confirmBooking();
        booking.setPayment(payment);
        slot.setStatus(SlotStatus.BOOKED);
        slotRepository.save(slot);
        Booking saved = bookingRepository.save(booking);

        // 4. Notify Player (Observer Pattern)
        notificationService.notifyBookingConfirmed(saved);

        return saved;
    }

    /**
     * Cancel a booking — triggers refund and notification.
     */
    public Booking cancelBooking(String bookingId, String currentUserEmail) {
        Booking booking = bookingRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new RuntimeException("Booking not found"));

        if (!booking.getPlayer().getEmail().equals(currentUserEmail)) {
            throw new SecurityException("Not authorized to cancel this booking");
        }
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new IllegalStateException("Booking already cancelled");
        }

        // Cancel and free slot
        booking.cancelBooking();
        Slot slot = booking.getSlot();
        slot.setStatus(SlotStatus.AVAILABLE);
        slotRepository.save(slot);

        // Refund
        if (booking.getPayment() != null) {
            booking.getPayment().initiateRefund();
            paymentRepository.save(booking.getPayment());
        }

        Booking saved = bookingRepository.save(booking);

        // Observer: notify cancellation
        notificationService.notifyBookingCancelled(saved);

        return saved;
    }

    public List<Booking> getPlayerBookings(Long playerId) {
        return bookingRepository.findByPlayer_IdOrderByBookingTimeDesc(playerId);
    }

    public List<Booking> getVenueBookings(Long venueId) {
        return bookingRepository.findBySlot_Court_Venue_IdOrderByBookingTimeDesc(venueId);
    }

    public Optional<Booking> findByBookingId(String bookingId) {
        return bookingRepository.findByBookingId(bookingId);
    }

    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    public long countVenueBookings(Long venueId) {
        return bookingRepository.countBySlot_Court_Venue_Id(venueId);
    }
}

