# NebulaOS 0.1 — Gaming Edition (prototipo construible)

NebulaOS es un prototipo de distribución GNU/Linux x86-64 basado en Debian 13 “Trixie”, con escritorio LXQt, configuración visual propia y herramientas opcionales para jugar. Este repositorio incluye un flujo de GitHub Actions para generar una ISO desde Windows sin instalar Debian localmente. La ISO todavía debe compilarse y probarse: no se presenta como un sistema ya validado.

## Decisiones técnicas

- **Base:** Debian 13 “Trixie” estable. Usa repositorios Debian y actualizaciones de seguridad; evita basarse en imágenes modificadas de procedencia desconocida.
- **Escritorio:** LXQt + Openbox + LightDM. Es más ligero que un escritorio GNOME completo y permite una interfaz convencional. El tema Nebula es una primera identidad visual, no una suite de escritorio desarrollada desde cero.
- **Formato:** ISO híbrida amd64 para DVD/USB, con arranque Live y posibilidad de instalación mediante Calamares. La configuración de arranque BIOS/UEFI depende de las herramientas de `live-build` instaladas en el host y deberá validarse en hardware real.
- **Paquetes:** repositorios Debian `main contrib non-free non-free-firmware`. Esto permite solicitar firmware redistribuible y componentes como Lutris; el firmware/controlador adecuado varía según el dispositivo.
- **Juegos:** perfil Gaming añade Lutris, Wine, MangoHud, GameMode, herramientas Vulkan y Flatpak. Steam, Heroic y Prism se ofrecen mediante un script posterior para habilitar multiarch y descargar los clientes de sus fuentes correspondientes.
- **Seguridad:** no desactiva servicios críticos, no deshabilita el firewall, no elimina actualizaciones y no fuerza controladores NVIDIA. No instala automáticamente controladores propietarios que podrían dejar sin interfaz gráfica a GPUs antiguas.

## Estructura

```text
NebulaOS-0.1/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── INICIO_COMPILAR_WINDOWS.txt
├── COMPILAR_NEBULAOS.bat
├── .github/workflows/build-iso.yml
├── config/
│   ├── package-lists/
│   ├── includes.chroot/
│   └── hooks/normal/
├── scripts/
│   ├── install-build-deps.sh
│   ├── build-iso.sh
│   ├── build-iso-ci.sh
│   ├── compilar-nebulaos.ps1
│   ├── verify-iso.sh
│   └── make-usb-linux.sh
└── docs/
    ├── WINDOWS-BUILDER.md
    ├── TEST-PLAN.md
    └── HARDWARE-NOTES.md
```

## Compilar desde Windows sin instalar Debian

La opción recomendada para usuarios de Windows es el constructor remoto de GitHub Actions; la compilación se hace en un servidor temporal, no en este PC. Consulta `docs/WINDOWS-BUILDER.md`. Necesitas conexión a Internet y una cuenta de GitHub.

1. Crea un repositorio en GitHub.
2. Sube el **contenido** de esta carpeta a la raíz del repositorio, incluida la carpeta oculta `.github`.
3. Ejecuta `COMPILAR_NEBULAOS.bat` y sigue sus instrucciones, o usa **Actions → Compilar ISO de NebulaOS → Run workflow** en GitHub.
4. Descarga el artefacto que acaba con `-ISO` cuando la ejecución termine.

El constructor genera `binary.iso` y `binary.iso.sha256`. Una compilación correcta no sustituye las pruebas de arranque e instalación.

## Construir localmente desde Debian

Construye desde una instalación o máquina virtual **Debian 13 amd64** actualizada. Recomendación para el equipo que construye: 4 núcleos, 8 GB de RAM o más y 40 GB libres. La construcción descarga paquetes, crea un sistema raíz con `debootstrap` y necesita permisos de administración. En un PC de 8 GB puede funcionar, pero tardará más y conviene cerrar programas pesados.

1. Extrae esta carpeta en Debian 13.
2. Abre una terminal dentro de `NebulaOS-0.1`.
3. Instala las herramientas de construcción:

   ```bash
   chmod +x scripts/*.sh
   ./scripts/install-build-deps.sh
   ```

4. Construye la edición Gaming (por defecto):

   ```bash
   ./scripts/build-iso.sh
   ```

   Para una ISO más pequeña, sin el conjunto adicional de juegos:

   ```bash
   ./scripts/build-iso.sh --minimal
   ```

5. El archivo ISO se generará en `binary.iso` en esta carpeta. Verifica su suma:

   ```bash
   ./scripts/verify-iso.sh binary.iso
   ```

El script limpia el árbol de construcción anterior antes de iniciar una compilación reproducible desde cero, pero **no elimina archivos fuera de la carpeta del proyecto**. No lances `make-usb-linux.sh` hasta confirmar con `lsblk` cuál es la memoria USB: seleccionar mal el dispositivo sobrescribe otro disco.

## Crear un USB desde Linux

Identifica el dispositivo USB con `lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS`. Después desmonta sus particiones y usa el script indicando explícitamente el dispositivo completo, por ejemplo `/dev/sdX` o `/dev/nvme1n1` (sin número de partición):

```bash
sudo ./scripts/make-usb-linux.sh binary.iso /dev/sdX
```

**ATENCIÓN:** esto destruye el contenido del dispositivo elegido. No copies el ejemplo literal sin comprobar la salida de `lsblk`. En Windows puedes usar Rufus o balenaEtcher, seleccionando `binary.iso`; verifica el archivo ISO antes de grabarlo.

## Primer arranque e instalación

- Primero usa una máquina virtual (QEMU/KVM o VirtualBox) con 2 CPU, 3–4 GB RAM, 25 GB de disco virtual y red habilitada.
- Prueba el modo Live antes de tocar un disco físico.
- El instalador Calamares permite elegir particiones; revisa dos veces el disco de destino. La personalización de marca y el funcionamiento del instalador deben validarse con el plan de pruebas de `docs/TEST-PLAN.md`.
- Si el instalador falla o no muestra “NebulaOS”, no continúes instalando: guarda el registro, arranca en Live y corrige la configuración.

## Perfil Gaming y lanzadores

En una instalación NebulaOS ya arrancada, abre una terminal y ejecuta:

```bash
nebula-install-game-launchers
```

Este comando solicita privilegios de administrador, habilita la arquitectura i386 para bibliotecas de 32 bits, instala Steam/Lutris/Wine y herramientas gráficas, y propone los clientes Heroic y Prism Launcher desde Flathub. Se necesita conexión a Internet. Revisa las preguntas de los instaladores y las licencias. Prism Launcher es una opción comunitaria para gestionar Minecraft Java; usa una cuenta legítima y respeta las condiciones del juego.

La ISO no instala automáticamente un controlador NVIDIA propietario. En tarjetas antiguas, algunas funciones modernas de Vulkan/Proton pueden estar ausentes. No hay garantía de que todos los juegos funcionen: los sistemas antitrampas, DRM y algunos launchers pueden impedirlo.

## Estado del proyecto

**Preparado:** estructura de `live-build`, listas de paquetes, recursos de marca originales, accesos directos, scripts de construcción y flujo de GitHub Actions. Se ha hecho una validación sintáctica inicial de los scripts Bash y una revisión estática del flujo; la compilación remota aún debe ejecutarse.

**Pendiente de demostrar:** compilar la ISO completa en Debian 13, comprobar disponibilidad real de cada paquete en los repositorios habilitados, arrancar en BIOS y UEFI, confirmar Calamares, instalar en disco virtual, medir RAM/arranque y probar el escritorio/controladores en equipos físicos. No se afirma que estas pruebas ya hayan pasado.

## Licencias y marcas

Los scripts y recursos originales de este prototipo se distribuyen bajo GPL-3.0-or-later, salvo que un archivo indique otra licencia. Debian, LXQt, Calamares, Steam, Wine, Lutris, Heroic, Prism Launcher y Minecraft son proyectos o marcas de sus respectivos titulares; NebulaOS no está afiliado con ellos.
