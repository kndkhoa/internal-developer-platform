package ${{ values.javaPackage }}.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class HealthController {

    @Value("${spring.application.name}")
    private String appName;

    @Value("${spring.profiles.active:default}")
    private String activeProfile;

    @GetMapping("/")
    public Map<String, Object> root() {
        return Map.of(
            "service", appName,
            "environment", activeProfile,
            "status", "running",
            "timestamp", Instant.now().toString()
        );
    }
}
