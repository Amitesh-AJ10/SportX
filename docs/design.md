# SportX Design Documentation

This document outlines the architectural decisions, design patterns, and software principles (SOLID and GRASP) implemented in the SportX project.

## Architectural Pattern: MVC

SportX follows the **Model-View-Controller (MVC)** architectural pattern:

- **Model**: JPA Entities (`User`, `Venue`, `Booking`, etc.) represent the data and business rules.
- **View**: Thymeleaf templates generate the dynamic HTML sent to the user's browser.
- **Controller**: Spring `@Controller` classes handle incoming HTTP requests, interact with services, and return views.

## SOLID Principles

The project adheres to the SOLID principles to ensure maintainability and scalability:

### 1. Single Responsibility Principle (SRP)
- Each class has one reason to change. 
- **Example**: `UserService` handles user accounts, while `BookingService` focus solely on the booking lifecycle. Entities like `User` are separated from their persistence logic (Repositories).

### 2. Open/Closed Principle (OCP)
- The system is open for extension but closed for modification.
- **Example**: Adding a new `SportType` (e.g., GOLF) only requires updating an Enum, and the rest of the search and filtering logic adapts automatically without modifying existing services.

### 3. Liskov Substitution Principle (LSP)
- Subclasses can replace their base classes without affecting correctness.
- **Example**: `Player`, `VenueOwner`, and `Admin` all extend `User`. The `UserRepository` and `SecurityConfig` treat them as `User` objects where polymorphic behavior (like `getDashboardUrl()`) is utilized.

### 4. Interface Segregation Principle (ISP)
- Clients are not forced to depend on methods they do not use.
- **Example**: Instead of one giant "DataRepository," we have specific interfaces like `VenueRepository`, `SlotRepository`, and `BookingRepository`.

### 5. Dependency Inversion Principle (DIP)
- High-level modules do not depend on low-level modules; both depend on abstractions.
- **Example**: Controllers depend on Service interfaces (abstractions), and Services depend on Repository interfaces. Spring's Dependency Injection (DI) manages these relationships.

## GRASP Principles

- **Information Expert**: Logic is placed where the data resides. For instance, `Venue.updateAvgRating()` calculates the rating because the `Venue` object holds the list of reviews.
- **Creator**: `VenueService` acts as the creator for `Venue` objects, ensuring they are properly initialized with an owner and a unique ID.
- **Controller**: `AuthController`, `PlayerController`, etc., act as the initial entry points that coordinate system operations.
- **Low Coupling & High Cohesion**: By separating concerns into distinct packages (`dto`, `model`, `service`, `controller`), we ensure that changes in the UI (View) don't force changes in the database logic (Model).

## Design Patterns Used

### Behavioral Patterns

- **Observer Pattern**: 
    - **Location**: `Booking` logic and `Notification` system.
    - **Role**: When a `Booking` status changes, it triggers the creation of a `Notification` for the user.
- **Strategy Pattern**: 
    - **Location**: `Payment` class.
    - **Role**: The `paymentMethod` field (CARD, UPI, WALLET) allows for different payment processing strategies to be implemented without changing the `Booking` logic.
- **Template Method Pattern**:
    - **Location**: `User.java` (Abstract class).
    - **Role**: The abstract `getDashboardUrl()` method defines a template that subclasses (`Player`, `Admin`) must implement, allowing the `SecurityConfig` to redirect users correctly after login.

### Structural Patterns

- **Adapter Pattern**:
    - **Location**: `UserDetailsServiceImpl.java`.
    - **Role**: Adapts our custom `User` entity to the `UserDetails` interface required by Spring Security.
- **Proxy Pattern**:
    - **Location**: Spring Security Filter Chain.
    - **Role**: Spring Security acts as a proxy for all web requests, intercepting them to check for authentication before they reach the actual controllers.

### Creational Patterns

- **Singleton Pattern**:
    - **Location**: Spring Beans.
    - **Role**: By default, all Spring-managed components (Services, Repositories) are singletons perfectly managed by the application context.
- **Factory/Builder Pattern**:
    - **Location**: Lombok `@Builder` (if used) and Spring's internal bean creation.
