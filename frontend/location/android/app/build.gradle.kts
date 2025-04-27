plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter Gradle doit être appliqué après les plugins Android et Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.location"
    compileSdk = 34 // Remarque ici l'utilisation de '=' au lieu de 'compileSdkVersion'
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Spécifie ton propre ID d'application unique (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.location"
        // Tu peux mettre à jour les valeurs suivantes pour correspondre aux besoins de ton application.
        // Pour plus d'informations, voir: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Ajoute ta propre configuration de signature pour la build de release.
            // Utilisation des clés de debug pour le moment, pour que `flutter run --release` fonctionne.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
