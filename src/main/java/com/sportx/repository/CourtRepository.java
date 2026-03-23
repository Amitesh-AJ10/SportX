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

