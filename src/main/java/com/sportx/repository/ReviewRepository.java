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

