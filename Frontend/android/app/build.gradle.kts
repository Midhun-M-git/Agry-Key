plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.agrikey"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.agrikey"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        missingDimensionStrategy("distribution", "github")
    }

    flavorDimensions += "distribution"

    productFlavors {
        create("github") {
            dimension = "distribution"
        }
        create("play") {
            dimension = "distribution"
        }
    }

    signingConfigs {
        create("release") {
            val keystoreFile = file("agrikey-release.jks")
            if (keystoreFile.exists()) {
                storeFile = keystoreFile
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: "agrikey2026"
                keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: "agrikey"
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD") ?: "agrikey2026"
                enableV1Signing = true
                enableV2Signing = true
            } else {
                val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
                if (isReleaseTask) {
                    throw GradleException("Release build failed: Release keystore 'agrikey-release.jks' was not found. Debug signing fallback is prohibited for release builds.")
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
