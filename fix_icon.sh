#!/bin/bash

echo "🎨 Aplicando ícono al 100% proporcional..."

# ============================================
# pubspec.yaml - imagen directa sin modificar
# ============================================
cat > pubspec.yaml << 'PUBSPEC'
name: mi_ahorrito
description: Mi Ahorrito – Retos de Ahorro. Cumple tus metas de ahorro paso a paso.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  uuid: ^4.3.3
  intl: ^0.19.0
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  url_launcher: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "logoFinal.png"
  min_sdk_android: 21
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "logoFinal.png"

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - logoFinal.png
PUBSPEC

echo "✅ pubspec.yaml actualizado"

flutter pub get

echo ""
echo "🖼️  Generando íconos..."
dart run flutter_launcher_icons

echo ""
echo "============================================"
echo "  LISTO - imagen al 100% sin modificar"
echo "============================================"
echo ""
echo "Ejecuta: flutter clean && flutter run"
