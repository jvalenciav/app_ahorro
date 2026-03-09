#!/bin/bash

echo "🔧 Corrigiendo MainActivity.kt..."

NEW_PATH="android/app/src/main/kotlin/com/juancarlos/miahorrito"

# ============================================
# 1. Crear la carpeta correcta
# ============================================
mkdir -p "$NEW_PATH"

# ============================================
# 2. Escribir MainActivity.kt con el package correcto
# ============================================
cat > "$NEW_PATH/MainActivity.kt" << 'KT'
package com.juancarlos.miahorrito

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
KT

echo "✅ MainActivity.kt creado en $NEW_PATH"

# ============================================
# 3. Eliminar carpetas viejas de com.example
# ============================================
if [ -d "android/app/src/main/kotlin/com/example" ]; then
  rm -rf "android/app/src/main/kotlin/com/example"
  echo "✅ Carpeta com.example eliminada"
fi

# Limpiar carpetas vacías intermedias
find "android/app/src/main/kotlin" -empty -type d -delete 2>/dev/null

# ============================================
# 4. Verificar AndroidManifest.xml
# ============================================
sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" android/app/src/main/AndroidManifest.xml
echo "✅ AndroidManifest.xml verificado"

# ============================================
# 5. Verificar build.gradle
# ============================================
sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" android/app/build.gradle
echo "✅ build.gradle verificado"

# ============================================
# 6. Mostrar estructura final para verificar
# ============================================
echo ""
echo "Estructura kotlin:"
find android/app/src/main/kotlin -type f

# ============================================
# 7. Build
# ============================================
echo ""
echo "🧹 Limpiando..."
flutter clean

echo "📦 Dependencias..."
flutter pub get

echo ""
echo "🏗️  Generando App Bundle..."
flutter build appbundle --release

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
  echo ""
  echo "============================================"
  echo "  LISTO ✅"
  echo "============================================"
  echo "  Archivo: $AAB_PATH"
else
  echo "❌ Error al generar el bundle."
fi
