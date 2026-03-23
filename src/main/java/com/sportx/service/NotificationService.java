package com.sportx.service;

import com.sportx.model.Booking;
import com.sportx.model.Notification;
import com.sportx.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * NotificationService — Observer in the Observer Pattern.
 * Reacts to Booking state changes and persists notifications.
 *
 * Design Pattern: Observer (Behavioral)
 *   Subject = Booking events in BookingService
 *   Observer = NotificationService (this class)
 */
@Service
@Transactional
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    public void notifyBookingConfirmed(Booking booking) {
        String venue = booking.getSlot().getCourt().getVenue().getName();
        String court = booking.getSlot().getCourt().getCourtName();
        String time  = booking.getSlot().getStartTime().toString();

        Notification n = buildNotification(
                booking.getPlayer().getUserId(),
                "BOOKING_CONFIRMED",
                String.format("Booking confirmed! %s — %s at %s. Booking ID: %s",
                        venue, court, time, booking.getBookingId())
        );
        notificationRepository.save(n);
    }

    public void notifyBookingCancelled(Booking booking) {
        Notification n = buildNotification(
                booking.getPlayer().getUserId(),
                "BOOKING_CANCELLED",
                String.format("Your booking %s has been cancelled. Refund will be processed shortly.",
                        booking.getBookingId())
        );
        notificationRepository.save(n);
    }

    public void notifyPaymentSuccess(Booking booking) {
        Notification n = buildNotification(
                booking.getPlayer().getUserId(),
                "PAYMENT_SUCCESS",
                String.format("Payment of ₹%.2f successful for booking %s.",
                        booking.getTotalAmount(), booking.getBookingId())
        );
        notificationRepository.save(n);
    }

    public void notifyVenueVerified(String ownerUserId, String venueName) {
        Notification n = buildNotification(
                ownerUserId,
                "VENUE_VERIFIED",
                String.format("Your venue '%s' has been verified and is now live!", venueName)
        );
        notificationRepository.save(n);
    }

    public List<Notification> getNotificationsForUser(String userId) {
        return notificationRepository.findByUserIdOrderByTimestampDesc(userId);
    }

    public long getUnreadCount(String userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    public void markAllRead(String userId) {
        List<Notification> unread = notificationRepository.findByUserIdAndIsReadFalse(userId);
        unread.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(unread);
    }

    private Notification buildNotification(String userId, String type, String message) {
        Notification n = new Notification();
        n.setUserId(userId);
        n.setType(type);
        n.setMessage(message);
        n.setTimestamp(LocalDateTime.now());
        n.setRead(false);
        return n;
    }
}

