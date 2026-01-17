# Script para ejecutar la app Flutter
$env:Path = "C:\Users\xcia\src\flutter_windows_3.38.7-stable\flutter\bin;" + $env:Path

Write-Host "Ejecutando la app en Chrome..." -ForegroundColor Green
flutter run -d chrome --web-port=8080
