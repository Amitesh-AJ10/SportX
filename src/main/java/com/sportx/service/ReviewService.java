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

