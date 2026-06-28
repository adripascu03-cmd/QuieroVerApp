# Quiero ver — cómo arrancar el proyecto

Esta app se generó en un entorno Windows, donde no hay Xcode disponible.
Todo el código está escrito con cuidado siguiendo la especificación, pero
**no ha podido compilarse ni ejecutarse todavía**. Estos son los pasos
para arrancarla en un Mac.

## Requisitos

- macOS con **Xcode 15.2 o superior** (el proyecto usa el formato clásico
  de `.pbxproj`: grupos `PBXGroup` y referencias de archivo explícitas.
  Si añades, quitas o renombras un archivo `.swift`, tienes que añadirlo
  también desde Xcode — "Add Files to..." o arrastrándolo al navegador —
  para que quede registrado en el proyecto).
- iOS 17+ como destino (usa SwiftData y Observation).
- Una API key gratuita de TMDb.

## 1. Obtener la API key de TMDb

1. Crea una cuenta en https://www.themoviedb.org/signup
2. Ve a Ajustes → API: https://www.themoviedb.org/settings/api
3. Solicita una "API key (v3 auth)" para uso personal/de desarrollador.
4. Copia el valor "API Key (v3 auth)".

## 2. Configurar la clave localmente

Abre `Secrets.xcconfig` (en la raíz del proyecto, junto al `.xcodeproj`) y
sustituye el placeholder:

```
TMDB_API_KEY = TU_API_KEY_AQUI
```

por tu clave real. Este archivo está en `.gitignore`: nunca se sube a un
repositorio. `Secrets.example.xcconfig` es la plantilla de referencia.

### 2.1 Importante: crea también `Secrets.plist` (obligatorio para compilar)

El proyecto ahora incluye un mecanismo de respaldo para leer la API key:
si por lo que sea no llega vía `Info.plist`, la app intenta leer
`QuieroVerApp/Resources/Secrets.plist` embebido en el bundle. **Ese
archivo está en `.gitignore` y NO se sube**, pero el proyecto Xcode SÍ
lo referencia como recurso del target — si no existe en tu copia local,
el build fallará con "Build input file cannot be found".

Antes de compilar:

1. Copia `QuieroVerApp/Resources/Secrets.example.plist` como
   `QuieroVerApp/Resources/Secrets.plist` (mismo directorio).
2. Rellena tu clave real en la clave `TMDB_API_KEY` de ese archivo (puede
   ser la misma clave que pusiste en `Secrets.xcconfig`, o dejarlo con el
   placeholder si el mecanismo de `Info.plist` ya te funciona — pero el
   archivo tiene que **existir** para que el build no falle).

## 3. Abrir y compilar

1. Doble clic en `QuieroVerApp.xcodeproj`.
2. Selecciona un simulador de iPhone (iOS 17+).
3. Run (⌘R).

Si Xcode pide firmar para ejecutar en un dispositivo físico, ve a la
pestaña "Signing & Capabilities" del target y selecciona tu equipo de
desarrollo (Team). No es necesario para el simulador.

## 4. Si algo no compila

No he podido verificar la compilación real (sin macOS/Xcode aquí). Si al
abrir el proyecto aparece algún error, pégamelo junto con el archivo y la
línea exacta y lo corrijo en la siguiente iteración.

## 5. Si la búsqueda sigue diciendo "Falta configurar la API key"

`TMDbConfig` imprime un diagnóstico en la consola de Xcode cada vez que
se pide la API key (solo en builds de Debug, nunca imprime la clave
completa). Con la consola de Xcode abierta (⇧⌘C), busca líneas como:

```
[TMDbConfig] Info.plist["TMDBAPIKey"]: presente (32 caracteres)
[TMDbConfig] Info.plist["TMDB_API_KEY"]: ausente
[TMDbConfig] Secrets.plist["TMDB_API_KEY"]: presente (32 caracteres)
```

Si las tres líneas dicen "ausente" o "sigue siendo el placeholder",
pégame exactamente esas tres líneas y seguimos depurando desde ahí.

## Decisiones y limitaciones conocidas del MVP1

- **Transición poster → detalle**: se usa la transición nativa de
  `NavigationStack` (push lateral fluido) más una ligera compresión al
  tocar el poster, en vez de un `matchedGeometryEffect` real que "crezca"
  el poster a través de la navegación. SwiftUI no soporta de forma fiable
  `matchedGeometryEffect` a través del límite de un `navigationDestination`
  sin sustituir `NavigationStack` por un router manual basado en `ZStack`.
  Tanto `CLAUDE.md` como `UX_UI_SPEC.md` califican esta animación como
  "si es viable"; se ha priorizado una navegación nativa robusta y
  predecible (con back-swipe, accesibilidad, etc. gratis) sobre una
  transición a medida que no podía probarse en este entorno.
- **Agrupación por género / dirección-creación** (la vista tipo "carrusel
  por persona" descrita en `CLAUDE.md` punto 11) no está implementada.
  El filtro por **Tipo** y el orden por **Recientes** / **Impacto** sí
  funcionan, que es lo mínimo exigido por el MVP1; el resto se marca
  explícitamente como incremental en la propia especificación.
- Sin tests automatizados (no se pidieron en la especificación).
- Sin App Icon real (solo el slot vacío en `Assets.xcassets`); puedes
  añadir una imagen 1024×1024 en `AppIcon.appiconset` cuando quieras.
