package com.gymbro.divkit.auth

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.time.Instant
import java.util.Base64
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

@Service
class GymbroJwtService(
    @Value("\${gymbro.jwt.secret:}") secretRaw: String,
    private val objectMapper: ObjectMapper
) {

    private val secretTrimmed = secretRaw.trim()

    fun validateBearerToken(token: String): String? {
        if (secretTrimmed.isBlank()) {
            return null
        }
        return try {
            val parts = token.split('.')
            if (parts.size != 3) {
                return null
            }
            val headerJson = String(Base64.getUrlDecoder().decode(parts[0]), StandardCharsets.UTF_8)
            val alg = objectMapper.readTree(headerJson).get("alg")?.asText()
            if (alg != "HS256") {
                return null
            }
            val signingBytes = "${parts[0]}.${parts[1]}".toByteArray(StandardCharsets.US_ASCII)
            val signature = Base64.getUrlDecoder().decode(parts[2])
            val mac = Mac.getInstance("HmacSHA256")
            mac.init(SecretKeySpec(secretTrimmed.toByteArray(StandardCharsets.UTF_8), "HmacSHA256"))
            val expected = mac.doFinal(signingBytes)
            if (!MessageDigest.isEqual(signature, expected)) {
                return null
            }
            val payloadJson = String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8)
            val payload = objectMapper.readTree(payloadJson)
            if (payload.get("iss")?.asText() != "gymbro") {
                return null
            }
            val expNode = payload.get("exp")
            if (expNode != null && expNode.isNumber) {
                val expSec = expNode.asLong()
                if (Instant.now().epochSecond >= expSec) {
                    return null
                }
            }
            val userIdNode = payload.get("user_id")
            val userId = when {
                userIdNode == null -> null
                userIdNode.isInt -> userIdNode.asInt()
                userIdNode.isLong -> userIdNode.asLong().toInt()
                userIdNode.isNumber -> userIdNode.asInt()
                else -> null
            }
            userId?.toString()
        } catch (_: Exception) {
            null
        }
    }
}
