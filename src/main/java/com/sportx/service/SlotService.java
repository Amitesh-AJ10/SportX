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

