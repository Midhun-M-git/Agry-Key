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
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH") ?: project.findProperty("KEYSTORE_PATH") as String?
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD") ?: project.findProperty("KEYSTORE_PASSWORD") as String?
            val keyAliasStr = System.getenv("KEY_ALIAS") ?: project.findProperty("KEY_ALIAS") as String?
            val keyPasswordStr = System.getenv("KEY_PASSWORD") ?: project.findProperty("KEY_PASSWORD") as String?
            val localKeystore = file("agrikey-release.jks")

            if (!keystorePath.isNullOrEmpty() && file(keystorePath).exists()) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword ?: ""
                keyAlias = keyAliasStr ?: ""
                keyPassword = keyPasswordStr ?: ""
                enableV1Signing = true
                enableV2Signing = true
            } else if (localKeystore.exists()) {
                storeFile = localKeystore
                storePassword = keystorePassword ?: "agrikey2026"
                keyAlias = keyAliasStr ?: "agrikey"
                keyPassword = keyPasswordStr ?: "agrikey2026"
                enableV1Signing = true
                enableV2Signing = true
            } else {
                try {
                    val process = ProcessBuilder(
                        "keytool", "-genkey", "-v",
                        "-keystore", localKeystore.absolutePath,
                        "-alias", "agrikey",
                        "-keyalg", "RSA",
                        "-keysize", "2048",
                        "-validity", "10000",
                        "-storepass", "agrikey2026",
                        "-keypass", "agrikey2026",
                        "-dname", "CN=AgriKey, OU=Mobile, O=AgriKey, L=Kochi, S=Kerala, C=IN"
                    ).inheritIO().start()
                    process.waitFor()
                } catch (e: Exception) {
                    println("Note: Keytool automated keystore generation skipped: ${e.message}")
                }

                if (localKeystore.exists()) {
                    storeFile = localKeystore
                    storePassword = "agrikey2026"
                    keyAlias = "agrikey"
                    keyPassword = "agrikey2026"
                    enableV1Signing = true
                    enableV2Signing = true
                }
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile != null && releaseConfig.storeFile!!.exists()) {
                signingConfig = releaseConfig
            }
        }
    }
}

flutter {
    source = "../.."
}
