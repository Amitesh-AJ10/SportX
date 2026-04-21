# SportX — Complete Class Diagram Context

**Project:** SportX — Sports Venue Booking System  
**Stack:** Java 17, Spring Boot 3, Spring MVC, Spring Security, Spring Data JPA, Thymeleaf, H2 (dev) / MySQL (prod), Lombok  
**Base Package:** `com.sportx`  
**Architecture:** Layered MVC — Controller → Service → Repository → Entity  
**Design Patterns Applied:** Factory Method, Strategy, Observer, Template Method, Facade, Proxy, Singleton, Adapter  
**Design Principles:** SOLID (SRP, OCP, LSP, ISP, DIP)

---

## 1. ENUMERATIONS

### 1.1 `UserRole` — `com.sportx.model.enums`
```
enum UserRole {
  PLAYER
  VENUE_OWNER
  ADMIN
}
```

### 1.2 `BookingStatus` — `com.sportx.model.enums`
```
enum BookingStatus {
  PENDING
  CONFIRMED
  CANCELLED
  COMPLETED
}
```

### 1.3 `SlotStatus` — `com.sportx.model.enums`
```
enum SlotStatus {
  AVAILABLE
  BOOKED
  BLOCKED
}
```

### 1.4 `SportType` — `com.sportx.model.enums`
```
enum SportType {
  BADMINTON
  FOOTBALL
  CRICKET
  TENNIS
  SWIMMING
}
```

---

## 2. ENTITY / DOMAIN MODEL CLASSES

### 2.1 `User` (Abstract) — `com.sportx.model`
**Stereotype:** Abstract Entity  
**JPA:** `@Entity`, `@Table(name="users")`, `@Inheritance(SINGLE_TABLE)`, `@DiscriminatorColumn(name="role")`  

| Visibility | Field | Type | JPA / Constraints |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | userId | String | `@Column(unique=true, nullable=false)` |
| - | name | String | `@NotBlank` |
| - | email | String | `@Email @Column(unique=true, nullable=false)` |
| - | phoneNumber | String | — |
| - | password | String | `@Column(nullable=false)` |
| - | role | UserRole | `@Enumerated(STRING) @Column(insertable=false, updatable=false)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | getDashboardUrl() | String | **abstract** — Template Method Pattern |
| + | login() | void | Delegated to Spring Security |
| + | updateProfile(name: String, phoneNumber: String) | void | Sets name + phone |

---

### 2.2 `Player` — `com.sportx.model`
**Stereotype:** Concrete Entity  
**Extends:** `User`  
**JPA:** `@Entity`, `@DiscriminatorValue("PLAYER")`  

| Visibility | Field | Type | JPA |
|---|---|---|---|
| - | bookings | List\<Booking\> | `@OneToMany(mappedBy="player", CascadeType.ALL, LAZY)` |
| - | reviews | List\<Review\> | `@OneToMany(mappedBy="player", CascadeType.ALL, LAZY)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | getDashboardUrl() | String | returns `"/player/dashboard"` |

**Relationships:**
- **Inheritance:** extends `User`
- **1..* (owns)** → `Booking` (one Player has many Bookings)
- **1..* (owns)** → `Review` (one Player has many Reviews)

---

### 2.3 `VenueOwner` — `com.sportx.model`
**Stereotype:** Concrete Entity  
**Extends:** `User`  
**JPA:** `@Entity`, `@DiscriminatorValue("VENUE_OWNER")`  

| Visibility | Field | Type | JPA |
|---|---|---|---|
| - | businessLicense | String | — |
| - | venues | List\<Venue\> | `@OneToMany(mappedBy="owner", CascadeType.ALL, LAZY)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | getDashboardUrl() | String | returns `"/owner/dashboard"` |
| + | addVenue(venue: Venue) | void | Sets back-reference and adds to list |

**Relationships:**
- **Inheritance:** extends `User`
- **1..* (owns)** → `Venue` (one VenueOwner has many Venues)

---

### 2.4 `Admin` — `com.sportx.model`
**Stereotype:** Concrete Entity  
**Extends:** `User`  
**JPA:** `@Entity`, `@DiscriminatorValue("ADMIN")`  

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | getDashboardUrl() | String | returns `"/admin/dashboard"` |
| + | verifyVenue(venueId: String) | void | Delegated to AdminService |
| + | manageUsers(userId: String) | void | Delegated to AdminService |

**Relationships:**
- **Inheritance:** extends `User`

---

### 2.5 `Venue` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="venues")`  

| Visibility | Field | Type | JPA / Default |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | venueId | String | `@Column(unique=true)` |
| - | name | String | `@Column(nullable=false)` |
| - | address | String | — |
| - | city | String | — |
| - | imageUrl | String | — |
| - | description | String | — |
| - | avgRating | double | default: `0.0` |
| - | isVerified | boolean | default: `false` |
| - | sportTypes | List\<SportType\> | `@ElementCollection @Enumerated(STRING)` → `venue_sports` join table |
| - | owner | VenueOwner | `@ManyToOne(LAZY) @JoinColumn(owner_id)` |
| - | courts | List\<Court\> | `@OneToMany(mappedBy="venue", CascadeType.ALL, LAZY)` |
| - | reviews | List\<Review\> | `@OneToMany(mappedBy="venue", CascadeType.ALL, LAZY)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | getDetails() | String | Returns formatted venue summary string |
| + | updateAvgRating() | void | Recalculates avgRating from reviews list |

**Relationships:**
- **N:1** → `VenueOwner` (many Venues belong to one VenueOwner)
- **1..*** → `Court` (one Venue has many Courts)
- **1..*** → `Review` (one Venue has many Reviews)
- **element collection** → `SportType[]` stored in `venue_sports` table

---

### 2.6 `Court` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="courts")`  

| Visibility | Field | Type | JPA |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | courtId | String | — |
| - | courtName | String | `@Column(nullable=false)` |
| - | sport | SportType | `@Enumerated(STRING)` |
| - | venue | Venue | `@ManyToOne(LAZY) @JoinColumn(venue_id)` |
| - | slots | List\<Slot\> | `@OneToMany(mappedBy="court", CascadeType.ALL, LAZY)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | getAvailableSlots(date: LocalDate) | List\<Slot\> | Filters slots by date and AVAILABLE status |

**Relationships:**
- **N:1** → `Venue` (many Courts belong to one Venue)
- **1..*** → `Slot` (one Court has many Slots)

---

### 2.7 `Slot` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="slots")`  

| Visibility | Field | Type | JPA / Default |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | slotId | String | — |
| - | startTime | LocalDateTime | `@Column(nullable=false)` |
| - | endTime | LocalDateTime | `@Column(nullable=false)` |
| - | price | double | — |
| - | status | SlotStatus | `@Enumerated(STRING)` default: `AVAILABLE` |
| - | court | Court | `@ManyToOne(LAZY) @JoinColumn(court_id)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | isAvailable() | boolean | Returns true if status == AVAILABLE |

**Relationships:**
- **N:1** → `Court` (many Slots belong to one Court)
- **1:1 (referenced by)** ← `Booking` (one Slot can be booked once)

---

### 2.8 `Booking` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="bookings")`  
**Pattern:** Observer trigger point  

| Visibility | Field | Type | JPA / Default |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | bookingId | String | `@Column(unique=true, nullable=false)` |
| - | bookingTime | LocalDateTime | — |
| - | totalAmount | double | — |
| - | status | BookingStatus | `@Enumerated(STRING)` default: `PENDING` |
| - | player | Player | `@ManyToOne(LAZY) @JoinColumn(player_id)` |
| - | slot | Slot | `@ManyToOne(LAZY) @JoinColumn(slot_id)` |
| - | payment | Payment | `@OneToOne(mappedBy="booking", CascadeType.ALL)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | confirmBooking() | void | Sets status to CONFIRMED |
| + | cancelBooking() | void | Sets status to CANCELLED |

**Relationships:**
- **N:1** → `Player` (many Bookings belong to one Player)
- **N:1** → `Slot` (many Bookings reference a Slot; logically 1:1 since slot becomes BOOKED)
- **1:1** ↔ `Payment` (one Booking has one Payment)

---

### 2.9 `Payment` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="payments")`  
**Pattern:** Strategy Pattern consumer  

| Visibility | Field | Type | JPA / Notes |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | transactionId | String | generated as `"TXN-" + timestamp` |
| - | amount | double | — |
| - | status | String | Values: `"SUCCESS"`, `"FAILED"`, `"REFUNDED"` |
| - | paymentMethod | String | Values: `"CARD"`, `"UPI"`, `"WALLET"` |
| - | booking | Booking | `@OneToOne(LAZY) @JoinColumn(booking_id)` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | processPayment() | String | Sets status=SUCCESS; returns transactionId |
| + | initiateRefund() | void | Sets status=REFUNDED |

**Relationships:**
- **1:1** → `Booking` (one Payment linked to one Booking, owner side)

---

### 2.10 `Review` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="reviews")`  

| Visibility | Field | Type | JPA / Constraints |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | reviewId | String | — |
| - | rating | int | `@Min(1) @Max(5)` |
| - | comment | String | `@Column(length=1000)` |
| - | player | Player | `@ManyToOne(LAZY) @JoinColumn(player_id)` |
| - | venue | Venue | `@ManyToOne(LAZY) @JoinColumn(venue_id)` |

**Relationships:**
- **N:1** → `Player` (many Reviews written by one Player)
- **N:1** → `Venue` (many Reviews belong to one Venue)

---

### 2.11 `Notification` — `com.sportx.model`
**Stereotype:** Entity  
**JPA:** `@Entity`, `@Table(name="notifications")`  
**Pattern:** Observer pattern — created by `NotificationService`  

| Visibility | Field | Type | JPA / Default |
|---|---|---|---|
| - | id | Long | `@Id @GeneratedValue(IDENTITY)` |
| - | message | String | `@Column(length=500)` |
| - | timestamp | LocalDateTime | — |
| - | userId | String | references `User.userId` (not FK, store by value) |
| - | isRead | boolean | default: `false` |
| - | type | String | Values: `"BOOKING_CONFIRMED"`, `"BOOKING_CANCELLED"`, `"PAYMENT_SUCCESS"`, `"VENUE_VERIFIED"` |

| Visibility | Method | Return | Notes |
|---|---|---|---|
| + | sendNotification(userId: String) | void | Sets userId, timestamp, prints to console |

---

## 3. DATA TRANSFER OBJECTS (DTOs)

### 3.1 `RegisterDTO` — `com.sportx.dto`
| Field | Type | Constraints |
|---|---|---|
| name | String | `@NotBlank` |
| email | String | `@Email @NotBlank` |
| password | String | `@NotBlank @Size(min=6)` |
| phoneNumber | String | — |
| role | UserRole | default: `PLAYER` |
| businessLicense | String | VenueOwner only |

**Used by:** `AuthController.register()` → `UserService.register()` → `UserFactory.createUser()`

---

### 3.2 `BookingDTO` — `com.sportx.dto`
| Field | Type | Notes |
|---|---|---|
| slotId | String | target Slot.slotId |
| paymentMethod | String | `"CARD"`, `"UPI"`, or `"WALLET"` |

**Used by:** `PlayerController.confirmBooking()` → `BookingService.bookSlot()`

---

### 3.3 `ReviewDTO` — `com.sportx.dto`
| Field | Type | Constraints |
|---|---|---|
| venueId | String | target Venue.venueId |
| rating | int | `@Min(1) @Max(5)` |
| comment | String | — |

**Used by:** `PlayerController.submitReview()` → `ReviewService.addReview()`

---

### 3.4 `VenueDTO` — `com.sportx.dto`
| Field | Type | Constraints |
|---|---|---|
| name | String | `@NotBlank` |
| address | String | `@NotBlank` |
| city | String | `@NotBlank` |
| description | String | — |
| imageUrl | String | — |
| sportTypes | List\<SportType\> | — |

**Used by:** `VenueOwnerController.addVenue()` → `VenueService.createVenue()`

---

### 3.5 `SlotDTO` — `com.sportx.dto`
| Field | Type | Notes |
|---|---|---|
| courtId | Long | target Court.id |
| startTime | LocalDateTime | — |
| endTime | LocalDateTime | — |
| price | double | — |

**Used by:** `VenueOwnerController.addSlot()` → `SlotService.createSlot()`

---

## 4. REPOSITORY INTERFACES (Spring Data JPA)

All repositories extend `JpaRepository<T, Long>` and are annotated `@Repository`.

### 4.1 `UserRepository` — `com.sportx.repository`
**Manages:** `User`  
| Method | Return | Notes |
|---|---|---|
| findByEmail(email: String) | Optional\<User\> | — |
| findByUserId(userId: String) | Optional\<User\> | — |
| existsByEmail(email: String) | boolean | uniqueness check |
| + inherited JPA | findAll(), findById(), save(), deleteById() | — |

---

### 4.2 `VenueRepository` — `com.sportx.repository`
**Manages:** `Venue`  
| Method | Return | Notes |
|---|---|---|
| findByVenueId(venueId: String) | Optional\<Venue\> | — |
| findByIsVerifiedTrue() | List\<Venue\> | public listing |
| findByCityContainingIgnoreCaseAndIsVerifiedTrue(city: String) | List\<Venue\> | — |
| findByOwner_Id(ownerId: Long) | List\<Venue\> | owner's venues |
| findBySportType(sport: SportType) | List\<Venue\> | `@Query` JPQL |
| searchVenues(city: String, sport: SportType) | List\<Venue\> | `@Query` JPQL with null-safe params |

---

### 4.3 `CourtRepository` — `com.sportx.repository`
**Manages:** `Court`  
| Method | Return | Notes |
|---|---|---|
| findByVenue_Id(venueId: Long) | List\<Court\> | — |
| findByVenue_IdAndSport(venueId: Long, sport: SportType) | List\<Court\> | — |

---

### 4.4 `SlotRepository` — `com.sportx.repository`
**Manages:** `Slot`  
| Method | Return | Notes |
|---|---|---|
| findBySlotId(slotId: String) | Optional\<Slot\> | — |
| findByCourt_Id(courtId: Long) | List\<Slot\> | — |
| findByCourt_IdAndStatus(courtId: Long, status: SlotStatus) | List\<Slot\> | availability filter |
| findByCourtAndDate(courtId: Long, from: LocalDateTime, to: LocalDateTime) | List\<Slot\> | `@Query` JPQL |

---

### 4.5 `BookingRepository` — `com.sportx.repository`
**Manages:** `Booking`  
| Method | Return | Notes |
|---|---|---|
| findByBookingId(bookingId: String) | Optional\<Booking\> | — |
| findByPlayer_IdOrderByBookingTimeDesc(playerId: Long) | List\<Booking\> | player history |
| findBySlot_Court_Venue_IdOrderByBookingTimeDesc(venueId: Long) | List\<Booking\> | venue bookings |
| findByStatus(status: BookingStatus) | List\<Booking\> | status filter |
| countBySlot_Court_Venue_Id(venueId: Long) | long | total bookings for venue |

---

### 4.6 `PaymentRepository` — `com.sportx.repository`
**Manages:** `Payment`  
| Method | Return | Notes |
|---|---|---|
| findByTransactionId(transactionId: String) | Optional\<Payment\> | — |
| findByBooking_Id(bookingId: Long) | Optional\<Payment\> | — |

---

### 4.7 `ReviewRepository` — `com.sportx.repository`
**Manages:** `Review`  
| Method | Return | Notes |
|---|---|---|
| findByVenue_Id(venueId: Long) | List\<Review\> | — |
| findByPlayer_Id(playerId: Long) | List\<Review\> | — |
| existsByPlayer_IdAndVenue_Id(playerId: Long, venueId: Long) | boolean | duplicate check |

---

### 4.8 `NotificationRepository` — `com.sportx.repository`
**Manages:** `Notification`  
| Method | Return | Notes |
|---|---|---|
| findByUserIdOrderByTimestampDesc(userId: String) | List\<Notification\> | inbox |
| findByUserIdAndIsReadFalse(userId: String) | List\<Notification\> | unread only |
| countByUserIdAndIsReadFalse(userId: String) | long | badge count |

---

## 5. SERVICE LAYER

### 5.1 `UserService` — `com.sportx.service`
**Stereotype:** `@Service @Transactional`  
**Pattern:** Facade (hides JPA complexity), DIP (depends on interface)  
**Dependencies (Autowired):** `UserRepository`, `PasswordEncoder`, `UserFactory`

| Method | Return | Notes |
|---|---|---|
| register(dto: RegisterDTO) | User | checks duplicate email, delegates to UserFactory, saves |
| findByEmail(email: String) | Optional\<User\> | — |
| findByUserId(userId: String) | Optional\<User\> | — |
| findAll() | List\<User\> | for admin panel |
| updateProfile(email: String, name: String, phone: String) | User | calls user.updateProfile() |
| deleteUser(id: Long) | void | — |

---

### 5.2 `VenueService` — `com.sportx.service`
**Stereotype:** `@Service @Transactional`  
**Pattern:** Facade  
**Dependencies (Autowired):** `VenueRepository`, `CourtRepository`, `SlotRepository`

| Method | Return | Notes |
|---|---|---|
| searchVenues(city: String, sport: SportType) | List\<Venue\> | null-safe search |
| getAllVerified() | List\<Venue\> | public listing |
| getAllForAdmin() | List\<Venue\> | includes unverified |
| findByVenueId(venueId: String) | Optional\<Venue\> | — |
| findById(id: Long) | Optional\<Venue\> | — |
| findByOwner(ownerId: Long) | List\<Venue\> | — |
| createVenue(dto: VenueDTO, owner: VenueOwner) | Venue | generates UUID venueId |
| verifyVenue(venueId: String) | Venue | sets isVerified=true |
| addCourt(venueId: Long, courtName: String, sport: SportType) | Court | creates and saves Court |
| getCourtsForVenue(venueId: Long) | List\<Court\> | — |
| getSlotsForCourt(courtId: Long) | List\<Slot\> | — |
| deleteVenue(id: Long) | void | — |

---

### 5.3 `BookingService` — `com.sportx.service`
**Stereotype:** `@Service @Transactional`  
**Pattern:** Facade (hides multi-step booking flow), Observer trigger  
**Dependencies (Autowired):** `BookingRepository`, `SlotRepository`, `PaymentRepository`, `NotificationService`, `PaymentContext`

| Method | Return | Notes |
|---|---|---|
| bookSlot(player: Player, slotId: String, paymentMethod: String) | Booking | Full booking flow: validate → create Booking → process Payment (via PaymentContext/Strategy) → confirm → notify (Observer) |
| cancelBooking(bookingId: String, currentUserEmail: String) | Booking | Validates ownership → cancels → refunds → frees Slot → notifies |
| getPlayerBookings(playerId: Long) | List\<Booking\> | History ordered by time desc |
| getVenueBookings(venueId: Long) | List\<Booking\> | — |
| findByBookingId(bookingId: String) | Optional\<Booking\> | — |
| getAllBookings() | List\<Booking\> | Admin use |
| countVenueBookings(venueId: Long) | long | Dashboard stats |

---

### 5.4 `SlotService` — `com.sportx.service`
**Stereotype:** `@Service @Transactional`  
**Dependencies (Autowired):** `SlotRepository`, `CourtRepository`

| Method | Return | Notes |
|---|---|---|
| createSlot(dto: SlotDTO) | Slot | Generates slotId UUID |
| getSlotsByCourtAndDate(courtId: Long, date: LocalDate) | List\<Slot\> | Date-range query |
| getAvailableSlots(courtId: Long) | List\<Slot\> | Status = AVAILABLE |
| blockSlot(slotId: String) | void | Sets status to BLOCKED |
| deleteSlot(id: Long) | void | — |

---

### 5.5 `ReviewService` — `com.sportx.service`
**Stereotype:** `@Service @Transactional`  
**Dependencies (Autowired):** `ReviewRepository`, `VenueRepository`

| Method | Return | Notes |
|---|---|---|
| addReview(player: Player, dto: ReviewDTO) | Review | Checks duplicate → saves → updates Venue.avgRating |
| getVenueReviews(venueId: Long) | List\<Review\> | — |
| getPlayerReviews(playerId: Long) | List\<Review\> | — |
| hasReviewed(playerId: Long, venueId: Long) | boolean | — |

---

### 5.6 `NotificationService` — `com.sportx.service`
**Stereotype:** `@Service @Transactional`  
**Pattern:** **Observer** (concrete observer reacting to Booking events)  
**Dependencies (Autowired):** `NotificationRepository`

| Method | Return | Notes |
|---|---|---|
| notifyBookingConfirmed(booking: Booking) | void | Creates and saves BOOKING_CONFIRMED Notification |
| notifyBookingCancelled(booking: Booking) | void | Creates and saves BOOKING_CANCELLED Notification |
| notifyPaymentSuccess(booking: Booking) | void | Creates and saves PAYMENT_SUCCESS Notification |
| notifyVenueVerified(ownerUserId: String, venueName: String) | void | Creates and saves VENUE_VERIFIED Notification |
| getNotificationsForUser(userId: String) | List\<Notification\> | Inbox query |
| getUnreadCount(userId: String) | long | Badge count |
| markAllRead(userId: String) | void | Marks all unread → read |
| buildNotification(userId: String, type: String, message: String) | Notification | private factory helper |

---

### 5.7 `UserDetailsServiceImpl` — `com.sportx.service`
**Stereotype:** `@Service`  
**Implements:** `UserDetailsService` (Spring Security interface)  
**Pattern:** **Adapter** — adapts `User` entity to Spring Security's `UserDetails`  
**Dependencies (Autowired):** `UserRepository`

| Method | Return | Notes |
|---|---|---|
| loadUserByUsername(email: String) | UserDetails | Loads User by email; maps role → `"ROLE_"` prefix; throws `UsernameNotFoundException` |

---

## 6. CONFIG / CREATIONAL & STRATEGY CLASSES

### 6.1 `PaymentStrategy` (Interface) — `com.sportx.config`
**Pattern:** **Strategy** (behavioral) — defines the payment algorithm family  

| Method | Return |
|---|---|
| pay(amount: double) | String (transactionId) |
| getMethodName() | String |

---

### 6.2 `CardPaymentStrategy` — `com.sportx.config`
**Implements:** `PaymentStrategy`  
**Spring bean:** `@Component("cardPayment")`  

| Method | Return | Notes |
|---|---|---|
| pay(amount: double) | String | Returns `"CARD-TXN-" + timestamp` |
| getMethodName() | String | Returns `"CARD"` |

---

### 6.3 `UpiPaymentStrategy` — `com.sportx.config`
**Implements:** `PaymentStrategy`  
**Spring bean:** `@Component("upiPayment")`  

| Method | Return | Notes |
|---|---|---|
| pay(amount: double) | String | Returns `"UPI-TXN-" + timestamp` |
| getMethodName() | String | Returns `"UPI"` |

---

### 6.4 `WalletPaymentStrategy` — `com.sportx.config`
**Implements:** `PaymentStrategy`  
**Spring bean:** `@Component("walletPayment")`  

| Method | Return | Notes |
|---|---|---|
| pay(amount: double) | String | Returns `"WALLET-TXN-" + timestamp` |
| getMethodName() | String | Returns `"WALLET"` |

---

### 6.5 `PaymentContext` — `com.sportx.config`
**Stereotype:** `@Component`  
**Pattern:** **Strategy Context** — selects the correct `PaymentStrategy` at runtime  
**Principle:** OCP — new payment methods without touching existing code  

| Field | Type | Notes |
|---|---|---|
| - strategies | Map\<String, PaymentStrategy\> | Spring-injected map of all strategy beans |

| Method | Return | Notes |
|---|---|---|
| executePayment(method: String, amount: double) | String | Switch on method ("UPI", "WALLET", default "CARD") → delegates to strategy.pay() |

**Relationships:**
- **uses** → `PaymentStrategy` (interface)
- **holds** → `CardPaymentStrategy`, `UpiPaymentStrategy`, `WalletPaymentStrategy` (via map)

---

### 6.6 `UserFactory` — `com.sportx.config`
**Stereotype:** `@Component`  
**Pattern:** **Factory Method** (creational) — centralises `User` subtype creation  
**Principle:** Controllers/Services never call `new Player()` directly  

| Method | Return | Notes |
|---|---|---|
| createUser(dto: RegisterDTO, encodedPassword: String) | User | Switches on `dto.getRole()` → calls private builder |
| - buildPlayer(dto, encodedPassword) | Player | private |
| - buildVenueOwner(dto, encodedPassword) | VenueOwner | sets businessLicense |
| - buildAdmin(dto, encodedPassword) | Admin | private |
| - populate(user, dto, encodedPassword) | void | sets userId (UUID), name, email, phone, password on any User subtype |

**Relationships:**
- **creates** → `Player`, `VenueOwner`, `Admin`
- **depends on** → `RegisterDTO`

---

### 6.7 `SecurityConfig` — `com.sportx.config`
**Stereotype:** `@Configuration @EnableWebSecurity`  
**Pattern:** **Proxy** (Spring Security wraps all controller access)  

| Bean/Method | Return | Notes |
|---|---|---|
| passwordEncoder() | PasswordEncoder | `BCryptPasswordEncoder` |
| authenticationManager(config: AuthenticationConfiguration) | AuthenticationManager | — |
| filterChain(http: HttpSecurity) | SecurityFilterChain | Configures URL authorization, form login, logout |

**Authorization Rules:**
- `/`, `/auth/**`, `/venues`, `/venues/search`, `/venues/{id}`, `/css/**`, `/js/**`, `/h2-console/**` → `permitAll`
- `/player/**` → `hasRole("PLAYER")`
- `/owner/**` → `hasRole("VENUE_OWNER")`
- `/admin/**` → `hasRole("ADMIN")`

**Post-login redirect:** role-based → `/admin/dashboard`, `/owner/dashboard`, `/player/dashboard`

---

### 6.8 `DataInitializer` — `com.sportx.config`
**Stereotype:** `@Component implements CommandLineRunner`  
**Purpose:** Seeds demo data on startup  

| Method | Notes |
|---|---|
| run(args: String...) | Calls seedUsers() and seedVenues() |
| seedUsers() | Creates Admin, VenueOwner, Player via UserService |
| seedVenues() | Creates 4 Venues (Badminton, Football, Tennis, Cricket) with Courts and Slots |
| addCourtsAndSlots(venue, courtName, sport, price) | Creates 1 Court + 48 Slots (4 days × 12 hours) |

**Dependencies (Autowired):** `UserService`, `VenueRepository`, `CourtRepository`, `SlotRepository`, `UserRepository`

---

## 7. CONTROLLER LAYER

### 7.1 `AuthController` — `com.sportx.controller`
**Stereotype:** `@Controller @RequestMapping("/auth")`  
**Dependencies (Autowired):** `UserService`

| HTTP | Endpoint | Method | Notes |
|---|---|---|---|
| GET | /auth/login | loginPage() | Renders login form with optional error/logout params |
| GET | /auth/register | registerPage() | Model includes `RegisterDTO`, `UserRole[]` |
| POST | /auth/register | register() | Validates RegisterDTO → UserService.register() → redirect /auth/login |

---

### 7.2 `HomeController` — `com.sportx.controller`
**Stereotype:** `@Controller`  
**Dependencies (Autowired):** `VenueService`

| HTTP | Endpoint | Method | Notes |
|---|---|---|---|
| GET | / | home() | Shows 6 featured verified venues |
| GET | /venues | venues() | Search by city + sport (public) |
| GET | /venues/{venueId} | venueDetail() | Public venue detail page |

---

### 7.3 `PlayerController` — `com.sportx.controller`
**Stereotype:** `@Controller @RequestMapping("/player")` (requires ROLE_PLAYER)  
**Dependencies (Autowired):** `UserService`, `VenueService`, `BookingService`, `SlotService`, `ReviewService`, `NotificationService`

| HTTP | Endpoint | Method | Notes |
|---|---|---|---|
| GET | /player/dashboard | dashboard() | Shows recent 5 bookings + unread count |
| GET | /player/search | searchVenues() | Venue search by city + sport |
| GET | /player/venue/{venueId} | viewVenue() | Venue detail + courts + reviews + hasReviewed |
| GET | /player/book/{slotId} | bookSlotPage() | Book-slot form |
| POST | /player/book | confirmBooking() | Calls BookingService.bookSlot() |
| GET | /player/bookings | bookingHistory() | All player bookings |
| POST | /player/cancel/{bookingId} | cancelBooking() | Calls BookingService.cancelBooking() |
| POST | /player/review | submitReview() | Calls ReviewService.addReview() |
| GET | /player/profile | profile() | Shows player profile |
| POST | /player/profile | updateProfile() | Calls UserService.updateProfile() |
| GET | /player/notifications | notifications() | Marks all read, shows notification list |
| GET | /player/slots/{courtId} | viewSlots() | Available slots for court |

---

### 7.4 `VenueOwnerController` — `com.sportx.controller`
**Stereotype:** `@Controller @RequestMapping("/owner")` (requires ROLE_VENUE_OWNER)  
**Dependencies (Autowired):** `UserService`, `VenueService`, `BookingService`, `SlotService`

| HTTP | Endpoint | Method | Notes |
|---|---|---|---|
| GET | /owner/dashboard | dashboard() | Shows venues list + total booking count |
| GET | /owner/venue/add | addVenuePage() | VenueDTO form + SportType enum |
| POST | /owner/venue/add | addVenue() | Calls VenueService.createVenue() |
| GET | /owner/venue/{venueId}/courts | manageCourts() | Lists courts for venue |
| POST | /owner/venue/{venueId}/court/add | addCourt() | Calls VenueService.addCourt() |
| GET | /owner/court/{courtId}/slots | manageSlots() | Lists available slots + SlotDTO |
| POST | /owner/slot/add | addSlot() | Calls SlotService.createSlot() |
| POST | /owner/slot/block/{slotId} | blockSlot() | Calls SlotService.blockSlot() |
| GET | /owner/venue/{venueId}/bookings | manageBookings() | All bookings for venue |
| GET | /owner/venue/{venueId}/reports | viewReports() | Revenue report (CONFIRMED+COMPLETED) |

---

### 7.5 `AdminController` — `com.sportx.controller`
**Stereotype:** `@Controller @RequestMapping("/admin")` (requires ROLE_ADMIN)  
**Dependencies (Autowired):** `UserService`, `VenueService`, `BookingService`, `NotificationService`

| HTTP | Endpoint | Method | Notes |
|---|---|---|---|
| GET | /admin/dashboard | dashboard() | Stats: total venues, pending, users, bookings |
| GET | /admin/venues | manageVenues() | All venues incl. unverified |
| POST | /admin/venue/verify/{venueId} | verifyVenue() | Calls VenueService.verifyVenue() + notifyVenueVerified() |
| POST | /admin/venue/delete/{id} | deleteVenue() | Calls VenueService.deleteVenue() |
| GET | /admin/users | manageUsers() | All users list |
| POST | /admin/user/delete/{id} | deleteUser() | Calls UserService.deleteUser() |
| GET | /admin/bookings | allBookings() | All bookings system-wide |

---

## 8. ENTRY POINT

### 8.1 `SportxApplication` — `com.sportx`
**Stereotype:** `@SpringBootApplication`  

| Method | Notes |
|---|---|
| main(args: String[]) | Bootstraps Spring Boot application |

---

## 9. COMPLETE RELATIONSHIP SUMMARY

### 9.1 Inheritance (Generalization)

```
User (abstract)
  ├── Player
  ├── VenueOwner
  └── Admin
```

- All use `SINGLE_TABLE` JPA inheritance with discriminator column `role`

### 9.2 Interface Realizations

```
PaymentStrategy (interface)
  ├── CardPaymentStrategy  (implements)
  ├── UpiPaymentStrategy   (implements)
  └── WalletPaymentStrategy (implements)

UserDetailsService (Spring Security interface)
  └── UserDetailsServiceImpl (implements)
```

### 9.3 Entity Associations (with multiplicity and direction)

| From | Relationship | To | Notes |
|---|---|---|---|
| VenueOwner | 1 → * | Venue | One owner has many venues; FK: `owner_id` in `venues` |
| Venue | 1 → * | Court | One venue has many courts; FK: `venue_id` in `courts` |
| Court | 1 → * | Slot | One court has many slots; FK: `court_id` in `slots` |
| Player | 1 → * | Booking | One player has many bookings; FK: `player_id` in `bookings` |
| Slot | 1 → * | Booking | One slot referenced by bookings; FK: `slot_id` in `bookings` |
| Booking | 1 ↔ 1 | Payment | One-to-one bidirectional; FK: `booking_id` in `payments` |
| Player | 1 → * | Review | One player writes many reviews; FK: `player_id` in `reviews` |
| Venue | 1 → * | Review | One venue has many reviews; FK: `venue_id` in `reviews` |
| Venue | 1 → * | SportType (element) | Collection stored in `venue_sports` join table |

### 9.4 Service Dependencies (Dependency / Uses)

| Controller/Service | Uses (Autowires) |
|---|---|
| AuthController | UserService |
| HomeController | VenueService |
| PlayerController | UserService, VenueService, BookingService, SlotService, ReviewService, NotificationService |
| VenueOwnerController | UserService, VenueService, BookingService, SlotService |
| AdminController | UserService, VenueService, BookingService, NotificationService |
| UserService | UserRepository, PasswordEncoder, UserFactory |
| VenueService | VenueRepository, CourtRepository, SlotRepository |
| BookingService | BookingRepository, SlotRepository, PaymentRepository, NotificationService, PaymentContext |
| SlotService | SlotRepository, CourtRepository |
| ReviewService | ReviewRepository, VenueRepository |
| NotificationService | NotificationRepository |
| UserDetailsServiceImpl | UserRepository |
| UserFactory | — (creates Player, VenueOwner, Admin) |
| PaymentContext | Map\<String, PaymentStrategy\> (CardPaymentStrategy, UpiPaymentStrategy, WalletPaymentStrategy) |
| DataInitializer | UserService, VenueRepository, CourtRepository, SlotRepository, UserRepository |
| SecurityConfig | UserDetailsServiceImpl |

### 9.5 Repository → Entity Managed

| Repository | Entity |
|---|---|
| UserRepository | User |
| VenueRepository | Venue |
| CourtRepository | Court |
| SlotRepository | Slot |
| BookingRepository | Booking |
| PaymentRepository | Payment |
| ReviewRepository | Review |
| NotificationRepository | Notification |

---

## 10. DESIGN PATTERNS & PRINCIPLES REFERENCE

| Pattern | Category | Where Applied |
|---|---|---|
| **Factory Method** | Creational | `UserFactory.createUser()` → creates Player / VenueOwner / Admin |
| **Singleton** | Creational | All `@Service`, `@Component`, `@Repository` Spring beans are singletons by default |
| **Strategy** | Behavioral | `PaymentStrategy` interface + `CardPaymentStrategy`, `UpiPaymentStrategy`, `WalletPaymentStrategy`; `PaymentContext` as context |
| **Observer** | Behavioral | `BookingService` (subject/trigger) → `NotificationService` (observer/listener) on booking/cancellation events |
| **Template Method** | Behavioral | `User.getDashboardUrl()` declared abstract; overridden in `Player`, `VenueOwner`, `Admin` |
| **Facade** | Structural | `BookingService` hides multi-step booking from controllers; `UserService` and `VenueService` hide JPA complexity |
| **Proxy** | Structural | Spring Security `SecurityFilterChain` wraps all controller access with auth/authz |
| **Adapter** | Structural | `UserDetailsServiceImpl` adapts `User` (domain entity) to Spring Security's `UserDetails` interface |

| Principle | Where Applied |
|---|---|
| **SRP** | Each Service class has exactly one responsibility (booking, notification, venue, etc.) |
| **OCP** | New payment methods added by implementing `PaymentStrategy`; no existing code changes |
| **LSP** | `Player`, `VenueOwner`, `Admin` are substitutable for `User` everywhere |
| **ISP** | `PaymentStrategy` only exposes `pay()` and `getMethodName()`; no fat interface |
| **DIP** | Services depend on Repository interfaces, not JPA implementations; controllers depend on Service abstractions |

---

## 11. DATABASE SCHEMA SUMMARY

| Table | JPA Entity | Key Columns |
|---|---|---|
| `users` | User / Player / VenueOwner / Admin | `id`, `user_id`, `name`, `email`, `phone_number`, `password`, `role` (discriminator), `business_license` |
| `venues` | Venue | `id`, `venue_id`, `name`, `address`, `city`, `image_url`, `description`, `avg_rating`, `is_verified`, `owner_id` (FK→users) |
| `venue_sports` | Venue.sportTypes | `venue_id` (FK→venues), `sport_type` |
| `courts` | Court | `id`, `court_id`, `court_name`, `sport`, `venue_id` (FK→venues) |
| `slots` | Slot | `id`, `slot_id`, `start_time`, `end_time`, `price`, `status`, `court_id` (FK→courts) |
| `bookings` | Booking | `id`, `booking_id`, `booking_time`, `total_amount`, `status`, `player_id` (FK→users), `slot_id` (FK→slots) |
| `payments` | Payment | `id`, `transaction_id`, `amount`, `status`, `payment_method`, `booking_id` (FK→bookings) |
| `reviews` | Review | `id`, `review_id`, `rating`, `comment`, `player_id` (FK→users), `venue_id` (FK→venues) |
| `notifications` | Notification | `id`, `message`, `timestamp`, `user_id` (value, not FK), `is_read`, `type` |

---

## 12. TECHNOLOGY & ANNOTATION CHEATSHEET

| Annotation | Source | Purpose |
|---|---|---|
| `@SpringBootApplication` | Spring Boot | Auto-config entry point |
| `@Entity` | JPA | Maps class to DB table |
| `@Table(name=...)` | JPA | Explicit table name |
| `@Inheritance(SINGLE_TABLE)` | JPA | All User subtypes in one `users` table |
| `@DiscriminatorColumn` / `@DiscriminatorValue` | JPA | `role` column for type discrimination |
| `@Id @GeneratedValue(IDENTITY)` | JPA | Auto-increment PK |
| `@ManyToOne / @OneToMany / @OneToOne` | JPA | Relationship mapping |
| `@JoinColumn(name=...)` | JPA | FK column definition |
| `@ElementCollection / @CollectionTable` | JPA | `sportTypes` join table |
| `@Enumerated(STRING)` | JPA | Store enum as string |
| `@Column(unique, nullable, length)` | JPA | Column constraints |
| `@NotBlank / @Email / @Min / @Max / @Size` | Jakarta Validation | Bean validation |
| `@Getter / @Setter / @NoArgsConstructor` | Lombok | Boilerplate elimination |
| `@Service / @Repository / @Controller / @Component` | Spring | Component scan stereotypes |
| `@Transactional` | Spring | Transaction boundaries on service methods |
| `@Autowired` | Spring | Dependency injection |
| `@RequestMapping / @GetMapping / @PostMapping` | Spring MVC | URL routing |
| `@PathVariable / @RequestParam / @ModelAttribute` | Spring MVC | Request parameter binding |
| `@AuthenticationPrincipal` | Spring Security | Inject logged-in `UserDetails` |
| `@Valid` | Jakarta Validation | Triggers bean validation on method params |
| `@Configuration / @EnableWebSecurity / @Bean` | Spring Security | Security configuration |
| `@Query / @Param` | Spring Data JPA | Custom JPQL queries in repositories |
