plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ailaga.ailaga"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }



    defaultConfig {
        applicationId = "com.ailaga.ailaga"
        minSdk = 26
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // S6: the "demo" flavor ships with no INTERNET permission (removed in
    // src/demo/AndroidManifest.xml) to prove the app runs fully on-device.
    // Day-to-day builds use the "app" flavor:
    //   flutter run --flavor app
    //   flutter build apk --flavor demo
    flavorDimensions += "audience"
    productFlavors {
        create("app") {
            dimension = "audience"
        }
        create("demo") {
            dimension = "audience"
        }
    }
}



flutter {
    source = "../.."
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
