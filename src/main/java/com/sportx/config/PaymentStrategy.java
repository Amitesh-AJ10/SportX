package com.sportx.config;

/**
 * Strategy Pattern — defines a family of payment algorithms.
 * Design Pattern: Behavioral — Strategy
 * ISP: Each strategy only exposes what it needs.
 */
public interface PaymentStrategy {
    String pay(double amount);
    String getMethodName();
}

