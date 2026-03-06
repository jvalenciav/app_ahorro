#!/bin/bash

echo "📦 Cambiando package name a com.valencia.miahorrito..."

OLD_PACKAGE="com.example.mi_ahorrito"
NEW_PACKAGE="com.valencia.miahorrito"

# ============================================
# 1. build.gradle - applicationId y namespace
# ============================================
sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" android/app/build.gradle
echo "✅ build.gradle actualizado"

# ============================================
# 2. AndroidManifest.xml
# ============================================
sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" android/app/src/main/AndroidManifest.xml
sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" android/app/src/debug/AndroidManifest.xml 2>/dev/null
sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" android/app/src/profile/AndroidManifest.xml 2>/dev/null
echo "✅ AndroidManifest.xml actualizado"

# ============================================
# 3. MainActivity.kt - mover a nueva carpeta
# ============================================
OLD_PATH="android/app/src/main/kotlin/com/example/mi_ahorrito"
NEW_PATH="android/app/src/main/kotlin/com/juancarlos/miahorrito"

if [ -d "$OLD_PATH" ]; then
  mkdir -p "$NEW_PATH"
  cp "$OLD_PATH/MainActivity.kt" "$NEW_PATH/MainActivity.kt"
  sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" "$NEW_PATH/MainActivity.kt"
  rm -rf "android/app/src/main/kotlin/com/example"
  echo "✅ MainActivity.kt movido a nueva ruta"
else
  echo "⏭️  Carpeta kotlin no encontrada, buscando..."
  find android -name "MainActivity.kt" | while read f; do
    sed -i "s|com.example.mi_ahorrito|com.juancarlos.miahorrito|g" "$f"
    echo "✅ $f actualizado"
  done
fi

# ============================================
# 4. Build release
# ============================================
echo ""
echo "🧹 Limpiando..."
flutter clean

echo "📦 Dependencias..."
flutter pub get

echo ""
echo "🏗️  Generando App Bundle con nuevo package..."
flutter build appbundle --release

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
  echo ""
  echo "============================================"
  echo "  LISTO ✅  package: com.juancarlos.miahorrito"
  echo "============================================"
  echo ""
  echo "  Archivo: $AAB_PATH"
else
  echo "❌ Error al generar el bundle."
fi
