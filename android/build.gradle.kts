import org.jetbrains.kotlin.gradle.dsl.JvmTarget

group = "com.adhub.adhub"
version = "1.0"

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.adhub.adhub"
    compileSdk = 37

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_21)
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:25.4.0")
    implementation("com.google.ads.mediation:applovin:13.6.4.0")
    implementation("com.google.ads.mediation:facebook:6.22.0.0")
    implementation("com.google.ads.mediation:unity:4.20.0.0")
    implementation("com.unity3d.ads:unity-ads:4.20.0")
}
