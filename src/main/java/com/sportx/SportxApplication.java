package com.sportx;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * SportX — Sports Venue Booking System
 * MVC Architecture with Spring Boot
 *
 * Design Patterns Applied:
 *   Creational : Factory Method (UserFactory), Singleton (Spring Beans)
 *   Structural : Facade (Service layer), Proxy (Spring Security)
 *   Behavioral : Observer (NotificationService), Strategy (PaymentStrategy),
 *                Template Method (User.getDashboardUrl())
 *
 * Design Principles: SRP, OCP, LSP, ISP, DIP (SOLID)
 */
@SpringBootApplication
public class SportxApplication {
    public static void main(String[] args) {
        SpringApplication.run(SportxApplication.class, args);
    }
}

