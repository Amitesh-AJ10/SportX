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

