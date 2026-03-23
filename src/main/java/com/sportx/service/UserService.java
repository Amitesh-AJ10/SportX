package com.sportx.service;

import com.sportx.config.UserFactory;
import com.sportx.dto.RegisterDTO;
import com.sportx.model.User;
import com.sportx.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * UserService — handles registration and profile operations.
 * Design Principle: SRP — only user-related business logic here.
 * Design Principle: DIP — depends on abstractions (Repository interface).
 * Design Pattern: Facade — hides JPA complexity from controllers.
 */
@Service
@Transactional
public class UserService {

    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private UserFactory userFactory;

    public User register(RegisterDTO dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }
        String encoded = passwordEncoder.encode(dto.getPassword());
        User user = userFactory.createUser(dto, encoded);
        return userRepository.save(user);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public Optional<User> findByUserId(String userId) {
        return userRepository.findByUserId(userId);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User updateProfile(String email, String name, String phone) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.updateProfile(name, phone);
        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}

