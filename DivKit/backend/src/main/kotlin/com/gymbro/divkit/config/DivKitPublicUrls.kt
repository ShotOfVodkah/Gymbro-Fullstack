package com.gymbro.divkit.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

@Component
class DivKitPublicUrls(
    @Value("\${gymbro.divkit.public-base-url:http://localhost:8090}") rawBase: String,
) {
    private val normalizedBase: String = rawBase.trimEnd('/')

    val publicBaseUrl: String = normalizedBase

    val assetsBaseUrl: String = "$normalizedBase/assets"
}
