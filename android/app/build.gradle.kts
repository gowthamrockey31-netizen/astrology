plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.astrocall.astrocall"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.astrocall.astrocall"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            ndk {
                debugSymbolLevel = "none"
            }
        }
    }
}

flutter {
    source = "../.."
}

tasks.matching { it.name == "assembleRelease" }.configureEach {
    doLast {
        val srcApk = File(project.layout.buildDirectory.get().asFile, "outputs/flutter-apk/app-release.apk")
        val altSrcApk = File(project.layout.buildDirectory.get().asFile, "outputs/apk/release/app-release.apk")
        val targetDir = File(rootDir, "../build/app/outputs/flutter-apk")
        val rootApk = File(rootDir, "../AstroDashaCare.apk")
        val finalSrc = if (srcApk.exists()) srcApk else altSrcApk
        if (finalSrc.exists()) {
            targetDir.mkdirs()
            finalSrc.copyTo(File(targetDir, "app-release.apk"), overwrite = true)
            finalSrc.copyTo(rootApk, overwrite = true)
        }
    }
}
