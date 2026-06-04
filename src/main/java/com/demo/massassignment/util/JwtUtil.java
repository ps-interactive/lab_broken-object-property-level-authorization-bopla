package com.demo.massassignment.util;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import java.nio.charset.StandardCharsets;
import java.util.Date;

public class JwtUtil {

    private static final String SECRET_STRING =
            "your-very-secure-and-long-secret-key-here-12345";

    private static final java.security.Key KEY =
            Keys.hmacShaKeyFor(
                    SECRET_STRING.getBytes(StandardCharsets.UTF_8)
            );

    public static String generateToken(String username, String role) {
        return Jwts.builder()
                .setSubject(username)
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(
                        new Date(System.currentTimeMillis() + 3600000) // 1 Hour
                )
                .signWith(KEY)
                .compact();
    }

    /**
     * Validates if the token was signed with our key and is not expired.
     */
    public static boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(KEY)
                    .build()
                    .parseClaimsJws(token);
            return true; // Token is structurally valid and untampered with
        } catch (JwtException | IllegalArgumentException e) {
            // Catches ExpiredJwtException, MalformedJwtException, SignatureException, etc.
            return false; 
        }
    }

    /**
     * Extracts the username (Subject) from the token.
     */
    public static String getUsernameFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(KEY)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    /**
     * Extracts the custom "role" claim from the token.
     */
    public static String getRoleFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(KEY)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .get("role", String.class);
    }
}