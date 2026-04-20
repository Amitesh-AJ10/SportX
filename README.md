# SportX - Sports Venue Booking System

SportX is a comprehensive web application designed to bridge the gap between sports enthusiasts and sports facility owners. It provides a seamless platform for players to search and book slots at various sports venues (Badminton, Football, Cricket, Tennis, etc.), while allowing venue owners to manage their facilities, courts, and bookings efficiently.

## Core Features

### Authentication and Authorization
- Secure Login and Registration for three distinct roles: Player, Venue Owner, and Admin.
- Role-based access control (RBAC) ensuring users only see what they are authorized to access.

### Player Module
- Search and Filter: Find venues by city and sport type.
- Venue Details: View facility descriptions, amenities, high-quality images, and ratings.
- Slot Booking: Real-time availability check and booking for specific time slots.
- My Bookings: Track upcoming and past bookings.
- Profile Management: Update personal information.
- Notifications: Receive updates about booking confirmations and cancellations.

### Venue Owner Module
- Venue Management: Register and manage sports facilities.
- Court and Slot Management: Add multiple courts per venue and define availability slots with custom pricing.
- Dashboard: Real-time overview of bookings and revenue.
- Reports: Gain insights into facility utilization and performance.

### Admin Module
- Dashboard: High-level overview of the entire system (users, venues, bookings).
- User Management: Oversee all registered users.
- Venue Verification: Verify and approve new venues to ensure quality and authenticity on the platform.

## Technologies Used

### Backend
- Java 17
- Spring Boot 3.5.12
- Spring Data JPA
- Spring Security
- Spring Validation
- Hibernate
- H2 In-Memory Database (Development)

### Frontend
- Thymeleaf (Template Engine)
- Bootstrap (Styling)
- HTML5 / CSS3

### Development Tools
- Maven (Build Tool)
- Lombok (Code Simplification)

## Getting Started

### Prerequisites
- Java Development Kit (JDK) 17 or higher
- Apache Maven 3.6 or higher

### Installation Steps

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd sportx
   ```

2. Build the project using the Maven Wrapper:
   ```bash
   chmod +x mvnw
   ./mvnw clean install
   ```

3. Run the application:
   ```bash
   ./mvnw spring-boot:run
   ```

4. Access the application:
   Open your browser and navigate to `http://localhost:8080`

### Default Credentials

The application is pre-seeded with demo data for testing:

| Role | Email | Password |
| :--- | :--- | :--- |
| Admin | admin@sportx.com | admin123 |
| Venue Owner | owner@sportx.com | owner123 |
| Player | player@sportx.com | player123 |

### Database Console
You can access the H2 console at `http://localhost:8080/h2-console`:
- JDBC URL: `jdbc:h2:mem:sportxdb`
- Username: `sa`
- Password: (leave blank)

## Project Structure

- `com.sportx.config`: Security and data initialization configurations.
- `com.sportx.controller`: Role-specific web controllers.
- `com.sportx.model`: JPA entities (User, Player, VenueOwner, Admin, Venue, Court, Slot, Booking).
- `com.sportx.repository`: Spring Data JPA repositories.
- `com.sportx.service`: Business logic layer.
- `com.sportx.dto`: Data Transfer Objects for registration and requests.
- `src/main/resources/templates`: Thymeleaf HTML views.
- `src/main/resources/static`: CSS, JavaScript, and images.
