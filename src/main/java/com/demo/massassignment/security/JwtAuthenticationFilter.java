package com.demo.massassignment.security;

import com.demo.massassignment.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.Collections;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                    HttpServletResponse response, 
                                    FilterChain filterChain) throws ServletException, IOException {
        
        // 1. Extract the Authorization header
        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7); // Remove "Bearer " prefix

            try {
                // 2. Validate token and extract claims (assumes these methods exist in your JwtUtil)
                if (JwtUtil.validateToken(token)) {
                    String username = JwtUtil.getUsernameFromToken(token);
                    String role = JwtUtil.getRoleFromToken(token); // e.g., "ROLE_ADMIN" or "ROLE_USER"

                    // 3. Convert the role String into a Spring Security Authority Object
                    SimpleGrantedAuthority authority = new SimpleGrantedAuthority(role);

                    // 4. Create an Authentication object containing the user details and their roles
                    UsernamePasswordAuthenticationToken authentication = 
                            new UsernamePasswordAuthenticationToken(username, null, Collections.singletonList(authority));

                    // 5. Inject this into Spring Security's Context
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            } catch (Exception e) {
                // If token is expired or invalid, clear context (or let it fail naturally)
                SecurityContextHolder.clearContext();
            }
        }

        // 6. Continue the request down the filter chain
        filterChain.doFilter(request, response);
    }
}