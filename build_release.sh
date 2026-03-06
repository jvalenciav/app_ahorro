#!/bin/bash

echo "🔐 Configurando firma release..."

# ============================================
# CAMBIA ESTA CONTRASEÑA ANTES DE EJECUTAR
# ============================================
KEY_PASSWORD="Lacoloniacurva2020*"
STORE_FILE="mi_ahorrito.jks"
KEY_ALIAS="mi_ahorrito"

# ============================================
# 1. Generar keystore si no existe
# ============================================
if [ ! -f "$STORE_FILE" ]; then
  echo "🔑 Generando keystore..."
  keytool -genkey -v \
    -keystore $STORE_FILE \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias $KEY_ALIAS \
    -storepass "$KEY_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Mi Ahorrito, OU=Dev, O=MiAhorrito, L=Mexico, S=Mexico, C=MX"
  echo "✅ Keystore generado"
else
  echo "✅ Keystore ya existe"
fi

# ============================================
# 2. Crear android/key.properties
# ============================================
cat > android/key.properties << KEYPROPS
storePassword=$KEY_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=../../$STORE_FILE
KEYPROPS
echo "✅ key.properties creado"

# ============================================
# 3. build.gradle CORRECTO
#    plugins {} PRIMERO, keystore despues
# ============================================
cat > android/app/build.gradle << 'GRADLE'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// Carga del keystore (debe ir DESPUES de plugins {})
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.mi_ahorrito"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.example.mi_ahorrito"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
            minifyEnabled false
            shrinkResources false
        }
        debug {
            signingConfig = signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}
GRADLE

echo "✅ build.gradle reescrito (plugins primero)"

# ============================================
# 4. .gitignore
# ============================================
if ! grep -q "mi_ahorrito.jks" .gitignore 2>/dev/null; then
  echo "" >> .gitignore
  echo "# Keystore - NO subir" >> .gitignore
  echo "mi_ahorrito.jks" >> .gitignore
  echo "android/key.properties" >> .gitignore
fi
echo "✅ .gitignore actualizado"

# ============================================
# 5. Build release
# ============================================
echo ""
echo "🧹 Limpiando..."
flutter clean

echo "📦 Dependencias..."
flutter pub get

echo ""
echo "🏗️  Generando App Bundle release firmado..."
flutter build appbundle --release

# ============================================
# Resultado
# ============================================
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
  AAB_SIZE=$(du -sh "$AAB_PATH" | cut -f1)
  echo ""
  echo "============================================"
  echo "  APP BUNDLE RELEASE LISTO ✅"
  echo "============================================"
  echo ""
  echo "  Archivo : $AAB_PATH"
  echo "  Tamaño  : $AAB_SIZE"
  echo ""
  echo "  Sube ese .aab a Google Play Store"
  echo ""
  echo "  ⚠️  GUARDA mi_ahorrito.jks EN LUGAR SEGURO"
  echo "      Sin él no puedes publicar actualizaciones"
else
  echo ""
  echo "❌ Error al generar el bundle."
  echo "   Revisa los mensajes arriba."
fi
