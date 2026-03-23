#!/bin/bash
# SportX Complete Auto-Setup Script (Fixed)
# Run from INSIDE your sportx folder: bash setup_sportx_fixed.sh
set -e
echo "🏗️  SportX Auto-Setup Starting..."

# ── Detect correct base package path ──────────────────────────
# Spring Initializr may have already created com/sportx/SportxApplication.java
# We need to find the right base and remove duplicates

BASE_JAVA="src/main/java"

# Remove any wrongly nested com/sportx/sportx directory if it exists
if [ -d "$BASE_JAVA/com/sportx/sportx" ]; then
  echo "🧹 Removing duplicate nested package com/sportx/sportx/..."
  rm -rf "$BASE_JAVA/com/sportx/sportx"
fi

# Remove the default generated SportxApplication if it exists (we'll rewrite it)
rm -f "$BASE_JAVA/com/sportx/SportxApplication.java"
rm -f "$BASE_JAVA/com/sportx/DemoApplication.java"

# Create all required directories under com/sportx/
mkdir -p $BASE_JAVA/com/sportx/{config,controller,model/enums,repository,service,dto}
mkdir -p src/main/resources/static/css
mkdir -p src/main/resources/templates/{auth,player,venueowner,admin}

echo "✅ Directories ready"
cat > pom.xml << 'SPORTX_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.12</version>
        <relativePath/>
    </parent>

    <groupId>com.sportx</groupId>
    <artifactId>sportx</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>sportx</name>
    <description>SportX - Sports Venue Booking System</description>
    <packaging>jar</packaging>

    <properties>
        <java.version>17</java.version>
        <start-class>com.sportx.SportxApplication</start-class>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.thymeleaf.extras</groupId>
            <artifactId>thymeleaf-extras-springsecurity6</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <mainClass>com.sportx.SportxApplication</mainClass>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
SPORTX_EOF
cat > src/main/resources/application.properties << 'SPORTX_EOF'
# =============================================
# SportX - Application Configuration
# =============================================

spring.application.name=sportx

# H2 In-Memory Database
spring.datasource.url=jdbc:h2:mem:sportxdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console

# JPA / Hibernate
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# MySQL (Production) - Uncomment and comment H2 above
# spring.datasource.url=jdbc:mysql://localhost:3306/sportxdb?useSSL=false&serverTimezone=UTC
# spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
# spring.datasource.username=root
# spring.datasource.password=yourpassword
# spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect
# spring.jpa.hibernate.ddl-auto=update

# Thymeleaf
spring.thymeleaf.cache=false
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html

# Server
server.port=8080

# Logging
logging.level.com.sportx=DEBUG
logging.level.org.springframework.security=INFO

SPORTX_EOF
cat > src/main/java/com/sportx/model/enums/BookingStatus.java << 'SPORTX_EOF'
package com.sportx.model.enums;

public enum BookingStatus {
    PENDING,
    CONFIRMED,
    CANCELLED,
    COMPLETED
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/enums/SlotStatus.java << 'SPORTX_EOF'
package com.sportx.model.enums;

public enum SlotStatus {
    AVAILABLE,
    BOOKED,
    BLOCKED
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/enums/SportType.java << 'SPORTX_EOF'
package com.sportx.model.enums;

public enum SportType {
    BADMINTON,
    FOOTBALL,
    CRICKET,
    TENNIS,
    SWIMMING
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/enums/UserRole.java << 'SPORTX_EOF'
package com.sportx.model.enums;

public enum UserRole {
    PLAYER,
    VENUE_OWNER,
    ADMIN
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/User.java << 'SPORTX_EOF'
package com.sportx.model;

import com.sportx.model.enums.UserRole;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

/**
 * Abstract base class for all users — Player, VenueOwner, Admin.
 * Demonstrates: Inheritance (Liskov Substitution Principle),
 *               Single Responsibility Principle
 */
@Entity
@Table(name = "users")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "role", discriminatorType = DiscriminatorType.STRING)
@Getter
@Setter
@NoArgsConstructor
public abstract class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String userId;

    @NotBlank
    private String name;

    @Email
    @Column(unique = true, nullable = false)
    private String email;

    private String phoneNumber;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(insertable = false, updatable = false)
    private UserRole role;

    // Template method pattern — subclasses override for specific behaviour
    public abstract String getDashboardUrl();

    public void login() { /* handled by Spring Security */ }

    public void updateProfile(String name, String phoneNumber) {
        this.name = name;
        this.phoneNumber = phoneNumber;
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Player.java << 'SPORTX_EOF'
package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Player — can search venues, book slots, view history, rate venues.
 * Owns use cases: Search, Book, Cancel, History, Rate & Review
 */
@Entity
@DiscriminatorValue("PLAYER")
@Getter
@Setter
@NoArgsConstructor
public class Player extends User {

    @OneToMany(mappedBy = "player", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Booking> bookings = new ArrayList<>();

    @OneToMany(mappedBy = "player", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Review> reviews = new ArrayList<>();

    @Override
    public String getDashboardUrl() {
        return "/player/dashboard";
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/VenueOwner.java << 'SPORTX_EOF'
package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * VenueOwner — manages venues, courts, slots, views reports.
 * Owns use cases: Add Venue, Manage Slots & Pricing, Manage Bookings, View Reports
 */
@Entity
@DiscriminatorValue("VENUE_OWNER")
@Getter
@Setter
@NoArgsConstructor
public class VenueOwner extends User {

    private String businessLicense;

    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Venue> venues = new ArrayList<>();

    @Override
    public String getDashboardUrl() {
        return "/owner/dashboard";
    }

    public void addVenue(Venue venue) {
        venue.setOwner(this);
        this.venues.add(venue);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Admin.java << 'SPORTX_EOF'
package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

/**
 * Admin — verifies venues, manages users.
 * Owns use cases: Verify Venue/Partner, Manage Users
 */
@Entity
@DiscriminatorValue("ADMIN")
@Getter
@Setter
@NoArgsConstructor
public class Admin extends User {

    @Override
    public String getDashboardUrl() {
        return "/admin/dashboard";
    }

    public void verifyVenue(String venueId) {
        // Delegated to AdminService
    }

    public void manageUsers(String userId) {
        // Delegated to AdminService
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Venue.java << 'SPORTX_EOF'
package com.sportx.model;

import com.sportx.model.enums.SportType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Venue — a sports facility that contains multiple courts.
 */
@Entity
@Table(name = "venues")
@Getter
@Setter
@NoArgsConstructor
public class Venue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String venueId;

    @Column(nullable = false)
    private String name;

    private String address;

    private String city;

    private String imageUrl;

    private String description;

    private double avgRating = 0.0;

    private boolean isVerified = false;

    @ElementCollection(targetClass = SportType.class)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "venue_sports", joinColumns = @JoinColumn(name = "venue_id"))
    @Column(name = "sport_type")
    private List<SportType> sportTypes = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private VenueOwner owner;

    @OneToMany(mappedBy = "venue", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Court> courts = new ArrayList<>();

    @OneToMany(mappedBy = "venue", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Review> reviews = new ArrayList<>();

    public String getDetails() {
        return String.format("Venue: %s at %s — Rating: %.1f", name, address, avgRating);
    }

    public void updateAvgRating() {
        if (reviews != null && !reviews.isEmpty()) {
            this.avgRating = reviews.stream()
                    .mapToInt(Review::getRating)
                    .average()
                    .orElse(0.0);
        }
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Court.java << 'SPORTX_EOF'
package com.sportx.model;

import com.sportx.model.enums.SportType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Court — a specific playable area within a Venue for a particular sport.
 */
@Entity
@Table(name = "courts")
@Getter
@Setter
@NoArgsConstructor
public class Court {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String courtId;

    @Column(nullable = false)
    private String courtName;

    @Enumerated(EnumType.STRING)
    private SportType sport;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id")
    private Venue venue;

    @OneToMany(mappedBy = "court", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Slot> slots = new ArrayList<>();

    public List<Slot> getAvailableSlots(LocalDate date) {
        return slots.stream()
                .filter(s -> s.getStartTime().toLocalDate().equals(date)
                        && s.getStatus().name().equals("AVAILABLE"))
                .collect(Collectors.toList());
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Slot.java << 'SPORTX_EOF'
package com.sportx.model;

import com.sportx.model.enums.SlotStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Slot — a time window on a Court that can be booked.
 */
@Entity
@Table(name = "slots")
@Getter
@Setter
@NoArgsConstructor
public class Slot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String slotId;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    private double price;

    @Enumerated(EnumType.STRING)
    private SlotStatus status = SlotStatus.AVAILABLE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id")
    private Court court;

    public boolean isAvailable() {
        return this.status == SlotStatus.AVAILABLE;
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Booking.java << 'SPORTX_EOF'
package com.sportx.model;

import com.sportx.model.enums.BookingStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Booking — links a Player to a Slot. Triggers Payment and Notification.
 * Demonstrates: Observer Pattern trigger point
 */
@Entity
@Table(name = "bookings")
@Getter
@Setter
@NoArgsConstructor
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String bookingId;

    private LocalDateTime bookingTime;

    private double totalAmount;

    @Enumerated(EnumType.STRING)
    private BookingStatus status = BookingStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id")
    private Player player;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "slot_id")
    private Slot slot;

    @OneToOne(mappedBy = "booking", cascade = CascadeType.ALL)
    private Payment payment;

    public void confirmBooking() {
        this.status = BookingStatus.CONFIRMED;
    }

    public void cancelBooking() {
        this.status = BookingStatus.CANCELLED;
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Payment.java << 'SPORTX_EOF'
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

SPORTX_EOF
cat > src/main/java/com/sportx/model/Review.java << 'SPORTX_EOF'
package com.sportx.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

/**
 * Review — a Player's rating and comment on a Venue.
 */
@Entity
@Table(name = "reviews")
@Getter
@Setter
@NoArgsConstructor
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String reviewId;

    @Min(1) @Max(5)
    private int rating;

    @Column(length = 1000)
    private String comment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id")
    private Player player;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id")
    private Venue venue;
}

SPORTX_EOF
cat > src/main/java/com/sportx/model/Notification.java << 'SPORTX_EOF'
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

SPORTX_EOF
cat > src/main/java/com/sportx/repository/UserRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUserId(String userId);
    boolean existsByEmail(String email);
}

SPORTX_EOF
cat > src/main/java/com/sportx/repository/VenueRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.Venue;
import com.sportx.model.enums.SportType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VenueRepository extends JpaRepository<Venue, Long> {
    Optional<Venue> findByVenueId(String venueId);
    List<Venue> findByIsVerifiedTrue();
    List<Venue> findByCityContainingIgnoreCaseAndIsVerifiedTrue(String city);
    List<Venue> findByOwner_Id(Long ownerId);

    @Query("SELECT v FROM Venue v JOIN v.sportTypes s WHERE s = :sport AND v.isVerified = true")
    List<Venue> findBySportType(@Param("sport") SportType sport);

    @Query("SELECT v FROM Venue v JOIN v.sportTypes s WHERE " +
           "(:city IS NULL OR LOWER(v.city) LIKE LOWER(CONCAT('%', :city, '%'))) AND " +
           "(:sport IS NULL OR s = :sport) AND v.isVerified = true")
    List<Venue> searchVenues(@Param("city") String city, @Param("sport") SportType sport);
}

SPORTX_EOF
cat > src/main/java/com/sportx/repository/CourtRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.Court;
import com.sportx.model.enums.SportType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CourtRepository extends JpaRepository<Court, Long> {
    List<Court> findByVenue_Id(Long venueId);
    List<Court> findByVenue_IdAndSport(Long venueId, SportType sport);
}

SPORTX_EOF
cat > src/main/java/com/sportx/repository/SlotRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.Slot;
import com.sportx.model.enums.SlotStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface SlotRepository extends JpaRepository<Slot, Long> {
    Optional<Slot> findBySlotId(String slotId);
    List<Slot> findByCourt_Id(Long courtId);
    List<Slot> findByCourt_IdAndStatus(Long courtId, SlotStatus status);

    @Query("SELECT s FROM Slot s WHERE s.court.id = :courtId " +
           "AND s.startTime >= :from AND s.startTime < :to")
    List<Slot> findByCourtAndDate(@Param("courtId") Long courtId,
                                  @Param("from") LocalDateTime from,
                                  @Param("to") LocalDateTime to);
}

SPORTX_EOF
cat > src/main/java/com/sportx/repository/BookingRepository.java << 'SPORTX_EOF'
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

SPORTX_EOF
cat > src/main/java/com/sportx/repository/ReviewRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByVenue_Id(Long venueId);
    List<Review> findByPlayer_Id(Long playerId);
    boolean existsByPlayer_IdAndVenue_Id(Long playerId, Long venueId);
}

SPORTX_EOF
cat > src/main/java/com/sportx/repository/PaymentRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Optional<Payment> findByTransactionId(String transactionId);
    Optional<Payment> findByBooking_Id(Long bookingId);
}

SPORTX_EOF
cat > src/main/java/com/sportx/repository/NotificationRepository.java << 'SPORTX_EOF'
package com.sportx.repository;

import com.sportx.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserIdOrderByTimestampDesc(String userId);
    List<Notification> findByUserIdAndIsReadFalse(String userId);
    long countByUserIdAndIsReadFalse(String userId);
}

SPORTX_EOF
cat > src/main/java/com/sportx/dto/RegisterDTO.java << 'SPORTX_EOF'
package com.sportx.dto;

import com.sportx.model.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/**
 * Data Transfer Object for user registration.
 */
@Getter
@Setter
public class RegisterDTO {

    @NotBlank(message = "Name is required")
    private String name;

    @Email(message = "Valid email required")
    @NotBlank(message = "Email is required")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    private String phoneNumber;

    private UserRole role = UserRole.PLAYER;

    // VenueOwner only
    private String businessLicense;
}

SPORTX_EOF
cat > src/main/java/com/sportx/dto/VenueDTO.java << 'SPORTX_EOF'
package com.sportx.dto;

import com.sportx.model.enums.SportType;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class VenueDTO {
    @NotBlank(message = "Venue name is required")
    private String name;

    @NotBlank(message = "Address is required")
    private String address;

    @NotBlank(message = "City is required")
    private String city;

    private String description;
    private String imageUrl;
    private List<SportType> sportTypes;
}

SPORTX_EOF
cat > src/main/java/com/sportx/dto/BookingDTO.java << 'SPORTX_EOF'
package com.sportx.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BookingDTO {
    private String slotId;
    private String paymentMethod; // CARD, UPI, WALLET
}

SPORTX_EOF
cat > src/main/java/com/sportx/dto/SlotDTO.java << 'SPORTX_EOF'
package com.sportx.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class SlotDTO {
    private Long courtId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private double price;
}

SPORTX_EOF
cat > src/main/java/com/sportx/dto/ReviewDTO.java << 'SPORTX_EOF'
package com.sportx.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDTO {
    private String venueId;

    @Min(1) @Max(5)
    private int rating;

    private String comment;
}

SPORTX_EOF
cat > src/main/java/com/sportx/config/UserFactory.java << 'SPORTX_EOF'
package com.sportx.config;

import com.sportx.dto.RegisterDTO;
import com.sportx.model.Admin;
import com.sportx.model.Player;
import com.sportx.model.User;
import com.sportx.model.VenueOwner;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Factory Method Pattern — encapsulates user creation logic.
 * Controllers/Services never call "new Player()" directly.
 * Design Pattern: Creational — Factory Method
 */
@Component
public class UserFactory {

    public User createUser(RegisterDTO dto, String encodedPassword) {
        return switch (dto.getRole()) {
            case PLAYER -> buildPlayer(dto, encodedPassword);
            case VENUE_OWNER -> buildVenueOwner(dto, encodedPassword);
            case ADMIN -> buildAdmin(dto, encodedPassword);
        };
    }

    private Player buildPlayer(RegisterDTO dto, String encodedPassword) {
        Player player = new Player();
        populate(player, dto, encodedPassword);
        return player;
    }

    private VenueOwner buildVenueOwner(RegisterDTO dto, String encodedPassword) {
        VenueOwner owner = new VenueOwner();
        populate(owner, dto, encodedPassword);
        owner.setBusinessLicense(dto.getBusinessLicense());
        return owner;
    }

    private Admin buildAdmin(RegisterDTO dto, String encodedPassword) {
        Admin admin = new Admin();
        populate(admin, dto, encodedPassword);
        return admin;
    }

    private void populate(User user, RegisterDTO dto, String encodedPassword) {
        user.setUserId("USR-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        user.setName(dto.getName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhoneNumber());
        user.setPassword(encodedPassword);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/config/PaymentStrategy.java << 'SPORTX_EOF'
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

SPORTX_EOF
cat > src/main/java/com/sportx/config/PaymentStrategies.java << 'SPORTX_EOF'
package com.sportx.config;

import org.springframework.stereotype.Component;

/**
 * Concrete Strategy: Card Payment
 */
@Component("cardPayment")
class CardPaymentStrategy implements PaymentStrategy {
    @Override
    public String pay(double amount) {
        return "CARD-TXN-" + System.currentTimeMillis();
    }

    @Override
    public String getMethodName() { return "CARD"; }
}

/**
 * Concrete Strategy: UPI Payment
 */
@Component("upiPayment")
class UpiPaymentStrategy implements PaymentStrategy {
    @Override
    public String pay(double amount) {
        return "UPI-TXN-" + System.currentTimeMillis();
    }

    @Override
    public String getMethodName() { return "UPI"; }
}

/**
 * Concrete Strategy: Wallet Payment
 */
@Component("walletPayment")
class WalletPaymentStrategy implements PaymentStrategy {
    @Override
    public String pay(double amount) {
        return "WALLET-TXN-" + System.currentTimeMillis();
    }

    @Override
    public String getMethodName() { return "WALLET"; }
}

SPORTX_EOF
cat > src/main/java/com/sportx/config/PaymentContext.java << 'SPORTX_EOF'
package com.sportx.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Context that selects the correct PaymentStrategy at runtime.
 * Design Pattern: Behavioral — Strategy (Context class)
 * Design Principle: OCP — new payment methods added without touching existing code.
 */
@Component
public class PaymentContext {

    private final Map<String, PaymentStrategy> strategies;

    @Autowired
    public PaymentContext(Map<String, PaymentStrategy> strategies) {
        this.strategies = strategies;
    }

    public String executePayment(String method, double amount) {
        PaymentStrategy strategy = switch (method.toUpperCase()) {
            case "UPI"    -> strategies.get("upiPayment");
            case "WALLET" -> strategies.get("walletPayment");
            default       -> strategies.get("cardPayment");
        };
        return strategy.pay(amount);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/config/SecurityConfig.java << 'SPORTX_EOF'
package com.sportx.config;

import com.sportx.service.UserDetailsServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

/**
 * Spring Security Configuration.
 * Design Pattern: Proxy (Spring Security wraps all controller access)
 * MVC Architecture: Security sits as a cross-cutting concern
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/", "/auth/**", "/venues", "/venues/search",
                                 "/venues/{id}", "/css/**", "/js/**",
                                 "/h2-console/**").permitAll()
                .requestMatchers("/player/**").hasRole("PLAYER")
                .requestMatchers("/owner/**").hasRole("VENUE_OWNER")
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/auth/login")
                .loginProcessingUrl("/auth/login")
                .usernameParameter("email")
                .passwordParameter("password")
                .successHandler((req, res, auth) -> {
                    var authorities = auth.getAuthorities();
                    String role = authorities.iterator().next().getAuthority();
                    if (role.equals("ROLE_ADMIN")) {
                        res.sendRedirect("/admin/dashboard");
                    } else if (role.equals("ROLE_VENUE_OWNER")) {
                        res.sendRedirect("/owner/dashboard");
                    } else {
                        res.sendRedirect("/player/dashboard");
                    }
                })
                .failureUrl("/auth/login?error=true")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/auth/logout"))
                .logoutSuccessUrl("/")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            )
            .csrf(csrf -> csrf
                .ignoringRequestMatchers("/h2-console/**")
            )
            .headers(headers -> headers
                .frameOptions(f -> f.sameOrigin()) // For H2 console
            );

        return http.build();
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/config/DataInitializer.java << 'SPORTX_EOF'
package com.sportx.config;

import com.sportx.dto.RegisterDTO;
import com.sportx.model.*;
import com.sportx.model.enums.SlotStatus;
import com.sportx.model.enums.SportType;
import com.sportx.model.enums.UserRole;
import com.sportx.repository.*;
import com.sportx.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Seeds initial demo data on application startup.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired private UserService userService;
    @Autowired private VenueRepository venueRepository;
    @Autowired private CourtRepository courtRepository;
    @Autowired private SlotRepository slotRepository;
    @Autowired private UserRepository userRepository;

    @Override
    public void run(String... args) {
        seedUsers();
        seedVenues();
    }

    private void seedUsers() {
        // Admin
        RegisterDTO admin = new RegisterDTO();
        admin.setName("SportX Admin");
        admin.setEmail("admin@sportx.com");
        admin.setPassword("admin123");
        admin.setPhoneNumber("9000000001");
        admin.setRole(UserRole.ADMIN);
        userService.register(admin);

        // Venue Owner
        RegisterDTO owner = new RegisterDTO();
        owner.setName("Rahul Sports");
        owner.setEmail("owner@sportx.com");
        owner.setPassword("owner123");
        owner.setPhoneNumber("9000000002");
        owner.setRole(UserRole.VENUE_OWNER);
        owner.setBusinessLicense("LIC-2024-SPORT");
        userService.register(owner);

        // Player
        RegisterDTO player = new RegisterDTO();
        player.setName("Aditya Kumar");
        player.setEmail("player@sportx.com");
        player.setPassword("player123");
        player.setPhoneNumber("9000000003");
        player.setRole(UserRole.PLAYER);
        userService.register(player);
    }

    private void seedVenues() {
        VenueOwner owner = (VenueOwner) userRepository.findByEmail("owner@sportx.com").orElseThrow();

        // Venue 1: Badminton
        Venue v1 = new Venue();
        v1.setVenueId("VEN-DEMO001");
        v1.setName("Champions Badminton Academy");
        v1.setAddress("12 MG Road");
        v1.setCity("Bangalore");
        v1.setDescription("State-of-the-art badminton courts with synthetic flooring and LED lighting.");
        v1.setImageUrl("https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800");
        v1.setSportTypes(List.of(SportType.BADMINTON));
        v1.setVerified(true);
        v1.setAvgRating(4.5);
        v1.setOwner(owner);
        venueRepository.save(v1);
        addCourtsAndSlots(v1, "Badminton Court A", SportType.BADMINTON, 400.0);

        // Venue 2: Football
        Venue v2 = new Venue();
        v2.setVenueId("VEN-DEMO002");
        v2.setName("Goal Zone Football Arena");
        v2.setAddress("45 Whitefield");
        v2.setCity("Bangalore");
        v2.setDescription("5-a-side and 7-a-side turf football grounds with floodlights.");
        v2.setImageUrl("https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800");
        v2.setSportTypes(List.of(SportType.FOOTBALL));
        v2.setVerified(true);
        v2.setAvgRating(4.2);
        v2.setOwner(owner);
        venueRepository.save(v2);
        addCourtsAndSlots(v2, "Turf Ground 1", SportType.FOOTBALL, 1200.0);

        // Venue 3: Tennis
        Venue v3 = new Venue();
        v3.setVenueId("VEN-DEMO003");
        v3.setName("Ace Tennis Club");
        v3.setAddress("7 Koramangala");
        v3.setCity("Bangalore");
        v3.setDescription("Professional clay and hard courts, open year-round.");
        v3.setImageUrl("https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800");
        v3.setSportTypes(List.of(SportType.TENNIS));
        v3.setVerified(true);
        v3.setAvgRating(4.7);
        v3.setOwner(owner);
        venueRepository.save(v3);
        addCourtsAndSlots(v3, "Court 1 (Clay)", SportType.TENNIS, 600.0);

        // Venue 4: Cricket
        Venue v4 = new Venue();
        v4.setVenueId("VEN-DEMO004");
        v4.setName("SixerBox Cricket Arena");
        v4.setAddress("22 Indiranagar");
        v4.setCity("Bangalore");
        v4.setDescription("Box cricket ground with pitch, nets, and scoreboard.");
        v4.setImageUrl("https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800");
        v4.setSportTypes(List.of(SportType.CRICKET));
        v4.setVerified(true);
        v4.setAvgRating(4.3);
        v4.setOwner(owner);
        venueRepository.save(v4);
        addCourtsAndSlots(v4, "Box Cricket Pitch 1", SportType.CRICKET, 2000.0);
    }

    private void addCourtsAndSlots(Venue venue, String courtName, SportType sport, double price) {
        Court court = new Court();
        court.setCourtId("CRT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        court.setCourtName(courtName);
        court.setSport(sport);
        court.setVenue(venue);
        courtRepository.save(court);

        // Create slots for today and next 3 days
        LocalDateTime base = LocalDateTime.now().toLocalDate().atTime(6, 0);
        for (int day = 0; day < 4; day++) {
            for (int hour = 0; hour < 12; hour++) {
                Slot slot = new Slot();
                slot.setSlotId("SLT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
                slot.setStartTime(base.plusDays(day).plusHours(hour));
                slot.setEndTime(base.plusDays(day).plusHours(hour + 1));
                slot.setPrice(price);
                slot.setStatus(SlotStatus.AVAILABLE);
                slot.setCourt(court);
                slotRepository.save(slot);
            }
        }
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/service/UserDetailsServiceImpl.java << 'SPORTX_EOF'
package com.sportx.service;

import com.sportx.model.User;
import com.sportx.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Bridges Spring Security with our User entity.
 * Design Pattern: Adapter (adapts our User model to Spring Security's UserDetails)
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + email));

        String roleName = "ROLE_" + user.getRole().name();

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                List.of(new SimpleGrantedAuthority(roleName))
        );
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/service/UserService.java << 'SPORTX_EOF'
package com.sportx.service;

import com.sportx.config.UserFactory;
import com.sportx.dto.RegisterDTO;
import com.sportx.model.User;
import com.sportx.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * UserService — handles registration and profile operations.
 * Design Principle: SRP — only user-related business logic here.
 * Design Principle: DIP — depends on abstractions (Repository interface).
 * Design Pattern: Facade — hides JPA complexity from controllers.
 */
@Service
@Transactional
public class UserService {

    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private UserFactory userFactory;

    public User register(RegisterDTO dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        String encoded = passwordEncoder.encode(dto.getPassword());
        User user = userFactory.createUser(dto, encoded);
        return userRepository.save(user);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public Optional<User> findByUserId(String userId) {
        return userRepository.findByUserId(userId);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User updateProfile(String email, String name, String phone) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.updateProfile(name, phone);
        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/service/VenueService.java << 'SPORTX_EOF'
package com.sportx.service;

import com.sportx.dto.VenueDTO;
import com.sportx.model.Court;
import com.sportx.model.Slot;
import com.sportx.model.Venue;
import com.sportx.model.VenueOwner;
import com.sportx.model.enums.SportType;
import com.sportx.repository.CourtRepository;
import com.sportx.repository.SlotRepository;
import com.sportx.repository.VenueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * VenueService — venue CRUD and search.
 * Design Pattern: Facade
 * Design Principle: SRP, OCP
 */
@Service
@Transactional
public class VenueService {

    @Autowired private VenueRepository venueRepository;
    @Autowired private CourtRepository courtRepository;
    @Autowired private SlotRepository slotRepository;

    public List<Venue> searchVenues(String city, SportType sport) {
        if ((city == null || city.isBlank()) && sport == null) {
            return venueRepository.findByIsVerifiedTrue();
        }
        return venueRepository.searchVenues(city, sport);
    }

    public List<Venue> getAllVerified() {
        return venueRepository.findByIsVerifiedTrue();
    }

    public List<Venue> getAllForAdmin() {
        return venueRepository.findAll();
    }

    public Optional<Venue> findByVenueId(String venueId) {
        return venueRepository.findByVenueId(venueId);
    }

    public Optional<Venue> findById(Long id) {
        return venueRepository.findById(id);
    }

    public List<Venue> findByOwner(Long ownerId) {
        return venueRepository.findByOwner_Id(ownerId);
    }

    public Venue createVenue(VenueDTO dto, VenueOwner owner) {
        Venue venue = new Venue();
        venue.setVenueId("VEN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        venue.setName(dto.getName());
        venue.setAddress(dto.getAddress());
        venue.setCity(dto.getCity());
        venue.setDescription(dto.getDescription());
        venue.setImageUrl(dto.getImageUrl() != null && !dto.getImageUrl().isBlank()
                ? dto.getImageUrl()
                : "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800");
        venue.setSportTypes(dto.getSportTypes());
        venue.setOwner(owner);
        return venueRepository.save(venue);
    }

    public Venue verifyVenue(String venueId) {
        Venue venue = venueRepository.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        venue.setVerified(true);
        return venueRepository.save(venue);
    }

    public Court addCourt(Long venueId, String courtName, SportType sport) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        Court court = new Court();
        court.setCourtId("CRT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        court.setCourtName(courtName);
        court.setSport(sport);
        court.setVenue(venue);
        return courtRepository.save(court);
    }

    public List<Court> getCourtsForVenue(Long venueId) {
        return courtRepository.findByVenue_Id(venueId);
    }

    public List<Slot> getSlotsForCourt(Long courtId) {
        return slotRepository.findByCourt_Id(courtId);
    }

    public void deleteVenue(Long id) {
        venueRepository.deleteById(id);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/service/BookingService.java << 'SPORTX_EOF'
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

SPORTX_EOF
cat > src/main/java/com/sportx/service/NotificationService.java << 'SPORTX_EOF'
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

SPORTX_EOF
cat > src/main/java/com/sportx/service/SlotService.java << 'SPORTX_EOF'
package com.sportx.service;

import com.sportx.dto.SlotDTO;
import com.sportx.model.Court;
import com.sportx.model.Slot;
import com.sportx.model.enums.SlotStatus;
import com.sportx.repository.CourtRepository;
import com.sportx.repository.SlotRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * SlotService — manages time slot creation and availability.
 * Design Principle: SRP, DIP
 */
@Service
@Transactional
public class SlotService {

    @Autowired private SlotRepository slotRepository;
    @Autowired private CourtRepository courtRepository;

    public Slot createSlot(SlotDTO dto) {
        Court court = courtRepository.findById(dto.getCourtId())
                .orElseThrow(() -> new RuntimeException("Court not found"));

        Slot slot = new Slot();
        slot.setSlotId("SLT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        slot.setStartTime(dto.getStartTime());
        slot.setEndTime(dto.getEndTime());
        slot.setPrice(dto.getPrice());
        slot.setStatus(SlotStatus.AVAILABLE);
        slot.setCourt(court);
        return slotRepository.save(slot);
    }

    public List<Slot> getSlotsByCourtAndDate(Long courtId, LocalDate date) {
        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to   = date.atTime(23, 59, 59);
        return slotRepository.findByCourtAndDate(courtId, from, to);
    }

    public List<Slot> getAvailableSlots(Long courtId) {
        return slotRepository.findByCourt_IdAndStatus(courtId, SlotStatus.AVAILABLE);
    }

    public void blockSlot(String slotId) {
        Slot slot = slotRepository.findBySlotId(slotId)
                .orElseThrow(() -> new RuntimeException("Slot not found"));
        slot.setStatus(SlotStatus.BLOCKED);
        slotRepository.save(slot);
    }

    public void deleteSlot(Long id) {
        slotRepository.deleteById(id);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/service/ReviewService.java << 'SPORTX_EOF'
package com.sportx.service;

import com.sportx.dto.ReviewDTO;
import com.sportx.model.Player;
import com.sportx.model.Review;
import com.sportx.model.Venue;
import com.sportx.repository.ReviewRepository;
import com.sportx.repository.VenueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * ReviewService — handles rating and review submission.
 * Design Principle: SRP
 */
@Service
@Transactional
public class ReviewService {

    @Autowired private ReviewRepository reviewRepository;
    @Autowired private VenueRepository venueRepository;

    public Review addReview(Player player, ReviewDTO dto) {
        Venue venue = venueRepository.findByVenueId(dto.getVenueId())
                .orElseThrow(() -> new RuntimeException("Venue not found"));

        if (reviewRepository.existsByPlayer_IdAndVenue_Id(player.getId(), venue.getId())) {
            throw new IllegalStateException("You have already reviewed this venue");
        }

        Review review = new Review();
        review.setReviewId("REV-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        review.setRating(dto.getRating());
        review.setComment(dto.getComment());
        review.setPlayer(player);
        review.setVenue(venue);
        Review saved = reviewRepository.save(review);

        // Refresh average rating on venue
        venue.getReviews().add(saved);
        venue.updateAvgRating();
        venueRepository.save(venue);

        return saved;
    }

    public List<Review> getVenueReviews(Long venueId) {
        return reviewRepository.findByVenue_Id(venueId);
    }

    public List<Review> getPlayerReviews(Long playerId) {
        return reviewRepository.findByPlayer_Id(playerId);
    }

    public boolean hasReviewed(Long playerId, Long venueId) {
        return reviewRepository.existsByPlayer_IdAndVenue_Id(playerId, venueId);
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/controller/AuthController.java << 'SPORTX_EOF'
package com.sportx.controller;

import com.sportx.dto.RegisterDTO;
import com.sportx.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/**
 * AuthController — MVC Controller for authentication flows.
 * MVC Role: Controller (C)
 * Handles: Register, Login, Logout
 */
@Controller
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @GetMapping("/login")
    public String loginPage(@RequestParam(required = false) String error,
                            @RequestParam(required = false) String logout,
                            Model model) {
        if (error != null) model.addAttribute("errorMsg", "Invalid email or password.");
        if (logout != null) model.addAttribute("successMsg", "You have been logged out.");
        return "auth/login";
    }

    @GetMapping("/register")
    public String registerPage(Model model) {
        model.addAttribute("registerDTO", new RegisterDTO());
        model.addAttribute("roles", com.sportx.model.enums.UserRole.values());
        return "auth/register";
    }

    @PostMapping("/register")
    public String register(@Valid @ModelAttribute("registerDTO") RegisterDTO dto,
                           BindingResult result,
                           Model model,
                           RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("roles", com.sportx.model.enums.UserRole.values());
            return "auth/register";
        }
        try {
            userService.register(dto);
            redirectAttributes.addFlashAttribute("successMsg",
                    "Registration successful! Please log in.");
            return "redirect:/auth/login";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMsg", e.getMessage());
            model.addAttribute("roles", com.sportx.model.enums.UserRole.values());
            return "auth/register";
        }
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/controller/HomeController.java << 'SPORTX_EOF'
package com.sportx.controller;

import com.sportx.model.Venue;
import com.sportx.model.enums.SportType;
import com.sportx.service.VenueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * HomeController — public-facing pages.
 * MVC Role: Controller (C)
 */
@Controller
public class HomeController {

    @Autowired
    private VenueService venueService;

    @GetMapping("/")
    public String home(Model model) {
        List<Venue> featured = venueService.getAllVerified();
        model.addAttribute("venues", featured.stream().limit(6).toList());
        model.addAttribute("sportTypes", SportType.values());
        return "home";
    }

    @GetMapping("/venues")
    public String venues(@RequestParam(required = false) String city,
                         @RequestParam(required = false) SportType sport,
                         Model model) {
        List<Venue> venues = venueService.searchVenues(city, sport);
        model.addAttribute("venues", venues);
        model.addAttribute("sportTypes", SportType.values());
        model.addAttribute("selectedCity", city);
        model.addAttribute("selectedSport", sport);
        return "venues";
    }

    @GetMapping("/venues/{venueId}")
    public String venueDetail(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        model.addAttribute("venue", venue);
        return "venue-detail";
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/controller/PlayerController.java << 'SPORTX_EOF'
package com.sportx.controller;

import com.sportx.dto.BookingDTO;
import com.sportx.dto.ReviewDTO;
import com.sportx.model.*;
import com.sportx.model.enums.SportType;
import com.sportx.service.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * PlayerController — all player-facing actions.
 * MVC Role: Controller (C)
 * Owns use cases: Book Slot, Cancel Booking, View History, Rate & Review, Manage Profile
 */
@Controller
@RequestMapping("/player")
public class PlayerController {

    @Autowired private UserService userService;
    @Autowired private VenueService venueService;
    @Autowired private BookingService bookingService;
    @Autowired private SlotService slotService;
    @Autowired private ReviewService reviewService;
    @Autowired private NotificationService notificationService;

    private Player getCurrentPlayer(UserDetails userDetails) {
        return (Player) userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Player not found"));
    }

    /* ── Dashboard ── */
    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        Player player = getCurrentPlayer(userDetails);
        List<Booking> bookings = bookingService.getPlayerBookings(player.getId());
        long unread = notificationService.getUnreadCount(player.getUserId());

        model.addAttribute("player", player);
        model.addAttribute("bookings", bookings.stream().limit(5).toList());
        model.addAttribute("totalBookings", bookings.size());
        model.addAttribute("unreadCount", unread);
        return "player/dashboard";
    }

    /* ── Search Venues ── */
    @GetMapping("/search")
    public String searchVenues(@RequestParam(required = false) String city,
                                @RequestParam(required = false) SportType sport,
                                Model model) {
        model.addAttribute("venues", venueService.searchVenues(city, sport));
        model.addAttribute("sportTypes", SportType.values());
        model.addAttribute("selectedCity", city);
        model.addAttribute("selectedSport", sport);
        return "player/search";
    }

    /* ── View Venue & Available Slots ── */
    @GetMapping("/venue/{venueId}")
    public String viewVenue(@PathVariable String venueId,
                             @AuthenticationPrincipal UserDetails userDetails,
                             Model model) {
        Player player = getCurrentPlayer(userDetails);
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        List<Court> courts = venueService.getCourtsForVenue(venue.getId());

        model.addAttribute("venue", venue);
        model.addAttribute("courts", courts);
        model.addAttribute("hasReviewed", reviewService.hasReviewed(player.getId(), venue.getId()));
        model.addAttribute("reviews", reviewService.getVenueReviews(venue.getId()));
        model.addAttribute("reviewDTO", new ReviewDTO());
        return "player/venue-detail";
    }

    /* ── Book Slot ── */
    @GetMapping("/book/{slotId}")
    public String bookSlotPage(@PathVariable String slotId, Model model) {
        model.addAttribute("slotId", slotId);
        model.addAttribute("bookingDTO", new BookingDTO());
        return "player/book-slot";
    }

    @PostMapping("/book")
    public String confirmBooking(@ModelAttribute BookingDTO dto,
                                  @AuthenticationPrincipal UserDetails userDetails,
                                  RedirectAttributes redirectAttributes) {
        Player player = getCurrentPlayer(userDetails);
        try {
            Booking booking = bookingService.bookSlot(player, dto.getSlotId(), dto.getPaymentMethod());
            redirectAttributes.addFlashAttribute("successMsg",
                    "Booking confirmed! ID: " + booking.getBookingId());
            return "redirect:/player/bookings";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/player/search";
        }
    }

    /* ── Booking History ── */
    @GetMapping("/bookings")
    public String bookingHistory(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        Player player = getCurrentPlayer(userDetails);
        model.addAttribute("bookings", bookingService.getPlayerBookings(player.getId()));
        return "player/bookings";
    }

    /* ── Cancel Booking ── */
    @PostMapping("/cancel/{bookingId}")
    public String cancelBooking(@PathVariable String bookingId,
                                 @AuthenticationPrincipal UserDetails userDetails,
                                 RedirectAttributes redirectAttributes) {
        try {
            bookingService.cancelBooking(bookingId, userDetails.getUsername());
            redirectAttributes.addFlashAttribute("successMsg", "Booking cancelled. Refund initiated.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/player/bookings";
    }

    /* ── Rate & Review ── */
    @PostMapping("/review")
    public String submitReview(@Valid @ModelAttribute ReviewDTO dto,
                                @AuthenticationPrincipal UserDetails userDetails,
                                RedirectAttributes redirectAttributes) {
        Player player = getCurrentPlayer(userDetails);
        try {
            reviewService.addReview(player, dto);
            redirectAttributes.addFlashAttribute("successMsg", "Review submitted!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/player/venue/" + dto.getVenueId();
    }

    /* ── Profile ── */
    @GetMapping("/profile")
    public String profile(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        model.addAttribute("player", getCurrentPlayer(userDetails));
        return "player/profile";
    }

    @PostMapping("/profile")
    public String updateProfile(@RequestParam String name,
                                 @RequestParam String phoneNumber,
                                 @AuthenticationPrincipal UserDetails userDetails,
                                 RedirectAttributes redirectAttributes) {
        userService.updateProfile(userDetails.getUsername(), name, phoneNumber);
        redirectAttributes.addFlashAttribute("successMsg", "Profile updated successfully.");
        return "redirect:/player/profile";
    }

    /* ── Notifications ── */
    @GetMapping("/notifications")
    public String notifications(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        Player player = getCurrentPlayer(userDetails);
        notificationService.markAllRead(player.getUserId());
        model.addAttribute("notifications",
                notificationService.getNotificationsForUser(player.getUserId()));
        return "player/notifications";
    }

    /* ── Slots for Court (AJAX/page) ── */
    @GetMapping("/slots/{courtId}")
    public String viewSlots(@PathVariable Long courtId, Model model) {
        model.addAttribute("slots", slotService.getAvailableSlots(courtId));
        model.addAttribute("courtId", courtId);
        return "player/slots";
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/controller/VenueOwnerController.java << 'SPORTX_EOF'
package com.sportx.controller;

import com.sportx.dto.SlotDTO;
import com.sportx.dto.VenueDTO;
import com.sportx.model.*;
import com.sportx.model.enums.SportType;
import com.sportx.service.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * VenueOwnerController — manage venues, courts, slots, bookings, reports.
 * MVC Role: Controller (C)
 * Owns use cases: Add/Update Venue, Manage Slots & Pricing, Manage Bookings, View Reports
 */
@Controller
@RequestMapping("/owner")
public class VenueOwnerController {

    @Autowired private UserService userService;
    @Autowired private VenueService venueService;
    @Autowired private BookingService bookingService;
    @Autowired private SlotService slotService;

    private VenueOwner getCurrentOwner(UserDetails userDetails) {
        return (VenueOwner) userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Owner not found"));
    }

    /* ── Dashboard ── */
    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        VenueOwner owner = getCurrentOwner(userDetails);
        List<Venue> venues = venueService.findByOwner(owner.getId());
        long totalBookings = venues.stream()
                .mapToLong(v -> bookingService.countVenueBookings(v.getId()))
                .sum();

        model.addAttribute("owner", owner);
        model.addAttribute("venues", venues);
        model.addAttribute("totalBookings", totalBookings);
        return "venueowner/dashboard";
    }

    /* ── Add Venue ── */
    @GetMapping("/venue/add")
    public String addVenuePage(Model model) {
        model.addAttribute("venueDTO", new VenueDTO());
        model.addAttribute("sportTypes", SportType.values());
        return "venueowner/add-venue";
    }

    @PostMapping("/venue/add")
    public String addVenue(@Valid @ModelAttribute("venueDTO") VenueDTO dto,
                            BindingResult result,
                            @AuthenticationPrincipal UserDetails userDetails,
                            Model model,
                            RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("sportTypes", SportType.values());
            return "venueowner/add-venue";
        }
        VenueOwner owner = getCurrentOwner(userDetails);
        Venue venue = venueService.createVenue(dto, owner);
        redirectAttributes.addFlashAttribute("successMsg",
                "Venue '" + venue.getName() + "' submitted for admin verification.");
        return "redirect:/owner/dashboard";
    }

    /* ── Venue Courts ── */
    @GetMapping("/venue/{venueId}/courts")
    public String manageCourts(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        model.addAttribute("venue", venue);
        model.addAttribute("courts", venueService.getCourtsForVenue(venue.getId()));
        model.addAttribute("sportTypes", SportType.values());
        return "venueowner/courts";
    }

    @PostMapping("/venue/{venueId}/court/add")
    public String addCourt(@PathVariable String venueId,
                            @RequestParam String courtName,
                            @RequestParam SportType sport,
                            RedirectAttributes redirectAttributes) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        venueService.addCourt(venue.getId(), courtName, sport);
        redirectAttributes.addFlashAttribute("successMsg", "Court added successfully.");
        return "redirect:/owner/venue/" + venueId + "/courts";
    }

    /* ── Manage Slots ── */
    @GetMapping("/court/{courtId}/slots")
    public String manageSlots(@PathVariable Long courtId, Model model) {
        model.addAttribute("slots", slotService.getAvailableSlots(courtId));
        model.addAttribute("courtId", courtId);
        model.addAttribute("slotDTO", new SlotDTO());
        return "venueowner/slots";
    }

    @PostMapping("/slot/add")
    public String addSlot(@ModelAttribute SlotDTO dto, RedirectAttributes redirectAttributes) {
        slotService.createSlot(dto);
        redirectAttributes.addFlashAttribute("successMsg", "Slot created successfully.");
        return "redirect:/owner/court/" + dto.getCourtId() + "/slots";
    }

    @PostMapping("/slot/block/{slotId}")
    public String blockSlot(@PathVariable String slotId,
                             @RequestParam Long courtId,
                             RedirectAttributes redirectAttributes) {
        slotService.blockSlot(slotId);
        redirectAttributes.addFlashAttribute("successMsg", "Slot blocked.");
        return "redirect:/owner/court/" + courtId + "/slots";
    }

    /* ── Manage Bookings ── */
    @GetMapping("/venue/{venueId}/bookings")
    public String manageBookings(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        model.addAttribute("venue", venue);
        model.addAttribute("bookings", bookingService.getVenueBookings(venue.getId()));
        return "venueowner/bookings";
    }

    /* ── View Reports ── */
    @GetMapping("/venue/{venueId}/reports")
    public String viewReports(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        List<Booking> bookings = bookingService.getVenueBookings(venue.getId());
        double revenue = bookings.stream()
                .filter(b -> b.getStatus().name().equals("CONFIRMED") ||
                             b.getStatus().name().equals("COMPLETED"))
                .mapToDouble(Booking::getTotalAmount)
                .sum();

        model.addAttribute("venue", venue);
        model.addAttribute("bookings", bookings);
        model.addAttribute("totalRevenue", revenue);
        model.addAttribute("totalBookings", bookings.size());
        return "venueowner/reports";
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/controller/AdminController.java << 'SPORTX_EOF'
package com.sportx.controller;

import com.sportx.model.User;
import com.sportx.model.Venue;
import com.sportx.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * AdminController — system administration.
 * MVC Role: Controller (C)
 * Owns use cases: Verify Venue/Partner, Manage Users
 */
@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired private UserService userService;
    @Autowired private VenueService venueService;
    @Autowired private BookingService bookingService;
    @Autowired private NotificationService notificationService;

    /* ── Dashboard ── */
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        List<Venue> allVenues = venueService.getAllForAdmin();
        List<User> allUsers = userService.findAll();
        long pendingVenues = allVenues.stream().filter(v -> !v.isVerified()).count();

        model.addAttribute("totalVenues", allVenues.size());
        model.addAttribute("pendingVenues", pendingVenues);
        model.addAttribute("totalUsers", allUsers.size());
        model.addAttribute("totalBookings", bookingService.getAllBookings().size());
        model.addAttribute("venues", allVenues);
        return "admin/dashboard";
    }

    /* ── Verify Venue ── */
    @GetMapping("/venues")
    public String manageVenues(Model model) {
        model.addAttribute("venues", venueService.getAllForAdmin());
        return "admin/venues";
    }

    @PostMapping("/venue/verify/{venueId}")
    public String verifyVenue(@PathVariable String venueId,
                               RedirectAttributes redirectAttributes) {
        Venue venue = venueService.verifyVenue(venueId);
        // Notify owner
        notificationService.notifyVenueVerified(
                venue.getOwner().getUserId(), venue.getName());
        redirectAttributes.addFlashAttribute("successMsg",
                "Venue '" + venue.getName() + "' verified successfully.");
        return "redirect:/admin/venues";
    }

    @PostMapping("/venue/delete/{id}")
    public String deleteVenue(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        venueService.deleteVenue(id);
        redirectAttributes.addFlashAttribute("successMsg", "Venue deleted.");
        return "redirect:/admin/venues";
    }

    /* ── Manage Users ── */
    @GetMapping("/users")
    public String manageUsers(Model model) {
        model.addAttribute("users", userService.findAll());
        return "admin/users";
    }

    @PostMapping("/user/delete/{id}")
    public String deleteUser(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        userService.deleteUser(id);
        redirectAttributes.addFlashAttribute("successMsg", "User deleted.");
        return "redirect:/admin/users";
    }

    /* ── All Bookings ── */
    @GetMapping("/bookings")
    public String allBookings(Model model) {
        model.addAttribute("bookings", bookingService.getAllBookings());
        return "admin/bookings";
    }
}

SPORTX_EOF
cat > src/main/java/com/sportx/SportxApplication.java << 'SPORTX_EOF'
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

SPORTX_EOF
echo '✅ All Java files written'
cat > src/main/resources/static/css/style.css << 'SPORTX_EOF'
/* ============================================================
   SportX — Design System
   Palette: White + Soft Gray + Emerald Green accent
   ============================================================ */

:root {
  --white:       #ffffff;
  --gray-50:     #f8f9fa;
  --gray-100:    #f1f3f5;
  --gray-200:    #e9ecef;
  --gray-300:    #dee2e6;
  --gray-400:    #ced4da;
  --gray-500:    #adb5bd;
  --gray-600:    #6c757d;
  --gray-700:    #495057;
  --gray-800:    #343a40;
  --gray-900:    #212529;

  --accent:      #10b981;   /* Emerald */
  --accent-dark: #059669;
  --accent-light:#d1fae5;
  --accent-pale: #f0fdf4;

  --danger:      #ef4444;
  --danger-light:#fee2e2;
  --warning:     #f59e0b;
  --warning-light:#fef3c7;
  --info:        #3b82f6;
  --info-light:  #dbeafe;

  --radius-sm:   6px;
  --radius:      12px;
  --radius-lg:   16px;
  --radius-xl:   24px;

  --shadow-sm:   0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
  --shadow:      0 4px 12px rgba(0,0,0,.08);
  --shadow-lg:   0 10px 30px rgba(0,0,0,.10);

  --font:        'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --transition:  0.2s ease;
}

/* ── Reset & Base ── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html { scroll-behavior: smooth; }

body {
  font-family: var(--font);
  background: var(--gray-50);
  color: var(--gray-900);
  line-height: 1.6;
  font-size: 15px;
}

a { color: var(--accent); text-decoration: none; }
a:hover { color: var(--accent-dark); }
img { max-width: 100%; display: block; }
ul { list-style: none; }

/* ── Typography ── */
h1 { font-size: 2rem;   font-weight: 700; letter-spacing: -0.5px; }
h2 { font-size: 1.5rem; font-weight: 700; letter-spacing: -0.3px; }
h3 { font-size: 1.2rem; font-weight: 600; }
h4 { font-size: 1rem;   font-weight: 600; }
p  { color: var(--gray-600); }

/* ── Layout ── */
.container { max-width: 1200px; margin: 0 auto; padding: 0 24px; }
.page-wrapper { min-height: 100vh; display: flex; flex-direction: column; }
main { flex: 1; padding: 32px 0; }
.section { padding: 64px 0; }

/* ── Navbar ── */
.navbar {
  background: var(--white);
  border-bottom: 1px solid var(--gray-200);
  position: sticky; top: 0; z-index: 100;
  box-shadow: var(--shadow-sm);
}
.navbar-inner {
  display: flex; align-items: center;
  justify-content: space-between;
  height: 64px;
}
.navbar-brand {
  font-size: 1.25rem; font-weight: 800;
  color: var(--gray-900);
  display: flex; align-items: center; gap: 8px;
}
.navbar-brand span { color: var(--accent); }
.navbar-nav {
  display: flex; align-items: center; gap: 4px;
}
.nav-link {
  padding: 8px 14px; border-radius: var(--radius-sm);
  color: var(--gray-700); font-weight: 500;
  transition: background var(--transition), color var(--transition);
}
.nav-link:hover { background: var(--gray-100); color: var(--gray-900); }
.nav-link.active { color: var(--accent); font-weight: 600; }

/* ── Buttons ── */
.btn {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 10px 20px; border-radius: var(--radius-sm);
  font-size: 14px; font-weight: 600; cursor: pointer;
  border: none; transition: all var(--transition);
  text-decoration: none;
}
.btn-primary {
  background: var(--accent); color: var(--white);
}
.btn-primary:hover { background: var(--accent-dark); color: var(--white); transform: translateY(-1px); }
.btn-outline {
  background: transparent; color: var(--accent);
  border: 1.5px solid var(--accent);
}
.btn-outline:hover { background: var(--accent-pale); }
.btn-danger { background: var(--danger); color: var(--white); }
.btn-danger:hover { background: #dc2626; }
.btn-gray { background: var(--gray-100); color: var(--gray-700); }
.btn-gray:hover { background: var(--gray-200); }
.btn-sm { padding: 6px 14px; font-size: 13px; }
.btn-lg { padding: 14px 28px; font-size: 16px; }
.btn-block { width: 100%; justify-content: center; }

/* ── Cards ── */
.card {
  background: var(--white); border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--gray-200);
  overflow: hidden;
}
.card-body { padding: 24px; }
.card-footer { padding: 16px 24px; background: var(--gray-50); border-top: 1px solid var(--gray-200); }

/* ── Venue Card ── */
.venue-card {
  background: var(--white); border-radius: var(--radius);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--gray-200);
  overflow: hidden;
  transition: all var(--transition);
}
.venue-card:hover { box-shadow: var(--shadow-lg); transform: translateY(-4px); }
.venue-card-img {
  width: 100%; height: 200px; object-fit: cover;
}
.venue-card-body { padding: 20px; }
.venue-card-name { font-size: 1.05rem; font-weight: 700; color: var(--gray-900); margin-bottom: 6px; }
.venue-card-city { color: var(--gray-500); font-size: 13px; margin-bottom: 10px; }
.venue-card-tags { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 14px; }
.venue-card-footer {
  display: flex; justify-content: space-between; align-items: center;
  padding-top: 14px; border-top: 1px solid var(--gray-100);
}
.venue-price { font-size: 1.1rem; font-weight: 700; color: var(--accent); }
.venue-price span { font-size: 12px; font-weight: 400; color: var(--gray-500); }

/* ── Badges / Tags ── */
.badge {
  display: inline-block; padding: 3px 10px;
  border-radius: 100px; font-size: 12px; font-weight: 600;
}
.badge-green  { background: var(--accent-light); color: var(--accent-dark); }
.badge-gray   { background: var(--gray-100); color: var(--gray-600); }
.badge-red    { background: var(--danger-light); color: var(--danger); }
.badge-yellow { background: var(--warning-light); color: #b45309; }
.badge-blue   { background: var(--info-light); color: #1d4ed8; }

/* ── Sport Tag ── */
.sport-tag {
  display: inline-flex; align-items: center; gap: 4px;
  padding: 4px 10px; border-radius: 100px;
  background: var(--accent-pale); color: var(--accent-dark);
  font-size: 12px; font-weight: 600;
}

/* ── Rating ── */
.rating { display: flex; align-items: center; gap: 4px; }
.stars { color: var(--warning); font-size: 14px; }
.rating-num { font-weight: 700; font-size: 14px; color: var(--gray-800); }
.rating-count { font-size: 12px; color: var(--gray-400); }

/* ── Forms ── */
.form-group { margin-bottom: 20px; }
.form-label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
.form-control {
  width: 100%; padding: 10px 14px;
  border: 1.5px solid var(--gray-200);
  border-radius: var(--radius-sm);
  font-size: 15px; font-family: var(--font);
  transition: border-color var(--transition), box-shadow var(--transition);
  background: var(--white); color: var(--gray-900);
}
.form-control:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(16,185,129,.12);
}
.form-control.is-invalid { border-color: var(--danger); }
.form-hint { font-size: 12px; color: var(--gray-500); margin-top: 4px; }
.form-error { font-size: 12px; color: var(--danger); margin-top: 4px; }
select.form-control { appearance: none; cursor: pointer; }

/* ── Slot Picker ── */
.slots-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 10px; margin-top: 16px;
}
.slot-btn {
  padding: 12px 10px; border-radius: var(--radius-sm);
  text-align: center; cursor: pointer;
  border: 1.5px solid var(--gray-200);
  background: var(--white); transition: all var(--transition);
}
.slot-btn:hover { border-color: var(--accent); background: var(--accent-pale); }
.slot-btn.selected { border-color: var(--accent); background: var(--accent); color: var(--white); }
.slot-btn.booked { background: var(--gray-100); color: var(--gray-400); cursor: not-allowed; border-color: var(--gray-200); }
.slot-time { font-size: 13px; font-weight: 700; }
.slot-price { font-size: 12px; margin-top: 3px; opacity: 0.8; }

/* ── Table ── */
.table-wrap { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; }
th {
  background: var(--gray-50); padding: 12px 16px;
  font-size: 12px; font-weight: 700; text-transform: uppercase;
  letter-spacing: 0.5px; color: var(--gray-500);
  border-bottom: 1px solid var(--gray-200); text-align: left;
}
td {
  padding: 14px 16px; border-bottom: 1px solid var(--gray-100);
  color: var(--gray-700); font-size: 14px;
}
tr:last-child td { border-bottom: none; }
tr:hover td { background: var(--gray-50); }

/* ── Alerts / Flash ── */
.alert {
  padding: 14px 18px; border-radius: var(--radius-sm);
  font-size: 14px; font-weight: 500;
  display: flex; align-items: center; gap: 10px;
  margin-bottom: 20px;
}
.alert-success { background: var(--accent-light); color: var(--accent-dark); border: 1px solid var(--accent); }
.alert-error   { background: var(--danger-light);  color: var(--danger);      border: 1px solid var(--danger); }
.alert-info    { background: var(--info-light);    color: var(--info);        border: 1px solid var(--info); }

/* ── Dashboard Stats ── */
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 20px; margin-bottom: 32px; }
.stat-card {
  background: var(--white); border-radius: var(--radius);
  padding: 24px; border: 1px solid var(--gray-200);
  box-shadow: var(--shadow-sm);
}
.stat-label { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: var(--gray-500); }
.stat-value { font-size: 2rem; font-weight: 800; color: var(--gray-900); margin: 8px 0 4px; }
.stat-sub   { font-size: 12px; color: var(--gray-400); }

/* ── Page Header ── */
.page-header { margin-bottom: 32px; }
.page-header h1 { color: var(--gray-900); }
.page-header p { color: var(--gray-600); margin-top: 6px; }

/* ── Sidebar Layout ── */
.layout-with-sidebar { display: grid; grid-template-columns: 220px 1fr; gap: 32px; align-items: start; }
.sidebar {
  background: var(--white); border-radius: var(--radius);
  border: 1px solid var(--gray-200); padding: 16px;
  position: sticky; top: 88px;
}
.sidebar-nav a {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 14px; border-radius: var(--radius-sm);
  color: var(--gray-700); font-weight: 500; font-size: 14px;
  transition: all var(--transition);
}
.sidebar-nav a:hover { background: var(--gray-100); color: var(--gray-900); }
.sidebar-nav a.active { background: var(--accent-pale); color: var(--accent-dark); font-weight: 600; }

/* ── Hero Section ── */
.hero {
  background: linear-gradient(135deg, var(--gray-900) 0%, var(--gray-800) 100%);
  color: var(--white); padding: 80px 0; text-align: center;
}
.hero h1 { font-size: 2.8rem; color: var(--white); margin-bottom: 16px; }
.hero h1 span { color: var(--accent); }
.hero p { font-size: 1.1rem; color: var(--gray-300); margin-bottom: 36px; max-width: 540px; margin-left: auto; margin-right: auto; }

/* ── Search Bar ── */
.search-bar {
  display: flex; gap: 10px; max-width: 640px; margin: 0 auto;
  background: var(--white); padding: 8px 8px 8px 16px;
  border-radius: var(--radius-xl); box-shadow: var(--shadow-lg);
}
.search-bar input, .search-bar select {
  flex: 1; border: none; outline: none;
  font-size: 15px; color: var(--gray-900); font-family: var(--font);
  background: transparent;
}

/* ── Venue Grid ── */
.venues-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 24px; }

/* ── Notification badge ── */
.notif-badge {
  background: var(--danger); color: white;
  font-size: 10px; font-weight: 700;
  width: 18px; height: 18px;
  border-radius: 50%; display: inline-flex;
  align-items: center; justify-content: center;
  margin-left: 4px; vertical-align: top;
}

/* ── Auth Cards ── */
.auth-page {
  min-height: 100vh; display: flex; align-items: center;
  justify-content: center; background: var(--gray-50); padding: 24px;
}
.auth-card {
  background: var(--white); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg); padding: 48px 40px;
  width: 100%; max-width: 440px;
  border: 1px solid var(--gray-200);
}
.auth-logo { text-align: center; margin-bottom: 32px; }
.auth-logo h2 { font-size: 1.8rem; color: var(--gray-900); }
.auth-logo span { color: var(--accent); }

/* ── Review card ── */
.review-card {
  padding: 20px; border-radius: var(--radius);
  border: 1px solid var(--gray-200); background: var(--white);
  margin-bottom: 14px;
}
.review-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px; }
.reviewer-name { font-weight: 600; color: var(--gray-800); }

/* ── Footer ── */
footer {
  background: var(--gray-900); color: var(--gray-400);
  text-align: center; padding: 24px;
  font-size: 13px; margin-top: auto;
}
footer span { color: var(--accent); }

/* ── Divider ── */
.divider { height: 1px; background: var(--gray-200); margin: 24px 0; }

/* ── Utility ── */
.text-accent  { color: var(--accent); }
.text-muted   { color: var(--gray-500); }
.text-danger  { color: var(--danger); }
.text-center  { text-align: center; }
.text-right   { text-align: right; }
.fw-bold      { font-weight: 700; }
.fw-semibold  { font-weight: 600; }
.mt-0 { margin-top: 0; }
.mt-1 { margin-top: 8px; }
.mt-2 { margin-top: 16px; }
.mt-3 { margin-top: 24px; }
.mt-4 { margin-top: 32px; }
.mb-0 { margin-bottom: 0; }
.mb-1 { margin-bottom: 8px; }
.mb-2 { margin-bottom: 16px; }
.mb-3 { margin-bottom: 24px; }
.mb-4 { margin-bottom: 32px; }
.flex { display: flex; }
.flex-center { display: flex; align-items: center; }
.flex-between { display: flex; align-items: center; justify-content: space-between; }
.gap-1 { gap: 8px; }
.gap-2 { gap: 16px; }
.gap-3 { gap: 24px; }
.w-full { width: 100%; }
.hidden { display: none; }
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }

/* ── Responsive ── */
@media (max-width: 768px) {
  .hero h1 { font-size: 2rem; }
  .layout-with-sidebar { grid-template-columns: 1fr; }
  .sidebar { position: static; }
  .grid-2, .grid-3 { grid-template-columns: 1fr; }
  .venues-grid { grid-template-columns: 1fr; }
  .auth-card { padding: 32px 24px; }
  .search-bar { flex-direction: column; border-radius: var(--radius); }
  h1 { font-size: 1.6rem; }
}

SPORTX_EOF
cat > src/main/resources/templates/home.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>SportX — Book Sports Venues Instantly</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">

<!-- Navbar -->
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/venues}" class="nav-link">Browse Venues</a></li>
      <li sec:authorize="isAnonymous()"><a th:href="@{/auth/login}" class="btn btn-outline btn-sm">Login</a></li>
      <li sec:authorize="isAnonymous()"><a th:href="@{/auth/register}" class="btn btn-primary btn-sm">Sign Up</a></li>
      <li sec:authorize="hasRole('PLAYER')"><a th:href="@{/player/dashboard}" class="btn btn-primary btn-sm">Dashboard</a></li>
      <li sec:authorize="hasRole('VENUE_OWNER')"><a th:href="@{/owner/dashboard}" class="btn btn-primary btn-sm">Dashboard</a></li>
      <li sec:authorize="hasRole('ADMIN')"><a th:href="@{/admin/dashboard}" class="btn btn-primary btn-sm">Dashboard</a></li>
      <li sec:authorize="isAuthenticated()"><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<!-- Hero -->
<section class="hero">
  <div class="container">
    <h1>Book Your <span>Perfect</span> Court<br/>Instantly, Anywhere</h1>
    <p>Discover and book badminton, tennis, football, cricket, and swimming venues near you in seconds.</p>

    <form th:action="@{/venues}" method="get" class="search-bar">
      <input type="text" name="city" placeholder="Enter city or area..." style="min-width:160px;"/>
      <select name="sport">
        <option value="">All Sports</option>
        <option th:each="s : ${sportTypes}" th:value="${s}" th:text="${s}">Sport</option>
      </select>
      <button type="submit" class="btn btn-primary">Search</button>
    </form>
  </div>
</section>

<!-- Features -->
<section class="section" style="background: var(--white);">
  <div class="container">
    <div style="text-align:center; margin-bottom:48px;">
      <h2>Why Choose SportX?</h2>
      <p>Everything you need to find and book your next game.</p>
    </div>
    <div class="grid-3">
      <div style="text-align:center; padding:32px 20px;">
        <div style="font-size:2.5rem; margin-bottom:16px;">🏸</div>
        <h3>5 Sports Supported</h3>
        <p>Badminton, Football, Tennis, Cricket, and Swimming — all in one platform.</p>
      </div>
      <div style="text-align:center; padding:32px 20px;">
        <div style="font-size:2.5rem; margin-bottom:16px;">⚡</div>
        <h3>Instant Booking</h3>
        <p>Select your slot, pay securely, and get a confirmation in under 30 seconds.</p>
      </div>
      <div style="text-align:center; padding:32px 20px;">
        <div style="font-size:2.5rem; margin-bottom:16px;">⭐</div>
        <h3>Verified Venues</h3>
        <p>Every venue is reviewed by our admin team. Only quality courts make it in.</p>
      </div>
    </div>
  </div>
</section>

<!-- Featured Venues -->
<section class="section">
  <div class="container">
    <div class="flex-between mb-3">
      <div>
        <h2>Featured Venues</h2>
        <p>Top-rated courts near you</p>
      </div>
      <a th:href="@{/venues}" class="btn btn-outline">View All</a>
    </div>

    <div class="venues-grid">
      <div th:each="venue : ${venues}" class="venue-card">
        <img th:src="${venue.imageUrl}" th:alt="${venue.name}" class="venue-card-img"
             onerror="this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800'"/>
        <div class="venue-card-body">
          <div class="venue-card-name" th:text="${venue.name}">Venue Name</div>
          <div class="venue-card-city">📍 <span th:text="${venue.city}">City</span></div>
          <div class="venue-card-tags">
            <span th:each="sport : ${venue.sportTypes}" class="sport-tag" th:text="${sport}">Sport</span>
          </div>
          <div class="venue-card-footer">
            <div class="rating">
              <span class="stars">★</span>
              <span class="rating-num" th:text="${#numbers.formatDecimal(venue.avgRating, 1, 1)}">4.5</span>
            </div>
            <a th:href="@{/venues/{id}(id=${venue.venueId})}" class="btn btn-primary btn-sm">Book Now</a>
          </div>
        </div>
      </div>
    </div>

    <div th:if="${#lists.isEmpty(venues)}" style="text-align:center; padding:48px; color:var(--gray-400);">
      <p>No venues available yet. Check back soon!</p>
    </div>
  </div>
</section>

<!-- CTA -->
<section class="section" style="background: var(--gray-900); color:white; text-align:center;">
  <div class="container">
    <h2 style="color:white;">Own a Sports Venue?</h2>
    <p style="color:var(--gray-400); margin:12px 0 32px;">List your courts on SportX and reach thousands of players in your city.</p>
    <a th:href="@{/auth/register}" class="btn btn-primary btn-lg">Get Started Free</a>
  </div>
</section>

<footer>
  <p>© 2025 <span style="color:var(--accent);">SportX</span> — Sports Venue Booking System</p>
</footer>

</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venues.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Browse Venues — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/venues}" class="nav-link active">Browse Venues</a></li>
      <li sec:authorize="isAnonymous()"><a th:href="@{/auth/login}" class="btn btn-outline btn-sm">Login</a></li>
      <li sec:authorize="isAnonymous()"><a th:href="@{/auth/register}" class="btn btn-primary btn-sm">Sign Up</a></li>
      <li sec:authorize="isAuthenticated()"><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div class="page-header">
      <h1>Browse Venues</h1>
      <p>Explore verified sports venues and book your court.</p>
    </div>

    <!-- Search -->
    <div class="card mb-4">
      <div class="card-body">
        <form th:action="@{/venues}" method="get">
          <div class="grid-3" style="align-items:end;">
            <div class="form-group" style="margin-bottom:0;">
              <label class="form-label">City</label>
              <input type="text" name="city" class="form-control"
                     placeholder="e.g. Bangalore" th:value="${selectedCity}"/>
            </div>
            <div class="form-group" style="margin-bottom:0;">
              <label class="form-label">Sport</label>
              <select name="sport" class="form-control">
                <option value="">All Sports</option>
                <option th:each="s : ${sportTypes}" th:value="${s}" th:text="${s}"
                        th:selected="${s == selectedSport}">Sport</option>
              </select>
            </div>
            <button type="submit" class="btn btn-primary">Search</button>
          </div>
        </form>
      </div>
    </div>

    <div class="flex-between mb-3">
      <p><strong th:text="${#lists.size(venues)}">0</strong> venues found</p>
    </div>

    <div class="venues-grid">
      <div th:each="venue : ${venues}" class="venue-card">
        <img th:src="${venue.imageUrl}" th:alt="${venue.name}" class="venue-card-img"
             onerror="this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800'"/>
        <div class="venue-card-body">
          <div class="venue-card-name" th:text="${venue.name}">Name</div>
          <div class="venue-card-city">📍 <span th:text="${venue.address}">Address</span>, <span th:text="${venue.city}">City</span></div>
          <div class="venue-card-tags">
            <span th:each="sport : ${venue.sportTypes}" class="sport-tag" th:text="${sport}">Sport</span>
          </div>
          <div class="venue-card-footer">
            <div class="rating">
              <span class="stars">★</span>
              <span class="rating-num" th:text="${#numbers.formatDecimal(venue.avgRating,1,1)}">4.5</span>
            </div>
            <!-- Logged-in players go to booking flow; others go to login -->
            <a sec:authorize="hasRole('PLAYER')"
               th:href="@{/player/venue/{id}(id=${venue.venueId})}"
               class="btn btn-primary btn-sm">Book Now</a>
            <a sec:authorize="!hasRole('PLAYER')"
               th:href="@{/auth/login}"
               class="btn btn-outline btn-sm">Login to Book</a>
          </div>
        </div>
      </div>
    </div>

    <div th:if="${#lists.isEmpty(venues)}"
         style="text-align:center; padding:64px; color:var(--gray-400);">
      <p style="font-size:2rem;">🏟️</p>
      <h3 style="color:var(--gray-600); margin:12px 0 8px;">No venues found</h3>
      <p>Try a different city or sport.</p>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venue-detail.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title th:text="${venue.name + ' — SportX'}">Venue — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/venues}" class="nav-link">← All Venues</a></li>
      <li sec:authorize="isAnonymous()"><a th:href="@{/auth/login}" class="btn btn-primary btn-sm">Login to Book</a></li>
      <li sec:authorize="isAuthenticated()"><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div class="card mb-3" style="overflow:hidden;">
      <img th:src="${venue.imageUrl}" th:alt="${venue.name}"
           style="width:100%; height:300px; object-fit:cover;"
           onerror="this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800'"/>
      <div class="card-body">
        <div class="flex-between">
          <div>
            <h1 th:text="${venue.name}">Venue</h1>
            <p>📍 <span th:text="${venue.address}">Address</span>, <span th:text="${venue.city}">City</span></p>
            <div class="flex gap-1 mt-1">
              <span th:each="s : ${venue.sportTypes}" class="sport-tag" th:text="${s}">Sport</span>
            </div>
          </div>
          <div style="text-align:right;">
            <div class="rating" style="justify-content:flex-end;">
              <span class="stars">★</span>
              <span class="rating-num" th:text="${#numbers.formatDecimal(venue.avgRating,1,1)}">4.5</span>
            </div>
            <span class="badge badge-green mt-1" th:if="${venue.verified}">✓ Verified</span>
          </div>
        </div>
        <p class="mt-2" th:text="${venue.description}">Description</p>

        <!-- CTA for non-players -->
        <div sec:authorize="!hasRole('PLAYER')" style="margin-top:20px; padding:16px;
             background:var(--accent-pale); border-radius:var(--radius-sm);">
          <p style="color:var(--accent-dark); font-weight:600; margin-bottom:10px;">
            Sign up or log in to book a slot at this venue.
          </p>
          <div class="flex gap-2">
            <a th:href="@{/auth/register}" class="btn btn-primary btn-sm">Create Account</a>
            <a th:href="@{/auth/login}" class="btn btn-outline btn-sm">Login</a>
          </div>
        </div>

        <div sec:authorize="hasRole('PLAYER')" style="margin-top:20px;">
          <a th:href="@{/player/venue/{id}(id=${venue.venueId})}"
             class="btn btn-primary btn-lg">View Available Slots →</a>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/auth/login.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body>
<div class="auth-page">
  <div class="auth-card">
    <div class="auth-logo">
      <h2>⚡ Sport<span>X</span></h2>
      <p style="color:var(--gray-500); margin-top:6px; font-size:14px;">Welcome back! Sign in to continue.</p>
    </div>

    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <form th:action="@{/auth/login}" method="post">
      <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>

      <div class="form-group">
        <label class="form-label">Email Address</label>
        <input type="email" name="email" class="form-control" placeholder="you@example.com" required/>
      </div>
      <div class="form-group">
        <label class="form-label">Password</label>
        <input type="password" name="password" class="form-control" placeholder="••••••••" required/>
      </div>

      <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top:8px;">Sign In</button>
    </form>

    <div class="divider"></div>
    <p style="text-align:center; font-size:14px; color:var(--gray-600);">
      Don't have an account?
      <a th:href="@{/auth/register}" style="font-weight:600;">Create one free</a>
    </p>

    <!-- Demo credentials hint -->
    <div style="margin-top:20px; padding:14px; background:var(--gray-50); border-radius:var(--radius-sm); border:1px solid var(--gray-200);">
      <p style="font-size:12px; font-weight:700; color:var(--gray-600); margin-bottom:8px;">DEMO CREDENTIALS</p>
      <p style="font-size:12px; color:var(--gray-500); line-height:1.8;">
        🟢 Player: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="49392528302c3b093a39263b3d31672a2624">[email&#160;protected]</a> / player123<br/>
        🏟️ Owner: <a href="/cdn-c
SPORTX_EOF
cat > src/main/resources/templates/auth/register.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Register — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body>
<div class="auth-page">
  <div class="auth-card" style="max-width:520px;">
    <div class="auth-logo">
      <h2>⚡ Sport<span>X</span></h2>
      <p style="color:var(--gray-500); margin-top:6px; font-size:14px;">Create your free account</p>
    </div>

    <div th:if="${errorMsg}" class="alert alert-error" th:text="${errorMsg}"></div>

    <form th:action="@{/auth/register}" method="post" th:object="${registerDTO}">
      <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>

      <div class="grid-2">
        <div class="form-group">
          <label class="form-label">Full Name *</label>
          <input type="text" th:field="*{name}" class="form-control" placeholder="John Doe"/>
          <span th:if="${#fields.hasErrors('name')}" class="form-error" th:errors="*{name}"></span>
        </div>
        <div class="form-group">
          <label class="form-label">Phone Number</label>
          <input type="tel" th:field="*{phoneNumber}" class="form-control" placeholder="9876543210"/>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">Email Address *</label>
        <input type="email" th:field="*{email}" class="form-control" placeholder="you@example.com"/>
        <span th:if="${#fields.hasErrors('email')}" class="form-error" th:errors="*{email}"></span>
      </div>

      <div class="form-group">
        <label class="form-label">Password *</label>
        <input type="password" th:field="*{password}" class="form-control" placeholder="Min 6 characters"/>
        <span th:if="${#fields.hasErrors('password')}" class="form-error" th:errors="*{password}"></span>
      </div>

      <div class="form-group">
        <label class="form-label">Register As *</label>
        <select th:field="*{role}" class="form-control" id="roleSelect" onchange="toggleLicense()">
          <option th:each="r : ${roles}" th:value="${r}" th:text="${r}">Role</option>
        </select>
      </div>

      <div class="form-group" id="licenseGroup" style="display:none;">
        <label class="form-label">Business License</label>
        <input type="text" th:field="*{businessLicense}" class="form-control" placeholder="e.g. LIC-2024-SPORT"/>
        <span class="form-hint">Required for Venue Owner registration.</span>
      </div>

      <button type="submit" class="btn btn-primary btn-block btn-lg" style="margin-top:8px;">Create Account</button>
    </form>

    <div class="divider"></div>
    <p style="text-align:center; font-size:14px; color:var(--gray-600);">
      Already have an account? <a th:href="@{/auth/login}" style="font-weight:600;">Sign in</a>
    </p>
  </div>
</div>

<script>
  function toggleLicense() {
    const role = document.getElementById('roleSelect').value;
    document.getElementById('licenseGroup').style.display =
      role === 'VENUE_OWNER' ? 'block' : 'none';
  }
  toggleLicense();
</script>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/dashboard.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Player Dashboard — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/dashboard}" class="nav-link active">Dashboard</a></li>
      <li><a th:href="@{/player/search}" class="nav-link">Find Courts</a></li>
      <li><a th:href="@{/player/bookings}" class="nav-link">My Bookings</a></li>
      <li><a th:href="@{/player/notifications}" class="nav-link">
        Alerts <span th:if="${unreadCount > 0}" class="notif-badge" th:text="${unreadCount}">0</span>
      </a></li>
      <li><a th:href="@{/player/profile}" class="nav-link">Profile</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <div class="page-header">
      <h1>Welcome back, <span class="text-accent" th:text="${player.name}">Player</span> 👋</h1>
      <p>Ready to play? Find and book courts near you.</p>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-label">Total Bookings</div>
        <div class="stat-value text-accent" th:text="${totalBookings}">0</div>
        <div class="stat-sub">All time</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Notifications</div>
        <div class="stat-value" th:text="${unreadCount}">0</div>
        <div class="stat-sub">Unread alerts</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Player ID</div>
        <div class="stat-value" style="font-size:1rem;" th:text="${player.userId}">USR-XXX</div>
        <div class="stat-sub">Your unique ID</div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="card mb-3">
      <div class="card-body">
        <h3 class="mb-2">Quick Actions</h3>
        <div class="flex gap-2">
          <a th:href="@{/player/search}" class="btn btn-primary">🔍 Find Courts</a>
          <a th:href="@{/player/bookings}" class="btn btn-outline">📋 My Bookings</a>
          <a th:href="@{/player/profile}" class="btn btn-gray">👤 Edit Profile</a>
        </div>
      </div>
    </div>

    <!-- Recent Bookings -->
    <div class="card">
      <div class="card-body">
        <div class="flex-between mb-3">
          <h3>Recent Bookings</h3>
          <a th:href="@{/player/bookings}" class="btn btn-gray btn-sm">View All</a>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Venue</th>
                <th>Court</th>
                <th>Date &amp; Time</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="booking : ${bookings}">
                <td class="fw-semibold" th:text="${booking.bookingId}">BKG-XXX</td>
                <td th:text="${booking.slot.court.venue.name}">Venue</td>
                <td th:text="${booking.slot.court.courtName}">Court</td>
                <td th:text="${#temporals.format(booking.slot.startTime, 'dd MMM yyyy, HH:mm')}">-</td>
                <td class="fw-bold text-accent">₹<span th:text="${booking.totalAmount}">0</span></td>
                <td>
                  <span class="badge"
                        th:classappend="${booking.status.name() == 'CONFIRMED'} ? 'badge-green' :
                                        (${booking.status.name() == 'CANCELLED'} ? 'badge-red' : 'badge-yellow')"
                        th:text="${booking.status}">Status</span>
                </td>
                <td>
                  <form th:if="${booking.status.name() == 'CONFIRMED'}"
                        th:action="@{/player/cancel/{id}(id=${booking.bookingId})}"
                        method="post" style="display:inline;">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            onclick="return confirm('Cancel this booking?')">Cancel</button>
                  </form>
                </td>
              </tr>
              <tr th:if="${#lists.isEmpty(bookings)}">
                <td colspan="7" class="text-center text-muted" style="padding:32px;">
                  No bookings yet. <a th:href="@{/player/search}">Find a court →</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/search.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Find Courts — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/player/search}" class="nav-link active">Find Courts</a></li>
      <li><a th:href="@{/player/bookings}" class="nav-link">My Bookings</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div class="page-header">
      <h1>Find Courts</h1>
      <p>Search verified venues and book your slot instantly.</p>
    </div>

    <!-- Search Form -->
    <div class="card mb-4">
      <div class="card-body">
        <form th:action="@{/player/search}" method="get">
          <div class="grid-3" style="align-items:end;">
            <div class="form-group" style="margin-bottom:0;">
              <label class="form-label">City / Area</label>
              <input type="text" name="city" class="form-control"
                     placeholder="e.g. Bangalore"
                     th:value="${selectedCity}"/>
            </div>
            <div class="form-group" style="margin-bottom:0;">
              <label class="form-label">Sport</label>
              <select name="sport" class="form-control">
                <option value="">All Sports</option>
                <option th:each="s : ${sportTypes}"
                        th:value="${s}" th:text="${s}"
                        th:selected="${s == selectedSport}">Sport</option>
              </select>
            </div>
            <button type="submit" class="btn btn-primary">Search Venues</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Results -->
    <div class="flex-between mb-3">
      <h3><span th:text="${#lists.size(venues)}">0</span> Venues Found</h3>
    </div>

    <div class="venues-grid">
      <div th:each="venue : ${venues}" class="venue-card">
        <img th:src="${venue.imageUrl}" th:alt="${venue.name}" class="venue-card-img"
             onerror="this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800'"/>
        <div class="venue-card-body">
          <div class="venue-card-name" th:text="${venue.name}">Name</div>
          <div class="venue-card-city">📍 <span th:text="${venue.city}">City</span></div>
          <div class="venue-card-tags">
            <span th:each="sport : ${venue.sportTypes}" class="sport-tag" th:text="${sport}">Sport</span>
          </div>
          <div class="venue-card-footer">
            <div class="rating">
              <span class="stars">★</span>
              <span class="rating-num" th:text="${#numbers.formatDecimal(venue.avgRating, 1, 1)}">4.5</span>
            </div>
            <a th:href="@{/player/venue/{id}(id=${venue.venueId})}" class="btn btn-primary btn-sm">View Courts</a>
          </div>
        </div>
      </div>
    </div>

    <div th:if="${#lists.isEmpty(venues)}"
         style="text-align:center; padding:64px; color:var(--gray-400);">
      <p style="font-size:2rem; margin-bottom:12px;">🏟️</p>
      <h3 style="color:var(--gray-600); margin-bottom:8px;">No venues found</h3>
      <p>Try a different city or sport filter.</p>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/venue-detail.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title th:text="${venue.name + ' — SportX'}">Venue — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/search}" class="nav-link">← Back to Search</a></li>
      <li><a th:href="@{/player/bookings}" class="nav-link">My Bookings</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <!-- Venue Hero -->
    <div class="card mb-3" style="overflow:hidden;">
      <img th:src="${venue.imageUrl}" th:alt="${venue.name}"
           style="width:100%; height:280px; object-fit:cover;"
           onerror="this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800'"/>
      <div class="card-body">
        <div class="flex-between">
          <div>
            <h1 th:text="${venue.name}" style="margin-bottom:8px;">Venue Name</h1>
            <p>📍 <span th:text="${venue.address}">Address</span>, <span th:text="${venue.city}">City</span></p>
            <div style="margin-top:10px;" class="flex gap-1">
              <span th:each="sport : ${venue.sportTypes}" class="sport-tag" th:text="${sport}">Sport</span>
            </div>
          </div>
          <div style="text-align:right;">
            <div class="rating" style="justify-content:flex-end;">
              <span class="stars">★★★★★</span>
              <span class="rating-num" th:text="${#numbers.formatDecimal(venue.avgRating,1,1)}">4.5</span>
            </div>
            <span class="badge badge-green mt-1" th:if="${venue.verified}">✓ Verified</span>
          </div>
        </div>
        <p style="margin-top:14px;" th:text="${venue.description}">Description</p>
      </div>
    </div>

    <!-- Courts & Slots -->
    <h2 class="mb-3">Available Courts &amp; Slots</h2>
    <div th:each="court : ${courts}" class="card mb-3">
      <div class="card-body">
        <div class="flex-between mb-2">
          <div>
            <h3 th:text="${court.courtName}">Court Name</h3>
            <span class="sport-tag mt-1" th:text="${court.sport}">Sport</span>
          </div>
        </div>

        <div class="slots-grid" id="slotsFor" th:id="'slots-' + ${court.id}">
          <div th:each="slot : ${court.slots}"
               th:if="${slot.status.name() == 'AVAILABLE'}">
            <a th:href="@{/player/book/{id}(id=${slot.slotId})}"
               class="slot-btn" style="display:block; text-decoration:none; color:inherit;">
              <div class="slot-time" th:text="${#temporals.format(slot.startTime, 'HH:mm')} + ' – ' + ${#temporals.format(slot.endTime, 'HH:mm')}">09:00 – 10:00</div>
              <div class="slot-price" th:text="'₹' + ${slot.price}">₹400</div>
              <div style="font-size:11px; margin-top:4px; color:var(--gray-400);"
                   th:text="${#temporals.format(slot.startTime, 'dd MMM')}">01 Jan</div>
            </a>
          </div>
          <div th:if="${#lists.isEmpty(court.slots)}"
               style="color:var(--gray-400); font-size:14px; grid-column:1/-1; padding:16px;">
            No slots available for this court.
          </div>
        </div>
      </div>
    </div>

    <div th:if="${#lists.isEmpty(courts)}"
         style="text-align:center; padding:48px; color:var(--gray-400);">
      <p>No courts added yet for this venue.</p>
    </div>

    <!-- Reviews Section -->
    <div class="mt-4">
      <h2 class="mb-3">Reviews</h2>

      <!-- Write Review -->
      <div class="card mb-3" th:if="${!hasReviewed}">
        <div class="card-body">
          <h3 class="mb-2">Write a Review</h3>
          <form th:action="@{/player/review}" method="post" th:object="${reviewDTO}">
            <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
            <input type="hidden" name="venueId" th:value="${venue.venueId}"/>
            <div class="grid-2">
              <div class="form-group">
                <label class="form-label">Rating (1–5)</label>
                <select name="rating" class="form-control" required>
                  <option value="5">⭐⭐⭐⭐⭐ Excellent</option>
                  <option value="4">⭐⭐⭐⭐ Good</option>
                  <option value="3">⭐⭐⭐ Average</option>
                  <option value="2">⭐⭐ Below Average</option>
                  <option value="1">⭐ Poor</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Comment</label>
                <input type="text" name="comment" class="form-control" placeholder="Share your experience..."/>
              </div>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Submit Review</button>
          </form>
        </div>
      </div>

      <div th:if="${hasReviewed}" class="alert alert-info">You have already reviewed this venue.</div>

      <!-- Existing Reviews -->
      <div th:each="review : ${reviews}" class="review-card">
        <div class="review-header">
          <span class="reviewer-name" th:text="${review.player.name}">Player</span>
          <span class="stars">
            <span th:each="i : ${#numbers.sequence(1, review.rating)}">★</span>
          </span>
        </div>
        <p th:text="${review.comment}" style="font-size:14px; color:var(--gray-600);">Comment</p>
      </div>

      <div th:if="${#lists.isEmpty(reviews)}"
           style="color:var(--gray-400); font-size:14px; padding:20px 0;">
        No reviews yet. Be the first to review!
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/book-slot.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Book Slot — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/search}" class="nav-link">← Back</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container" style="max-width:540px;">
    <div class="page-header">
      <h1>Confirm Booking</h1>
      <p>Review and complete your slot booking.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div style="background:var(--accent-pale); border-radius:var(--radius-sm); padding:16px; margin-bottom:24px;">
          <p style="font-size:13px; color:var(--gray-500); margin-bottom:4px;">Slot ID</p>
          <p class="fw-bold" th:text="${slotId}">SLT-XXX</p>
        </div>

        <form th:action="@{/player/book}" method="post" th:object="${bookingDTO}">
          <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
          <input type="hidden" name="slotId" th:value="${slotId}"/>

          <div class="form-group">
            <label class="form-label">Payment Method</label>
            <select name="paymentMethod" class="form-control">
              <option value="CARD">💳 Credit / Debit Card</option>
              <option value="UPI">📱 UPI</option>
              <option value="WALLET">👛 Digital Wallet</option>
            </select>
          </div>

          <div style="background:var(--gray-50); border-radius:var(--radius-sm); padding:16px; margin-bottom:20px;">
            <p style="font-size:13px; color:var(--gray-500);">Note: This is a simulated payment. No real transaction will occur.</p>
          </div>

          <button type="submit" class="btn btn-primary btn-block btn-lg">Confirm &amp; Pay</button>
          <a th:href="@{/player/search}" class="btn btn-gray btn-block mt-1">Cancel</a>
        </form>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/bookings.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Bookings — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/player/search}" class="nav-link">Find Courts</a></li>
      <li><a th:href="@{/player/bookings}" class="nav-link active">My Bookings</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <div class="page-header">
      <h1>My Bookings</h1>
      <p>Complete history of all your court reservations.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Venue</th>
                <th>Court</th>
                <th>Sport</th>
                <th>Date &amp; Time</th>
                <th>Amount</th>
                <th>Payment</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="b : ${bookings}">
                <td class="fw-semibold" th:text="${b.bookingId}">BKG-XXX</td>
                <td th:text="${b.slot.court.venue.name}">Venue</td>
                <td th:text="${b.slot.court.courtName}">Court</td>
                <td>
                  <span class="sport-tag" style="font-size:11px;"
                        th:text="${b.slot.court.sport}">Sport</span>
                </td>
                <td>
                  <div th:text="${#temporals.format(b.slot.startTime,'dd MMM yyyy')}">Date</div>
                  <div style="font-size:12px; color:var(--gray-400);"
                       th:text="${#temporals.format(b.slot.startTime,'HH:mm')} + ' – ' + ${#temporals.format(b.slot.endTime,'HH:mm')}">Time</div>
                </td>
                <td class="fw-bold text-accent">₹<span th:text="${b.totalAmount}">0</span></td>
                <td>
                  <span th:if="${b.payment != null}" class="badge badge-green"
                        th:text="${b.payment.paymentMethod}">CARD</span>
                  <span th:if="${b.payment == null}" class="badge badge-gray">-</span>
                </td>
                <td>
                  <span class="badge"
                        th:classappend="${b.status.name() == 'CONFIRMED'} ? 'badge-green' :
                                        (${b.status.name() == 'CANCELLED'}  ? 'badge-red'   :
                                        (${b.status.name() == 'COMPLETED'}  ? 'badge-blue'  : 'badge-yellow'))"
                        th:text="${b.status}">Status</span>
                </td>
                <td>
                  <form th:if="${b.status.name() == 'CONFIRMED'}"
                        th:action="@{/player/cancel/{id}(id=${b.bookingId})}"
                        method="post" style="display:inline;">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            onclick="return confirm('Are you sure you want to cancel this booking?')">
                      Cancel
                    </button>
                  </form>
                  <span th:if="${b.status.name() != 'CONFIRMED'}"
                        style="color:var(--gray-300); font-size:13px;">—</span>
                </td>
              </tr>
              <tr th:if="${#lists.isEmpty(bookings)}">
                <td colspan="9" class="text-center" style="padding:48px; color:var(--gray-400);">
                  <p style="font-size:1.5rem; margin-bottom:8px;">📋</p>
                  <p>No bookings yet.</p>
                  <a th:href="@{/player/search}" class="btn btn-primary btn-sm mt-2">Find Courts</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/profile.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>My Profile — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/player/profile}" class="nav-link active">Profile</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container" style="max-width:600px;">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <div class="page-header">
      <h1>My Profile</h1>
      <p>Update your personal information.</p>
    </div>

    <!-- Profile Info Card -->
    <div class="card mb-3">
      <div class="card-body" style="display:flex; align-items:center; gap:20px;">
        <div style="width:72px; height:72px; border-radius:50%;
                    background:var(--accent-light); display:flex;
                    align-items:center; justify-content:center;
                    font-size:1.8rem; font-weight:800; color:var(--accent-dark);"
             th:text="${#strings.substring(player.name, 0, 1)}">A</div>
        <div>
          <h3 th:text="${player.name}">Player Name</h3>
          <p th:text="${player.email}" style="font-size:14px;">email</p>
          <span class="badge badge-green mt-1">Player</span>
        </div>
      </div>
    </div>

    <!-- Edit Form -->
    <div class="card">
      <div class="card-body">
        <h3 class="mb-3">Edit Profile</h3>
        <form th:action="@{/player/profile}" method="post">
          <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>

          <div class="form-group">
            <label class="form-label">Full Name</label>
            <input type="text" name="name" class="form-control"
                   th:value="${player.name}" required/>
          </div>
          <div class="form-group">
            <label class="form-label">Email Address</label>
            <input type="email" class="form-control" th:value="${player.email}" disabled
                   style="background:var(--gray-50); color:var(--gray-500);"/>
            <span class="form-hint">Email cannot be changed.</span>
          </div>
          <div class="form-group">
            <label class="form-label">Phone Number</label>
            <input type="tel" name="phoneNumber" class="form-control"
                   th:value="${player.phoneNumber}" placeholder="9876543210"/>
          </div>

          <button type="submit" class="btn btn-primary">Save Changes</button>
        </form>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/player/notifications.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Notifications — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/player/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/player/notifications}" class="nav-link active">Notifications</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container" style="max-width:720px;">
    <div class="page-header">
      <h1>Notifications</h1>
      <p>All your recent alerts and updates.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div th:each="n : ${notifications}"
             style="padding:16px 0; border-bottom:1px solid var(--gray-100);">
          <div class="flex-between">
            <div style="display:flex; gap:12px; align-items:flex-start;">
              <div style="font-size:1.4rem;">
                <span th:if="${n.type == 'BOOKING_CONFIRMED'}">✅</span>
                <span th:if="${n.type == 'BOOKING_CANCELLED'}">❌</span>
                <span th:if="${n.type == 'PAYMENT_SUCCESS'}">💳</span>
                <span th:if="${n.type == 'VENUE_VERIFIED'}">🏟️</span>
                <span th:unless="${n.type == 'BOOKING_CONFIRMED' or n.type == 'BOOKING_CANCELLED' or n.type == 'PAYMENT_SUCCESS' or n.type == 'VENUE_VERIFIED'}">🔔</span>
              </div>
              <div>
                <p style="color:var(--gray-800); font-weight:500; margin-bottom:4px;"
                   th:text="${n.message}">Notification message</p>
                <p style="font-size:12px; color:var(--gray-400);"
                   th:text="${#temporals.format(n.timestamp, 'dd MMM yyyy, HH:mm')}">Time</p>
              </div>
            </div>
            <span class="badge badge-green" style="font-size:11px;" th:text="${n.type}">TYPE</span>
          </div>
        </div>

        <div th:if="${#lists.isEmpty(notifications)}"
             style="text-align:center; padding:48px; color:var(--gray-400);">
          <p style="font-size:2rem; margin-bottom:8px;">🔔</p>
          <p>No notifications yet. Book a court to get started!</p>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venueowner/dashboard.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Owner Dashboard — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/owner/dashboard}" class="nav-link active">Dashboard</a></li>
      <li><a th:href="@{/owner/venue/add}" class="nav-link">Add Venue</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <div class="page-header">
      <h1>Venue Owner Dashboard</h1>
      <p>Manage your venues, courts, and bookings.</p>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-label">My Venues</div>
        <div class="stat-value text-accent" th:text="${#lists.size(venues)}">0</div>
        <div class="stat-sub">Total listed</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Bookings</div>
        <div class="stat-value" th:text="${totalBookings}">0</div>
        <div class="stat-sub">All venues combined</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Owner ID</div>
        <div class="stat-value" style="font-size:1rem;" th:text="${owner.userId}">USR-XXX</div>
        <div class="stat-sub" th:text="${owner.email}">email</div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="card mb-4">
      <div class="card-body">
        <h3 class="mb-2">Quick Actions</h3>
        <div class="flex gap-2">
          <a th:href="@{/owner/venue/add}" class="btn btn-primary">➕ Add New Venue</a>
        </div>
      </div>
    </div>

    <!-- My Venues -->
    <h2 class="mb-3">My Venues</h2>
    <div class="venues-grid">
      <div th:each="venue : ${venues}" class="venue-card">
        <img th:src="${venue.imageUrl}" th:alt="${venue.name}" class="venue-card-img"
             onerror="this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800'"/>
        <div class="venue-card-body">
          <div class="venue-card-name" th:text="${venue.name}">Name</div>
          <div class="venue-card-city">📍 <span th:text="${venue.city}">City</span></div>
          <div class="flex gap-1 mt-1">
            <span class="badge" th:classappend="${venue.verified} ? 'badge-green' : 'badge-yellow'"
                  th:text="${venue.verified} ? '✓ Verified' : '⏳ Pending'">Status</span>
          </div>

          <!-- Action Links -->
          <div class="flex gap-1 mt-2" style="flex-wrap:wrap;">
            <a th:href="@{/owner/venue/{id}/courts(id=${venue.venueId})}"
               class="btn btn-outline btn-sm">Courts</a>
            <a th:href="@{/owner/venue/{id}/bookings(id=${venue.venueId})}"
               class="btn btn-gray btn-sm">Bookings</a>
            <a th:href="@{/owner/venue/{id}/reports(id=${venue.venueId})}"
               class="btn btn-gray btn-sm">Reports</a>
          </div>
        </div>
      </div>
    </div>

    <div th:if="${#lists.isEmpty(venues)}"
         style="text-align:center; padding:64px; color:var(--gray-400);">
      <p style="font-size:2rem; margin-bottom:12px;">🏟️</p>
      <h3 style="color:var(--gray-600); margin-bottom:8px;">No venues yet</h3>
      <p>Add your first venue to start accepting bookings.</p>
      <a th:href="@{/owner/venue/add}" class="btn btn-primary mt-2">Add Venue</a>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venueowner/add-venue.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Add Venue — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/owner/dashboard}" class="nav-link">← Dashboard</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container" style="max-width:660px;">
    <div class="page-header">
      <h1>Add New Venue</h1>
      <p>Fill in the details and submit for admin verification.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <form th:action="@{/owner/venue/add}" method="post" th:object="${venueDTO}">
          <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>

          <div class="grid-2">
            <div class="form-group">
              <label class="form-label">Venue Name *</label>
              <input type="text" th:field="*{name}" class="form-control"
                     placeholder="e.g. Champions Badminton Academy"/>
              <span th:if="${#fields.hasErrors('name')}" class="form-error" th:errors="*{name}"></span>
            </div>
            <div class="form-group">
              <label class="form-label">City *</label>
              <input type="text" th:field="*{city}" class="form-control" placeholder="e.g. Bangalore"/>
              <span th:if="${#fields.hasErrors('city')}" class="form-error" th:errors="*{city}"></span>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">Full Address *</label>
            <input type="text" th:field="*{address}" class="form-control"
                   placeholder="e.g. 12 MG Road, Bangalore"/>
            <span th:if="${#fields.hasErrors('address')}" class="form-error" th:errors="*{address}"></span>
          </div>

          <div class="form-group">
            <label class="form-label">Description</label>
            <textarea th:field="*{description}" class="form-control" rows="3"
                      placeholder="Tell players what makes your venue great..."></textarea>
          </div>

          <div class="form-group">
            <label class="form-label">Cover Image URL</label>
            <input type="url" th:field="*{imageUrl}" class="form-control"
                   placeholder="https://... (Unsplash or any public image)"/>
            <span class="form-hint">Leave blank to use a default image.</span>
          </div>

          <div class="form-group">
            <label class="form-label">Sports Available *</label>
            <div style="display:flex; gap:12px; flex-wrap:wrap; margin-top:8px;">
              <label th:each="sport : ${sportTypes}"
                     style="display:flex; align-items:center; gap:6px; cursor:pointer;
                            padding:8px 14px; border-radius:var(--radius-sm);
                            border:1.5px solid var(--gray-200);
                            transition:all 0.15s ease;"
                     class="sport-checkbox-label">
                <input type="checkbox" name="sportTypes" th:value="${sport}"
                       style="accent-color:var(--accent);"/>
                <span th:text="${sport}">Sport</span>
              </label>
            </div>
          </div>

          <div style="display:flex; gap:12px; margin-top:8px;">
            <button type="submit" class="btn btn-primary">Submit for Verification</button>
            <a th:href="@{/owner/dashboard}" class="btn btn-gray">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venueowner/courts.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Courts — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/owner/dashboard}" class="nav-link">← Dashboard</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>

    <div class="page-header">
      <h1>Courts — <span class="text-accent" th:text="${venue.name}">Venue</span></h1>
      <p>Add and manage courts for this venue.</p>
    </div>

    <div class="grid-2" style="align-items:start;">
      <!-- Add Court Form -->
      <div class="card">
        <div class="card-body">
          <h3 class="mb-3">Add New Court</h3>
          <form th:action="@{/owner/venue/{id}/court/add(id=${venue.venueId})}" method="post">
            <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
            <div class="form-group">
              <label class="form-label">Court Name</label>
              <input type="text" name="courtName" class="form-control"
                     placeholder="e.g. Court A" required/>
            </div>
            <div class="form-group">
              <label class="form-label">Sport</label>
              <select name="sport" class="form-control">
                <option th:each="s : ${sportTypes}" th:value="${s}" th:text="${s}">Sport</option>
              </select>
            </div>
            <button type="submit" class="btn btn-primary">Add Court</button>
          </form>
        </div>
      </div>

      <!-- Existing Courts -->
      <div>
        <h3 class="mb-2">Existing Courts (<span th:text="${#lists.size(courts)}">0</span>)</h3>
        <div th:each="court : ${courts}" class="card mb-2">
          <div class="card-body">
            <div class="flex-between">
              <div>
                <h4 th:text="${court.courtName}">Court Name</h4>
                <span class="sport-tag mt-1" th:text="${court.sport}">Sport</span>
                <p style="font-size:12px; color:var(--gray-400); margin-top:6px;"
                   th:text="${court.courtId}">CRT-XXX</p>
              </div>
              <a th:href="@{/owner/court/{id}/slots(id=${court.id})}"
                 class="btn btn-outline btn-sm">Manage Slots</a>
            </div>
          </div>
        </div>

        <div th:if="${#lists.isEmpty(courts)}"
             style="text-align:center; padding:32px; color:var(--gray-400);">
          <p>No courts yet. Add your first court.</p>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venueowner/slots.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Slots — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/owner/dashboard}" class="nav-link">← Dashboard</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>
    <div th:if="${errorMsg}"   class="alert alert-error"   th:text="${errorMsg}"></div>

    <div class="page-header">
      <h1>Manage Slots</h1>
      <p>Add time slots and set pricing for this court.</p>
    </div>

    <div class="grid-2" style="align-items:start;">
      <!-- Add Slot Form -->
      <div class="card">
        <div class="card-body">
          <h3 class="mb-3">Add New Slot</h3>
          <form th:action="@{/owner/slot/add}" method="post">
            <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
            <input type="hidden" name="courtId" th:value="${courtId}"/>

            <div class="form-group">
              <label class="form-label">Start Date &amp; Time</label>
              <input type="datetime-local" name="startTime" class="form-control" required/>
            </div>
            <div class="form-group">
              <label class="form-label">End Date &amp; Time</label>
              <input type="datetime-local" name="endTime" class="form-control" required/>
            </div>
            <div class="form-group">
              <label class="form-label">Price (₹)</label>
              <input type="number" name="price" class="form-control"
                     placeholder="400" min="0" step="50" required/>
            </div>
            <button type="submit" class="btn btn-primary">Create Slot</button>
          </form>
        </div>
      </div>

      <!-- Existing Slots -->
      <div>
        <h3 class="mb-2">Slots (<span th:text="${#lists.size(slots)}">0</span>)</h3>
        <div class="card">
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Slot ID</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Price</th>
                  <th>Status</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <tr th:each="slot : ${slots}">
                  <td style="font-size:12px; color:var(--gray-400);" th:text="${slot.slotId}">SLT-XXX</td>
                  <td th:text="${#temporals.format(slot.startTime,'dd MMM yyyy')}">Date</td>
                  <td th:text="${#temporals.format(slot.startTime,'HH:mm')} + ' – ' + ${#temporals.format(slot.endTime,'HH:mm')}">Time</td>
                  <td class="fw-bold text-accent">₹<span th:text="${slot.price}">0</span></td>
                  <td>
                    <span class="badge"
                          th:classappend="${slot.status.name() == 'AVAILABLE'} ? 'badge-green' :
                                          (${slot.status.name() == 'BOOKED'} ? 'badge-blue' : 'badge-red')"
                          th:text="${slot.status}">Status</span>
                  </td>
                  <td>
                    <form th:if="${slot.status.name() == 'AVAILABLE'}"
                          th:action="@{/owner/slot/block/{id}(id=${slot.slotId})}"
                          method="post" style="display:inline;">
                      <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                      <input type="hidden" name="courtId" th:value="${courtId}"/>
                      <button type="submit" class="btn btn-danger btn-sm">Block</button>
                    </form>
                    <span th:unless="${slot.status.name() == 'AVAILABLE'}"
                          style="color:var(--gray-300); font-size:13px;">—</span>
                  </td>
                </tr>
                <tr th:if="${#lists.isEmpty(slots)}">
                  <td colspan="6" class="text-center" style="padding:32px; color:var(--gray-400);">
                    No slots yet. Add your first slot.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venueowner/bookings.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Bookings — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/owner/dashboard}" class="nav-link">← Dashboard</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div class="page-header">
      <h1>Bookings — <span class="text-accent" th:text="${venue.name}">Venue</span></h1>
      <p>All bookings received for this venue.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Player</th>
                <th>Court</th>
                <th>Date &amp; Time</th>
                <th>Amount</th>
                <th>Payment</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="b : ${bookings}">
                <td class="fw-semibold" th:text="${b.bookingId}">BKG-XXX</td>
                <td>
                  <div th:text="${b.player.name}">Player</div>
                  <div style="font-size:12px; color:var(--gray-400);"
                       th:text="${b.player.phoneNumber}">Phone</div>
                </td>
                <td th:text="${b.slot.court.courtName}">Court</td>
                <td>
                  <div th:text="${#temporals.format(b.slot.startTime,'dd MMM yyyy')}">Date</div>
                  <div style="font-size:12px; color:var(--gray-400);"
                       th:text="${#temporals.format(b.slot.startTime,'HH:mm')} + ' – ' + ${#temporals.format(b.slot.endTime,'HH:mm')}">Time</div>
                </td>
                <td class="fw-bold text-accent">₹<span th:text="${b.totalAmount}">0</span></td>
                <td>
                  <span th:if="${b.payment != null}" class="badge badge-green"
                        th:text="${b.payment.paymentMethod}">CARD</span>
                </td>
                <td>
                  <span class="badge"
                        th:classappend="${b.status.name() == 'CONFIRMED'} ? 'badge-green' :
                                        (${b.status.name() == 'CANCELLED'} ? 'badge-red' : 'badge-yellow')"
                        th:text="${b.status}">Status</span>
                </td>
              </tr>
              <tr th:if="${#lists.isEmpty(bookings)}">
                <td colspan="7" class="text-center" style="padding:48px; color:var(--gray-400);">
                  No bookings yet for this venue.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/venueowner/reports.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Booking Reports — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/owner/dashboard}" class="nav-link">← Dashboard</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div class="page-header">
      <h1>Reports — <span class="text-accent" th:text="${venue.name}">Venue</span></h1>
      <p>Revenue and booking analytics for this venue.</p>
    </div>

    <!-- Summary Stats -->
    <div class="stats-grid mb-4">
      <div class="stat-card">
        <div class="stat-label">Total Revenue</div>
        <div class="stat-value text-accent">₹<span th:text="${#numbers.formatDecimal(totalRevenue, 0, 'COMMA', 0, 'POINT')}">0</span></div>
        <div class="stat-sub">Confirmed bookings only</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Bookings</div>
        <div class="stat-value" th:text="${totalBookings}">0</div>
        <div class="stat-sub">All time</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Avg. Rating</div>
        <div class="stat-value">
          <span th:text="${#numbers.formatDecimal(venue.avgRating, 1, 1)}">0.0</span>
          <span style="font-size:1rem; color:var(--warning);">★</span>
        </div>
        <div class="stat-sub">Based on reviews</div>
      </div>
    </div>

    <!-- Booking Breakdown by Status -->
    <div class="grid-2 mb-4">
      <div class="card">
        <div class="card-body">
          <h3 class="mb-2">Booking Status Breakdown</h3>
          <div th:with="confirmed=${#lists.size(bookings.?[status.name() == 'CONFIRMED'])},
                        cancelled=${#lists.size(bookings.?[status.name() == 'CANCELLED'])},
                        pending=${#lists.size(bookings.?[status.name() == 'PENDING'])}">
            <div style="display:flex; justify-content:space-between; padding:10px 0; border-bottom:1px solid var(--gray-100);">
              <span class="badge badge-green">CONFIRMED</span>
              <strong th:text="${confirmed}">0</strong>
            </div>
            <div style="display:flex; justify-content:space-between; padding:10px 0; border-bottom:1px solid var(--gray-100);">
              <span class="badge badge-yellow">PENDING</span>
              <strong th:text="${pending}">0</strong>
            </div>
            <div style="display:flex; justify-content:space-between; padding:10px 0;">
              <span class="badge badge-red">CANCELLED</span>
              <strong th:text="${cancelled}">0</strong>
            </div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-body">
          <h3 class="mb-2">Venue Info</h3>
          <div style="font-size:14px; line-height:2.2; color:var(--gray-600);">
            <div>📍 <span th:text="${venue.address}">Address</span>, <span th:text="${venue.city}">City</span></div>
            <div>🏟️ Venue ID: <strong th:text="${venue.venueId}">VEN-XXX</strong></div>
            <div>
              ✅ Status:
              <span class="badge" th:classappend="${venue.verified} ? 'badge-green' : 'badge-yellow'"
                    th:text="${venue.verified} ? 'Verified' : 'Pending'">Status</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- All Bookings Table -->
    <div class="card">
      <div class="card-body">
        <h3 class="mb-3">All Bookings</h3>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Player</th>
                <th>Court</th>
                <th>Date</th>
                <th>Amount</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="b : ${bookings}">
                <td class="fw-semibold" th:text="${b.bookingId}">BKG-XXX</td>
                <td th:text="${b.player.name}">Player</td>
                <td th:text="${b.slot.court.courtName}">Court</td>
                <td th:text="${#temporals.format(b.slot.startTime,'dd MMM yyyy, HH:mm')}">Date</td>
                <td class="fw-bold text-accent">₹<span th:text="${b.totalAmount}">0</span></td>
                <td>
                  <span class="badge"
                        th:classappend="${b.status.name() == 'CONFIRMED'} ? 'badge-green' :
                                        (${b.status.name() == 'CANCELLED'} ? 'badge-red' : 'badge-yellow')"
                        th:text="${b.status}">Status</span>
                </td>
              </tr>
              <tr th:if="${#lists.isEmpty(bookings)}">
                <td colspan="6" class="text-center" style="padding:32px; color:var(--gray-400);">
                  No bookings yet.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/admin/dashboard.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Admin Dashboard — SportX</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/admin/dashboard}" class="nav-link active">Dashboard</a></li>
      <li><a th:href="@{/admin/venues}" class="nav-link">Venues</a></li>
      <li><a th:href="@{/admin/users}" class="nav-link">Users</a></li>
      <li><a th:href="@{/admin/bookings}" class="nav-link">Bookings</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>

    <div class="page-header">
      <h1>Admin Dashboard</h1>
      <p>System overview and management controls.</p>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-label">Total Venues</div>
        <div class="stat-value text-accent" th:text="${totalVenues}">0</div>
        <div class="stat-sub">All venues</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Pending Verification</div>
        <div class="stat-value" style="color:var(--warning);" th:text="${pendingVenues}">0</div>
        <div class="stat-sub">Awaiting review</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Users</div>
        <div class="stat-value" th:text="${totalUsers}">0</div>
        <div class="stat-sub">Players + Owners + Admins</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Total Bookings</div>
        <div class="stat-value" th:text="${totalBookings}">0</div>
        <div class="stat-sub">Platform-wide</div>
      </div>
    </div>

    <!-- Pending Venues Alert -->
    <div th:if="${pendingVenues > 0}" class="alert alert-info">
      ⚠️ There are <strong th:text="${pendingVenues}">0</strong> venue(s) pending verification.
      <a th:href="@{/admin/venues}" style="font-weight:700;">Review now →</a>
    </div>

    <!-- Recent Venues Table -->
    <div class="card mt-3">
      <div class="card-body">
        <div class="flex-between mb-3">
          <h3>All Venues</h3>
          <a th:href="@{/admin/venues}" class="btn btn-outline btn-sm">Manage All</a>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Venue</th>
                <th>City</th>
                <th>Owner</th>
                <th>Status</th>
                <th>Rating</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="v : ${venues}">
                <td>
                  <div class="fw-semibold" th:text="${v.name}">Venue</div>
                  <div style="font-size:11px; color:var(--gray-400);" th:text="${v.venueId}">VEN-XXX</div>
                </td>
                <td th:text="${v.city}">City</td>
                <td th:text="${v.owner.name}">Owner</td>
                <td>
                  <span class="badge" th:classappend="${v.verified} ? 'badge-green' : 'badge-yellow'"
                        th:text="${v.verified} ? 'Verified' : 'Pending'">Status</span>
                </td>
                <td th:text="${#numbers.formatDecimal(v.avgRating,1,1)} + ' ★'">4.5 ★</td>
                <td>
                  <form th:if="${!v.verified}"
                        th:action="@{/admin/venue/verify/{id}(id=${v.venueId})}"
                        method="post" style="display:inline;">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-primary btn-sm">Verify</button>
                  </form>
                  <form th:action="@{/admin/venue/delete/{id}(id=${v.id})}"
                        method="post" style="display:inline;">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            onclick="return confirm('Delete this venue?')">Delete</button>
                  </form>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/admin/venues.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Venues — SportX Admin</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/admin/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/admin/venues}" class="nav-link active">Venues</a></li>
      <li><a th:href="@{/admin/users}" class="nav-link">Users</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>

    <div class="page-header">
      <h1>Venue Management</h1>
      <p>Verify and manage all listed venues.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Venue</th>
                <th>City</th>
                <th>Sports</th>
                <th>Owner</th>
                <th>Rating</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="v : ${venues}">
                <td>
                  <div class="fw-semibold" th:text="${v.name}">Venue</div>
                  <div style="font-size:11px; color:var(--gray-400);" th:text="${v.venueId}">ID</div>
                </td>
                <td th:text="${v.city}">City</td>
                <td>
                  <div style="display:flex; gap:4px; flex-wrap:wrap;">
                    <span th:each="s : ${v.sportTypes}" class="sport-tag"
                          style="font-size:10px;" th:text="${s}">Sport</span>
                  </div>
                </td>
                <td>
                  <div th:text="${v.owner.name}">Owner</div>
                  <div style="font-size:12px; color:var(--gray-400);"
                       th:text="${v.owner.email}">email</div>
                </td>
                <td th:text="${#numbers.formatDecimal(v.avgRating,1,1)} + ' ★'">4.5 ★</td>
                <td>
                  <span class="badge" th:classappend="${v.verified} ? 'badge-green' : 'badge-yellow'"
                        th:text="${v.verified} ? 'Verified' : 'Pending'">Status</span>
                </td>
                <td style="white-space:nowrap;">
                  <form th:if="${!v.verified}"
                        th:action="@{/admin/venue/verify/{id}(id=${v.venueId})}"
                        method="post" style="display:inline;">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-primary btn-sm">✓ Verify</button>
                  </form>
                  <form th:action="@{/admin/venue/delete/{id}(id=${v.id})}"
                        method="post" style="display:inline; margin-left:4px;">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            onclick="return confirm('Permanently delete this venue?')">Delete</button>
                  </form>
                </td>
              </tr>
              <tr th:if="${#lists.isEmpty(venues)}">
                <td colspan="7" class="text-center" style="padding:32px; color:var(--gray-400);">
                  No venues found.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/admin/users.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Users — SportX Admin</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/admin/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/admin/venues}" class="nav-link">Venues</a></li>
      <li><a th:href="@{/admin/users}" class="nav-link active">Users</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div th:if="${successMsg}" class="alert alert-success" th:text="${successMsg}"></div>

    <div class="page-header">
      <h1>User Management</h1>
      <p>View and manage all registered users.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>User ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Role</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="u : ${users}">
                <td style="font-size:12px; color:var(--gray-400);" th:text="${u.userId}">USR-XXX</td>
                <td class="fw-semibold" th:text="${u.name}">Name</td>
                <td th:text="${u.email}">email</td>
                <td th:text="${u.phoneNumber != null ? u.phoneNumber : '—'}">Phone</td>
                <td>
                  <span class="badge"
                        th:classappend="${u.role.name() == 'ADMIN'} ? 'badge-blue' :
                                        (${u.role.name() == 'VENUE_OWNER'} ? 'badge-yellow' : 'badge-green')"
                        th:text="${u.role}">Role</span>
                </td>
                <td>
                  <form th:action="@{/admin/user/delete/{id}(id=${u.id})}"
                        method="post" style="display:inline;"
                        th:if="${u.role.name() != 'ADMIN'}">
                    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
                    <button type="submit" class="btn btn-danger btn-sm"
                            onclick="return confirm('Delete this user?')">Delete</button>
                  </form>
                  <span th:if="${u.role.name() == 'ADMIN'}"
                        style="color:var(--gray-300); font-size:13px;">Protected</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
cat > src/main/resources/templates/admin/bookings.html << 'SPORTX_EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>All Bookings — SportX Admin</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" th:href="@{/css/style.css}"/>
</head>
<body class="page-wrapper">
<nav class="navbar">
  <div class="container navbar-inner">
    <a th:href="@{/}" class="navbar-brand">⚡ Sport<span>X</span></a>
    <ul class="navbar-nav">
      <li><a th:href="@{/admin/dashboard}" class="nav-link">Dashboard</a></li>
      <li><a th:href="@{/admin/bookings}" class="nav-link active">Bookings</a></li>
      <li><a th:href="@{/auth/logout}" class="btn btn-gray btn-sm">Logout</a></li>
    </ul>
  </div>
</nav>

<main>
  <div class="container">
    <div class="page-header">
      <h1>All Bookings</h1>
      <p>Platform-wide booking history.</p>
    </div>

    <div class="card">
      <div class="card-body">
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Booking ID</th>
                <th>Player</th>
                <th>Venue</th>
                <th>Court</th>
                <th>Sport</th>
                <th>Date &amp; Time</th>
                <th>Amount</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr th:each="b : ${bookings}">
                <td class="fw-semibold" th:text="${b.bookingId}">BKG-XXX</td>
                <td th:text="${b.player.name}">Player</td>
                <td th:text="${b.slot.court.venue.name}">Venue</td>
                <td th:text="${b.slot.court.courtName}">Court</td>
                <td>
                  <span class="sport-tag" style="font-size:11px;"
                        th:text="${b.slot.court.sport}">Sport</span>
                </td>
                <td>
                  <div th:text="${#temporals.format(b.slot.startTime,'dd MMM yyyy')}">Date</div>
                  <div style="font-size:12px; color:var(--gray-400);"
                       th:text="${#temporals.format(b.slot.startTime,'HH:mm')} + ' – ' + ${#temporals.format(b.slot.endTime,'HH:mm')}">Time</div>
                </td>
                <td class="fw-bold text-accent">₹<span th:text="${b.totalAmount}">0</span></td>
                <td>
                  <span class="badge"
                        th:classappend="${b.status.name() == 'CONFIRMED'} ? 'badge-green' :
                                        (${b.status.name() == 'CANCELLED'} ? 'badge-red' : 'badge-yellow')"
                        th:text="${b.status}">Status</span>
                </td>
              </tr>
              <tr th:if="${#lists.isEmpty(bookings)}">
                <td colspan="8" class="text-center" style="padding:48px; color:var(--gray-400);">
                  No bookings found.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</main>

<footer><p>© 2025 <span style="color:var(--accent);">SportX</span></p></footer>
</body>
</html>

SPORTX_EOF
echo "✅ All templates and CSS written"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 SportX setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Run:  ./mvnw spring-boot:run"
echo "  2. Open: http://localhost:8080"
echo ""
echo "Demo logins:"
echo "  player@sportx.com  / player123"
echo "  owner@sportx.com   / owner123"
echo "  admin@sportx.com   / admin123"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"