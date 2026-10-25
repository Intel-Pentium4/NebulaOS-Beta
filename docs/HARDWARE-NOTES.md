# Requisitos y límites de compatibilidad

## Objetivos iniciales (no son mediciones)

| Recurso | Mínimo de prueba propuesto | Recomendado |
|---|---|---|
| CPU | x86-64 con soporte SSE2 y capacidad de arrancar Debian 13 | Intel/AMD x86-64 reciente |
| RAM | 2 GB solo para probar el escritorio, sin garantía de fluidez | 4 GB escritorio; 8 GB para jugar/construir |
| Disco instalado | 12 GB libres como mínimo para experimentar | 25 GB o más; los juegos requieren mucho más |
| USB de instalación | 8 GB (ISO real por medir; usar 16 GB para margen) | 16 GB o más |
| Gráficos | GPU compatible con el kernel y el servidor gráfico; la aceleración puede ser limitada | Intel/AMD con Mesa actual o NVIDIA compatible con un controlador adecuado |
| Red | Ethernet o Wi-Fi reconocido por el kernel/firmware | Conexión estable para juegos y descarga de runtime |

## Objetivos de tamaño y rendimiento

Son metas para medir en la primera compilación, no resultados publicados:
- ISO minimal: objetivo aproximado 2.5–3.5 GB; ISO Gaming, 3–4.5 GB. Los paquetes disponibles y compresión pueden cambiarlo.
- RAM tras iniciar sesión, sin navegador: objetivo 700–1000 MiB. Depende de kernel, firmware, VM, servicios, resolución y aplicaciones.
- Arranque hasta escritorio: objetivo inferior a 30 s con SSD y equipo compatible; no se garantiza en BIOS/ordenadores antiguos.
- Espacio ocupado instalado: objetivo inicial inferior a 10 GB sin juegos, sujeto a lo que instale Calamares y a los datos del usuario.

Estos rangos son estimaciones de ingeniería. Solo una ISO construida e instalada permite determinar resultados reales.

## PCs antiguos

- **Intel HD 3000 / Sandy Bridge:** la pila gráfica de Linux y Mesa puede proporcionar escritorio acelerado básico, pero no se debe esperar soporte moderno completo de Vulkan. Muchos juegos de Windows con Proton pueden fallar o rendir peor por falta de extensiones gráficas.
- **NVIDIA GeForce GT 520M / Fermi:** GPU antigua; no instales a ciegas el controlador propietario actual. Nouveau puede permitir escritorio, pero Vulkan/Proton y el rendimiento 3D pueden estar muy limitados. Hace falta probar el dispositivo exacto.
- **Wi-Fi antiguo:** puede requerir firmware adicional; la velocidad y latencia dependen del adaptador y punto de acceso. La distribución no puede eliminar limitaciones físicas de 2.4 GHz.
- **BIOS/UEFI:** la ISO híbrida pretende soportar el arranque común BIOS y UEFI, pero debe verificarse en equipos reales. Secure Boot es un caso separado que hay que probar.
- **Antitrampas/DRM:** algunos juegos no funcionan aunque Steam y Proton se instalen correctamente.
