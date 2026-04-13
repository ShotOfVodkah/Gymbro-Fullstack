package com.gymbro.divkit.auth

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.http.MediaType
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 10)
class JwtAuthenticationFilter(
    private val gymbroJwtService: GymbroJwtService
) : OncePerRequestFilter() {

    override fun shouldNotFilter(request: HttpServletRequest): Boolean {
        val path = request.servletPath
        if (path.startsWith("/divkit/templates/")) return true
        if (path == "/workoutBuilderForType" || path.startsWith("/workoutBuilderForType/")) return true
        return false
    }

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val path = request.servletPath
        if (!requiresAuth(path)) {
            filterChain.doFilter(request, response)
            return
        }

        val header = request.getHeader("Authorization")
        if (header.isNullOrBlank() || !header.startsWith("Bearer ")) {
            unauthorized(response)
            return
        }
        val token = header.removePrefix("Bearer ").trim()
        if (token.isEmpty()) {
            unauthorized(response)
            return
        }
        val userId = gymbroJwtService.validateBearerToken(token)
        if (userId == null) {
            unauthorized(response)
            return
        }
        request.setAttribute(GymbroJwtAuth.USER_ID_ATTRIBUTE, userId)
        filterChain.doFilter(request, response)
    }

    private fun requiresAuth(path: String): Boolean =
        path == "/workoutsList" ||
            path.startsWith("/workoutsList/") ||
            path == "/workoutInfo" ||
            path.startsWith("/workoutInfo/") ||
            path == "/workoutBuilderSheet" ||
            path.startsWith("/workoutBuilderSheet/") ||
            path == "/workoutBuilderTitle" ||
            path.startsWith("/workoutBuilderTitle/")

    private fun unauthorized(response: HttpServletResponse) {
        response.status = HttpServletResponse.SC_UNAUTHORIZED
        response.contentType = MediaType.APPLICATION_JSON_VALUE
        response.characterEncoding = Charsets.UTF_8.name()
        response.writer.write("""{"error":"unauthorized"}""")
    }
}
