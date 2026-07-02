package RestaurantRating.backend.controller;

import RestaurantRating.backend.entity.User;
import RestaurantRating.backend.service.UserService;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.List;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public UserResponse create(@RequestBody @Validated CreateUserRequest request) {
        return toResponse(userService.create(request.name(), request.email()));
    }

    @GetMapping
    public List<UserResponse> findAll() {
        return userService.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/{id}")
    public UserResponse findById(@PathVariable Long id) {
        return toResponse(userService.findById(id));
    }

    private UserResponse toResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getCreatedAt()
        );
    }

    public record CreateUserRequest(
            @NotBlank String name,
            @NotBlank @Email String email
    ) {
    }

    public record UserResponse(
            Long id,
            String name,
            String email,
            Instant createdAt
    ) {
    }
}
