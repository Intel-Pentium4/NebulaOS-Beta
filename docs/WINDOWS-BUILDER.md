# Compilar NebulaOS desde Windows sin instalar Debian

Este proyecto puede compilarse en servidores de GitHub Actions. Tu PC con Windows solo necesita un navegador e Internet; no se instala Debian, WSL, Docker ni un compilador local.

## Primera vez: preparar el repositorio

1. Inicia sesión en GitHub o crea una cuenta en https://github.com/.
2. Crea un repositorio nuevo llamado `NebulaOS`. Para el camino gratuito más sencillo, puedes hacerlo público; el proyecto no necesita secretos ni credenciales. Si lo haces privado, revisa los límites de almacenamiento de artefactos de tu plan.
3. Descomprime `NebulaOS-0.1.zip` en Windows.
4. Sube **el contenido de la carpeta `NebulaOS-0.1`** a la raíz del repositorio. Importante: `.github/workflows/build-iso.yml` debe quedar exactamente en esa ruta desde la raíz. No subas solamente el ZIP.
5. Espera a que GitHub termine de guardar los archivos. La rama predeterminada debe llamarse `main` para que el archivo BAT pueda usar el modo automático.

## Método A: el más sencillo, con el navegador

1. Abre `COMPILAR_NEBULAOS.bat`.
2. Escribe el repositorio como `usuario/NebulaOS` cuando lo pida.
3. Elige `1` (Gaming) o `2` (Minimal). Si no tienes GitHub CLI, se abrirá el constructor web.
4. En GitHub, entra en **Actions** → **Compilar ISO de NebulaOS** → **Run workflow**. Elige el perfil y confirma con **Run workflow**.
5. Abre la ejecución. Cuando termine correctamente, descarga `NebulaOS-gaming-ISO` o `NebulaOS-minimal-ISO` desde **Artifacts**.
6. Extrae el archivo descargado. Dentro estarán `binary.iso` y `binary.iso.sha256`.

## Método B: automatizar la solicitud y descarga

Si ya tienes instalado [GitHub CLI](https://cli.github.com/) y has iniciado sesión con `gh auth login`, el archivo `COMPILAR_NEBULAOS.bat` puede solicitar la compilación, esperar a que termine y descargar el artefacto en `SALIDA_NEBULAOS`.

El modo automático asume que la rama predeterminada se llama `main`. No introduzcas contraseñas ni tokens en el script; el inicio de sesión se realiza mediante la herramienta oficial de GitHub.

## Qué hace el servidor

El flujo de GitHub Actions usa un contenedor desechable basado en Debian Trixie, instala las herramientas oficiales de `live-build`, crea la ISO híbrida amd64, calcula SHA-256 y publica la ISO como un artefacto temporal de un día. La compilación necesita Internet y puede tardar bastante porque descarga paquetes de Debian.

## Precauciones y límites

- El flujo aún debe ejecutarse para demostrar que construye la ISO correctamente. Añadir un compilador no equivale a haber validado el resultado.
- Una ejecución verde demuestra que se generó la ISO y que coincide con su suma SHA-256; no demuestra por sí sola que arranque en todos los BIOS/UEFI o que Calamares instale correctamente. Sigue `TEST-PLAN.md`.
- No grabes ni instales el sistema en un disco con datos importantes sin probar primero la ISO en una máquina virtual.
- Si GitHub muestra un error, abre la ejecución fallida y guarda el texto del paso rojo para poder corregirlo.
