# SportX Functonality Verification Guide

This document provides a checklist and instructions for verifying the core functionality of the SportX application.

## Authentication and User Management

- [ ] User Registration
    - **Step:** Navigate to `/register`. Fill in the form for different roles (Player, Venue Owner).
    - **Check:** Ensure you are redirected to the login page upon success. Attempt to register with an existing email to check for error handling.
- [ ] User Login
    - **Step:** Navigate to `/login`. Use the pre-seeded credentials or newly created ones.
    - **Check:** Confirm you are redirected to the correct dashboard (Player, Owner, or Admin) based on your role.
- [ ] User Logout
    - **Step:** Click the "Logout" button in the navigation bar.
    - **Check:** Confirm you are redirected to the home/login page and cannot access protected routes like `/player/dashboard`.

## Player Functionality

- [ ] Search Venues
    - **Step:** On the Home or Player Dashboard, use the search bar to filter by City (e.g., "Bangalore") or Sport (e.g., "Football").
    - **Check:** Ensure the displayed venues match the search criteria.
- [ ] Venue Detail View
    - **Step:** Click on "View Details" for any venue card.
    - **Check:** Verify that venue description, amenities, ratings, and available courts are displayed correctly.
- [ ] Slot Booking
    - **Step:** Select a date and an "Available" slot for a court. Click "Book Now".
    - **Check:** Ensure the booking is confirmed and the slot status changes from "Available" to "Booked" for that specific time.
- [ ] My Bookings
    - **Step:** Navigate to the "My Bookings" section in the Player Dashboard.
    - **Check:** Verify that your recent booking appears in the list with the status "Confirmed".
- [ ] Notifications
    - **Step:** Check the "Notifications" icon or page after making a booking.
    - **Check:** Confirm a notification exists for the booking confirmation.

## Venue Owner Functionality

- [ ] Add Venue
    - **Step:** Navigate to the Owner Dashboard -> "Add Venue". Enter venue details.
    - **Check:** verify the venue appears in your list (it may status as "Pending" or "Verified" depending on system defaults).
- [ ] Manage Courts and Slots
    - **Step:** Select a venue -> "Manage Courts". Add a new court and generate slots for it.
    - **Check:** Verify these slots appear as "Available" for players.
- [ ] Booking Management
    - **Step:** Navigate to "Bookings" in the Owner Dashboard.
    - **Check:** Confirm you can see bookings made by players for your venues.

## Admin Functionality

- [ ] Dashboard Overview
    - **Step:** Login as Admin and view the dashboard.
    - **Check:** Verify counts for total users, venues, and bookings are displayed.
- [ ] User Management
    - **Step:** Navigate to "Manage Users".
    - **Check:** verify list of all players and owners is visible.
- [ ] Venue Verification
    - **Step:** Navigate to "Manage Venues".
    - **Check:** Identify unverified venues and verify them. Confirm they now appear in player search results.

## H2 Database Verification

- [ ] Database State
    - **Step:** Access `http://localhost:8080/h2-console`. Run `SELECT * FROM USERS;` and `SELECT * FROM BOOKINGS;`.
    - **Check:** Verify that rows corresponding to your actions (registration, booking) are present in the tables.
