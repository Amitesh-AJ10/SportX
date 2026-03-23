package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Notification — triggered by Booking events.
 * Demonstrates: Observer Pattern (Booking triggers Notification)
 */
@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 500)
    private String message;

    private LocalDateTime timestamp;

    private String userId;

    private boolean isRead = false;

    private String type; // BOOKING_CONFIRMED, BOOKING_CANCELLED, PAYMENT_SUCCESS

    public void sendNotification(String userId) {
        this.userId = userId;
        this.timestamp = LocalDateTime.now();
        // In production: integrate SMS/Email gateway
        System.out.println("Notification sent to " + userId + ": " + message);
    }
}

