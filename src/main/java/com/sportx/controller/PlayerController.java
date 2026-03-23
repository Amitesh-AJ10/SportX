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

