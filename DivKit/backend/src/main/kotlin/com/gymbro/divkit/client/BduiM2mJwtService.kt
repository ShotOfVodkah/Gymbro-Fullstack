package com.gymbro.divkit.client

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.security.KeyFactory
import java.security.interfaces.RSAPrivateKey
import java.security.spec.PKCS8EncodedKeySpec
import java.util.Base64
import java.util.Date

@Service
class BduiM2mJwtService(
    @Value("\${gymbro.bdui.m2m.issuer:gymbro-bdui}") private val issuer: String,
    @Value("\${gymbro.bdui.m2m.audience:gymbro-workouts}") private val audience: String,
    @Value("\${gymbro.bdui.m2m.ttl-seconds:300}") private val ttlSeconds: Long,
    @Value("\${gymbro.bdui.m2m.private-key-pem:}") private val privateKeyPemConfig: String,
) {
    private val privateKey: RSAPrivateKey
    private val algorithm: Algorithm

    init {
        val pem = (System.getenv("BDUI_M2M_JWT_PRIVATE_KEY_PEM")?.trim()?.takeIf { it.isNotEmpty() }
            ?: privateKeyPemConfig.trim())
        if (pem.isEmpty()) {
            error("Set BDUI_M2M_JWT_PRIVATE_KEY_PEM (PKCS#8, BEGIN PRIVATE KEY) for RS256 M2M to Workouts.")
        }
        privateKey = loadPkcs8RsaPrivateKey(pem)
        algorithm = Algorithm.RSA256(null, privateKey)
    }

    fun createTokenForUserId(userId: String): String {
        val now = Date()
        return JWT.create()
            .withIssuer(issuer)
            .withAudience(audience)
            .withSubject(BduiM2MSub)
            .withClaim(ClaimUserId, userId)
            .withIssuedAt(now)
            .withExpiresAt(Date(now.time + ttlSeconds * 1000))
            .sign(algorithm)
    }

    private fun loadPkcs8RsaPrivateKey(pem: String): RSAPrivateKey {
        val normalized = pem
            .replace("-----BEGIN PRIVATE KEY-----", "")
            .replace("-----END PRIVATE KEY-----", "")
            .replace("\\s".toRegex(), "")
        val bytes = Base64.getDecoder().decode(normalized)
        val spec = PKCS8EncodedKeySpec(bytes)
        return KeyFactory.getInstance("RSA").generatePrivate(spec) as RSAPrivateKey
    }

    private companion object {
        const val ClaimUserId = "user_id"
        const val BduiM2MSub = "bdui-m2m"
    }
}
