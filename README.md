

# BOPLA Mass Assignment Fix Exercise
Broken Object Property Level Authorization.

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

- isAdmin

---

# Refactor the Controller

Replace the `updateUser()` method, at the vulnerable endpoint, that accepts a `User` object with one that accepts an `UpdateUserRequestDTO`.

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

The following payload submitted with a regular `$USER_TOKEN:

```json
{
  "email": "attacker@test.com",
  "bio": "Owned",
  "isAdmin": true
}
```

must update **only** these object fields:

- `email`
- `bio`

> **Important**: but must **NOT** modify:

- `isAdmin`

After the fix, the user's admin status should remain unchanged.

You should **only** be able to modify `isAdmin` via the administrative `/{id}/role` endpoint and **only** when supplyng a valid `$ADMIN_TOKEN` token.
