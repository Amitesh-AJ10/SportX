package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

/**
 * Payment — records a financial transaction for a Booking.
 * Demonstrates: Strategy Pattern (payment method abstraction)
 */
@Entity
@Table(name = "payments")
@Getter
@Setter
@NoArgsConstructor
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String transactionId;

    private double amount;

    private String status; // SUCCESS, FAILED, REFUNDED

    private String paymentMethod; // CARD, UPI, WALLET

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id")
    private Booking booking;

    public String processPayment() {
        // In production, delegate to PaymentGateway (external system)
        this.status = "SUCCESS";
        this.transactionId = "TXN-" + System.currentTimeMillis();
        return transactionId;
    }

    public void initiateRefund() {
        this.status = "REFUNDED";
    }
}

