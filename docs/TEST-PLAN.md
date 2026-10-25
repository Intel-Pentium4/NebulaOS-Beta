# Plan de pruebas — NebulaOS 0.1

Este documento es una lista de verificación; las pruebas no se consideran aprobadas hasta ejecutarlas y anotar los resultados reales.

## 1. Construcción
- [ ] Anotar versión de Debian anfitrión, `live-build --version` y fecha.
- [ ] Ejecutar `./scripts/build-iso.sh --minimal` y guardar todo el registro de construcción.
- [ ] Confirmar que la ISO se crea y que `sha256sum` coincide con el archivo de control.
- [ ] Repetir con el perfil Gaming y confirmar la presencia de Lutris, Wine, MangoHud y GameMode en el sistema Live.
- [ ] Registrar tamaño real de cada ISO.

## 2. Arranque
- [ ] VirtualBox: BIOS heredada y UEFI por separado.
- [ ] QEMU/KVM: arranque, red, audio, pantalla y apagado.
- [ ] PC físico con UEFI Secure Boot activado: documentar si funciona; no prometer compatibilidad hasta probarla.
- [ ] PC antiguo BIOS: verificar que el firmware puede arrancar el USB.
- [ ] Probar teclado, resolución, ratón, Wi-Fi y sonido.

## 3. Instalador
- [ ] Confirmar que se abre `Instalar NebulaOS`.
- [ ] Confirmar que Calamares muestra nombre y logo NebulaOS, no la identidad de Debian.
- [ ] Crear una VM con disco virtual descartable y completar instalación.
- [ ] Probar usuario, contraseña, idioma, teclado, zona horaria y gestor de arranque.
- [ ] Arrancar el sistema instalado y comprobar red, audio, actualización y permisos de sudo.
- [ ] Probar el caso UEFI/GPT y el caso BIOS heredada/MBR.
- [ ] No probar por primera vez en un disco con datos importantes.

## 4. Rendimiento
- [ ] Medir RAM al iniciar sesión sin abrir aplicaciones, después de 5 minutos y con Firefox abierto.
- [ ] Medir tiempo desde encendido hasta escritorio en SSD y HDD; hacer 3 arranques y publicar la mediana.
- [ ] Registrar CPU, GPU, controlador, kernel, resolución, firmware, modo de energía y temperatura ambiente.
- [ ] Probar carga de CPU/disco y reproducción de vídeo, registrando tirones y fallos.
- [ ] Probar el mismo juego, mapa/escena, resolución y ajustes en cada distribución de comparación.

## 5. Juegos y controladores
- [ ] Steam se instala después de habilitar i386 y abre sesión.
- [ ] Verificar `vulkaninfo --summary` en equipos compatibles y anotar cuándo no existe Vulkan.
- [ ] Probar MangoHud y GameMode con un juego de referencia.
- [ ] Probar un juego nativo de Linux, uno de Proton y un juego con antitrampas si se dispone de él; registrar resultados individuales.
- [ ] Probar Minecraft Java con una cuenta legítima, launcher mantenido y runtime Java apropiado.
- [ ] No afirmar que una GPU antigua soporta Proton/Vulkan sin comprobar su driver y extensiones.

## 6. Seguridad y mantenimiento
- [ ] `sudo apt update` y `sudo apt full-upgrade` tras instalar.
- [ ] Confirmar que el firewall puede habilitarse con `sudo apt install ufw` y que no hay servicios de red inesperados.
- [ ] Confirmar que no hay auto-login involuntario en el sistema instalado.
- [ ] Comprobar que los usuarios normales no tienen acceso de root sin autenticación.
- [ ] Confirmar que el script de lanzadores muestra una confirmación antes de instalar.
- [ ] Revisar los registros de Calamares y `journalctl -b` tras cualquier fallo.

## Tabla de resultados

| Prueba | Resultado | Equipo/VM | Fecha | Notas |
|---|---|---|---|---|
| Construcción ISO mínima | Pendiente | — | — | — |
| Construcción ISO Gaming | Pendiente | — | — | — |
| Arranque BIOS | Pendiente | — | — | — |
| Arranque UEFI | Pendiente | — | — | — |
| Instalación Calamares | Pendiente | — | — | — |
| RAM en reposo | Pendiente | — | — | Medir, no estimar |
| Tiempo de arranque | Pendiente | — | — | Mediana de 3 arranques |
