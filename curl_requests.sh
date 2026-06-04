#!/bin/bash

# Assumption: SecurityConfig.java and JwtAuthenticationFilter.java must exist as part of the project from the get-go.

# ========================================== #
# 1. OBTAIN AND USER TOKEN                   #
# ========================================== #

# Get USER token
USER_TOKEN=$(curl -s -X POST http://localhost:8080/auth/token \
-H "Content-Type: application/json" \
-d '{
  "username":"user",
  "password":"user123"
}' | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
echo "Captured USER_TOKEN:"
echo "$USER_TOKEN"



# =============================================== #
# 2. BOPLA VULNERABLE STATE (Before Refactoring)  #
# =============================================== #

# Show that intially isAdmin=false
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:8080/api/users/1 | jq

# BOPLA - mutate isAdmin; initially this succeeds because we pass a valid USER token 
# but the backend lacks DTO restrictions.
curl -X PUT http://localhost:8080/api/users/1 \
-H "Authorization: Bearer $USER_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "email":"attacker@test.com",
  "bio":"Owned",
  "admin":true
}' | jq

# Show that isAdmin=true - BOPLA revlealed
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:8080/api/users/1 | jq

# BOPLA - mutate isAdmin back to false using USER token
curl -X PUT http://localhost:8080/api/users/1 \
-H "Authorization: Bearer $USER_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "email":"attacker@test.com",
  "bio":"Owned",
  "admin":false
}' | jq

# Confirm user obejct with ID=1 has isAdmin reset back to "false"
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:8080/api/users/1 | jq

# ========================================================= #
# MANUAL LAB INTERMISSION STEPS:                            #
# - Create UpdateUserRequestDTO                             #
# - Replace User (model) with UpdateUserRequestDTO          #
#     in UserController (@PutMapping("/{id}"))              #
# - Create UpdateUserRoleRequestDTO                         #
# - Create AdminUserController.java - no need;              #
#     included with code base; only a walkthrough is needed #
# ========================================================= #


# ============================================ #
# 3. BOPLA MITIGATED STATE (After Refactoring) #
# ============================================ #

# !!! Obtain new tokens as the key changes upon app restart
# Get USER token
USER_TOKEN=$(curl -s -X POST http://localhost:8080/auth/token \
-H "Content-Type: application/json" \
-d '{
  "username":"user",
  "password":"user123"
}' | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
echo "Captured USER_TOKEN:"
echo "$USER_TOKEN"

# Get ADMIN token
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8080/auth/token \
-H "Content-Type: application/json" \
-d '{
  "username":"admin",
  "password":"admin123"
}' | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
echo "Captured ADMIN_TOKEN:"
echo "$ADMIN_TOKEN"


# BOPLA fixed test - regular user tries to escalate again
# This requests returns a plain HTTP response, hence we don't use jq
curl -X PUT http://localhost:8080/api/users/1 \
-H "Authorization: Bearer $USER_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "email":"attacker@test.com",
  "bio":"Owned",
  "admin":true
}'

# Confirming isAdmin=true was NOT overwritten and is still false
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:8080/api/users/1 | jq

# Expected Sample output:
{
  "id": 1,
  "username": "john",
  "email": "attacker@test.com",
  "bio": "Owned",
  "admin": false
}


# ===================================================== #
# 4. TESTING THE NEW DEDICATED WORKFLOW & BFLA DEFENSES #
# ===================================================== #

# Attempt unsuccessfully to mutate the isAdmin property via the Admin endpoint using a USER token
# Expected Result: 403 Forbidden (Spring Security @PreAuthorize blocks it)
curl -i -X PUT http://localhost:8080/api/admin/users/1/role \
-H "Authorization: Bearer $USER_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "admin": true
}' | jq

# Verify via GET that isAdmin has not changed and remains false
curl -H "Authorization: Bearer $USER_TOKEN" http://localhost:8080/api/users/1 | jq


# Mutate isAdmin successfully using an ADMIN token on the dedicated endpoint
# Expected Result: 204 No Content / 200 OK (Allowed by @PreAuthorize)
curl -i -X PUT http://localhost:8080/api/admin/users/1/role \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "admin": true
}' | jq

# Verify via GET that isAdmin has successfully changed to true
curl -H "Authorization: Bearer $ADMIN_TOKEN" http://localhost:8080/api/users/1 | jq