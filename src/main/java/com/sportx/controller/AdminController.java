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

