package com.gymbro.divkit.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

/**
 * Public origin of this DivKit server (scheme + host + port), as used by mobile clients to load images.
 * Must not be localhost when testing on a physical device.
 */
@Component
class DivKitPublicUrls(
    @Value("\${gymbro.divkit.public-base-url:http://localhost:8090}") rawBase: String,
) {
    private val normalizedBase: String = rawBase.trimEnd('/')

    val publicBaseUrl: String = normalizedBase

    val assetsBaseUrl: String = "$normalizedBase/assets"
}
