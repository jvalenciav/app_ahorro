#!/bin/bash

echo "✏️ Cambiando nombre a: Mi Ahorrito – Retos de Ahorro..."

# ============================================
# 1. pubspec.yaml - nombre del paquete y descripción
# ============================================
sed -i 's/^name: ahorro$/name: mi_ahorrito/' pubspec.yaml
sed -i 's/^description:.*$/description: Mi Ahorrito – Retos de Ahorro. Cumple tus metas de ahorro paso a paso./' pubspec.yaml
echo "✅ pubspec.yaml"

# ============================================
# 2. main.dart - título de la app
# ============================================
sed -i "s/title: 'Ahorro App'/title: 'Mi Ahorrito'/" lib/main.dart
echo "✅ main.dart (title)"

# ============================================
# 3. onboarding_screen.dart - texto de bienvenida
# ============================================
sed -i "s/Bienvenido a\\\\nAhorro App/Bienvenido a\\\\nMi Ahorrito/" lib/screens/onboarding_screen.dart
echo "✅ onboarding_screen.dart"

# ============================================
# 4. about_screen.dart - nombre de la app
# ============================================
sed -i "s/Text('Ahorro App'/Text('Mi Ahorrito'/" lib/screens/about_screen.dart
echo "✅ about_screen.dart"

# ============================================
# 5. android/app/src/main/AndroidManifest.xml - nombre visible en el dispositivo
# ============================================
sed -i 's/android:label="[^"]*"/android:label="Mi Ahorrito"/' android/app/src/main/AndroidManifest.xml
echo "✅ AndroidManifest.xml"

# ============================================
# 6. strings.xml si existe
# ============================================
STRINGS_FILE="android/app/src/main/res/values/strings.xml"
if [ -f "$STRINGS_FILE" ]; then
  sed -i 's/<string name="app_name">.*<\/string>/<string name="app_name">Mi Ahorrito<\/string>/' "$STRINGS_FILE"
  echo "✅ strings.xml"
else
  echo "⏭️  strings.xml no encontrado (no es necesario)"
fi

# ============================================
# Verificación rápida
# ============================================
echo ""
echo "============================================"
echo "  NOMBRE ACTUALIZADO CORRECTAMENTE"
echo "============================================"
echo ""
echo "Archivos modificados:"
echo "  • pubspec.yaml         → name + description"
echo "  • lib/main.dart        → title de MaterialApp"
echo "  • onboarding_screen    → texto bienvenida"
echo "  • about_screen         → nombre en pantalla"
echo "  • AndroidManifest.xml  → nombre en el dispositivo"
echo ""
echo "Ejecuta:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter run"
