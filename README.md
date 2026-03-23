# SportX — Sports Venue Booking System

A web application to discover and book sports courts (Badminton, Football, Tennis, Cricket, Swimming).

Built with **Spring Boot MVC + Thymeleaf + H2 Database**.

---

## How to Run

### Prerequisites
- Java 17 — [Download](https://adoptium.net/)
- Maven (comes bundled via `./mvnw`)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/sportx.git
cd sportx

# 2. Run the app
./mvnw spring-boot:run

# 3. Open in browser
http://localhost:8080
```

---

## Demo Logins

| Role | Email | Password |
|------|-------|----------|
| Player | player@sportx.com | player123 |
| Venue Owner | owner@sportx.com | owner123 |
| Admin | admin@sportx.com | admin123 |

---

## Tech Stack

- **Backend** — Spring Boot 3.5, Spring MVC, Spring Security, Spring Data JPA
- **Frontend** — Thymeleaf, HTML/CSS
- **Database** — H2 (in-memory, resets on restart)

---

## Project Structure

```
src/main/java/com/sportx/
├── config/        # Security, Factory, Payment Strategy
├── controller/    # MVC Controllers
├── model/         # JPA Entities + Enums
├── repository/    # Spring Data Repositories
├── service/       # Business Logic
└── dto/           # Data Transfer Objects

src/main/resources/
├── templates/     # Thymeleaf HTML pages
├── static/css/    # Stylesheet
└── application.properties
```
