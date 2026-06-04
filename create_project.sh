#!/bin/bash

set -e

echo "Creating Mass Assignment BOPLA Lab project..."

# =========================================================
# CREATE DIRECTORY STRUCTURE
# =========================================================

mkdir -p src/main/java/com/demo/massassignment

mkdir -p src/main/java/com/demo/massassignment/controller
mkdir -p src/main/java/com/demo/massassignment/model
mkdir -p src/main/java/com/demo/massassignment/repository
mkdir -p src/main/java/com/demo/massassignment/dto
mkdir -p src/main/java/com/demo/massassignment/config

mkdir -p src/main/resources

mkdir -p learner-fix

# =========================================================
# pom.xml
# =========================================================

cat > pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="
         http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>com.demo</groupId>
    <artifactId>mass-assignment-lab</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>21</java.version>
        <spring.boot.version>3.3.0</spring.boot.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>${spring.boot.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>

        <!-- Spring Boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

    </dependencies>

    <build>
        <plugins>

            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>

                <configuration>
                    <source>21</source>
                    <target>21</target>
                </configuration>
            </plugin>

        </plugins>
    </build>

</project>
EOF

# =========================================================
# APPLICATION
# =========================================================

cat > src/main/java/com/demo/massassignment/MassAssignmentApplication.java <<'EOF'
package com.demo.massassignment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class MassAssignmentApplication {

    public static void main(String[] args) {
        SpringApplication.run(MassAssignmentApplication.class, args);
    }
}
EOF

# =========================================================
# USER MODEL
# =========================================================

cat > src/main/java/com/demo/massassignment/model/User.java <<'EOF'
package com.demo.massassignment.model;

public class User {

    private Long id;

    private String username;

    private String email;

    private String bio;

    // Sensitive field
    private boolean isAdmin;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean admin) {
        isAdmin = admin;
    }
}
EOF

# =========================================================
# REPOSITORY
# =========================================================

cat > src/main/java/com/demo/massassignment/repository/UserRepository.java <<'EOF'
package com.demo.massassignment.repository;

import com.demo.massassignment.model.User;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
public class UserRepository {

    private final Map<Long, User> users = new HashMap<>();

    @PostConstruct
    public void init() {

        User user = new User();

        user.setId(1L);
        user.setUsername("john");
        user.setEmail("john@test.com");
        user.setBio("Initial bio");
        user.setAdmin(false);

        users.put(1L, user);
    }

    public User findById(Long id) {
        return users.get(id);
    }

    public User save(User user) {
        users.put(user.getId(), user);
        return user;
    }
}
EOF

# =========================================================
# VULNERABLE CONTROLLER
# =========================================================

cat > src/main/java/com/demo/massassignment/controller/UserController.java <<'EOF'
package com.demo.massassignment.controller;

import com.demo.massassignment.model.User;
import com.demo.massassignment.repository.UserRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {

        return userRepository.findById(id);
    }

    // =====================================================
    // VULNERABLE ENDPOINT
    // =====================================================
    //
    // MASS ASSIGNMENT VULNERABILITY:
    //
    // Spring automatically binds ALL incoming JSON fields
    // into the User object.
    //
    // An attacker can send:
    //
    // {
    //   "isAdmin": true
    // }
    //
    // and escalate privileges.
    //
    // Learners must fix this using DTOs.
    //
    // =====================================================

    @PutMapping("/{id}")
    public User updateUser(
            @PathVariable Long id,
            @RequestBody User request
    ) {

        request.setId(id);

        return userRepository.save(request);
    }
}
EOF

# =========================================================
# application.properties
# =========================================================

cat > src/main/resources/application.properties <<'EOF'
server.port=8080
EOF

# =========================================================
# LEARNER FIX FILE
# =========================================================

cat > learner-fix/README_FIX_INSTRUCTIONS.md <<'EOF'
# Mass Assignment Fix Exercise

## Learning Objective

Prevent Mass Assignment vulnerabilities using DTOs.

---

# Vulnerability

The current endpoint directly binds incoming JSON into the domain model:

```java
@PutMapping("/{id}")
public User updateUser(
        @PathVariable Long id,
        @RequestBody User request
) {

    request.setId(id);

    return userRepository.save(request);
}
```

Example attack payload:

```json
{
  "email": "attacker@test.com",
  "bio": "Owned",
  "isAdmin": true
}
```

---

# Your Task

Implement a DTO named:

```
UpdateUserRequest
```

The DTO should only contain:

- email
- bio

The DTO must not contain:

- id
- username
- isAdmin

---

# Refactor the Controller

Replace the vulnerable endpoint that accepts a User object with one that accepts an UpdateUserRequest DTO.

Load the existing user from the repository and explicitly map the allowed fields:

```java
user.setEmail(dto.getEmail());
user.setBio(dto.getBio());
```

Then save the updated user.

---

# Important

Do not use:

- BeanUtils.copyProperties(...)
- ModelMapper
- automatic object mapping libraries

The goal of this exercise is to practice explicit allow-listing of fields.

---

# Success Criteria

The following request:

```json
{
  "email": "attacker@test.com",
  "bio": "Owned",
  "isAdmin": true
}
```

must update:

- email
- bio

but must NOT modify:

- isAdmin

After the fix, the user's admin status should remain unchanged.
EOF

echo ""
echo "=============================================="
echo "Mass Assignment Lab Created Successfully"
echo "=============================================="

echo ""
echo "Build:"
echo "mvn clean package"

echo ""
echo "Run:"
echo "mvn spring-boot:run"
