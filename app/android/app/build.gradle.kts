import java.util.Properties

// Firma de release: key.properties (local, git-ignored) o variables de entorno (CI).
// Sin ninguna de las dos, el release se firma con la clave debug (solo para pruebas locales).
val keystoreProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
fun signingValue(key: String, env: String): String? =
    keystoreProps.getProperty(key) ?: System.getenv(env)

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fanal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications necesita desugaring (APIs de java.time en Android antiguos)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.fanal"
        minSdk = 24 // flutter_secure_storage + biometría
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val storePath = signingValue("storeFile", "FARO_KEYSTORE_PATH")
        if (storePath != null) {
            create("release") {
                storeFile = file(storePath)
                storePassword = signingValue("storePassword", "FARO_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "FARO_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "FARO_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
