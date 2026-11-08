# Monody

Arquitectura modular para Roblox con interfaz Liquid Glass, motor dinámico de temas, wallpapers en alta definición y compatibilidad móvil completa.

## Características

- **UI Framework**: Diseño Liquid Glass compacto (440x300, escalado dinámico con `UIScale` para móviles y PC).
- **Sistema de Licencia Aurora X**: Integración oficial con soporte para claves permanentes y obtención por Linkvertise (`Publisher ID: 9980602`).
- **Pantalla de Carga Minimalista**: Loader borderless con barra de progreso estilizada en plata y logo personalizado.
- **Iconografía**: Motor de iconos Lucide integrado con fallbacks oficiales.
- **Galería de Fondos**: 24 fondos y wallpapers seleccionables en tiempo real con descarga y caché offline.
- **Pestañas**:
  - `Home`: Estadísticas de jugador, accesos directos y estado general.
  - `Combat`: Aimbot (jugadores y NPCs), Silent Aim, FOV y Tracers con su lógica original.
  - `PvP`: Fast Attack, Dragon Gun, Camlock, Sanguine Boost y widgets flotantes.
  - `Macro`: Motor de macros y secuencias automáticas.
  - `Mobility`: Movement Engine y ajustes de movilidad.
  - `Soru`: Soru Controller con bypass de cooldown.
  - `Esp`: Visuales de jugadores y entidades.
  - `Misc`: Ajustes de cliente y optimizador de FPS.
  - `Themes`: 10 temas de color personalizables, selector de fuentes y fondos de pantalla.
  - `Settings`: Perfiles de configuración y restablecimiento a valores de fábrica.

## Ejecución

### Opción 1: Con Clave Permanente
```lua
script_key = "TU_CLAVE_PERMANENTE"
loadstring(game:HttpGet("https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua"))()
```

### Opción 2: Estándar (Verificación en el Juego)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/rivals-hash/idk/main/main.lua"))()
```
*(Se abrirá la ventana para copiar el enlace de Linkvertise y verificar la clave).*
