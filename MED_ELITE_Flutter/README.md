# MED ELITE · Prototipo Flutter v0.1

Biblioteca de estudios de Medicina (Android/iOS) con catálogo basado en el documento del autor «LISTADO DEFINITIVO DE TEMAS FINALIZADO 2026».

## Qué está implementado

- **44 asignaturas, 1.337 temas**: contenidos y numeración importados del listado original, con colores base por asignatura. **Anatomía y Neuroanatomía tiene 51 temas**. El primer tema de generalidades es blanco; las rotaciones siguientes son rojo, amarillo, azul, naranja, verde, morado y lila.
- **Tema claro y oscuro**, configurable y persistido localmente.
- **Biblioteca de recursos**, agrupada por asignatura → tema → categoría: libros, resúmenes, bancos de preguntas, diapositivas, exámenes, videoclases, flashcards y extras.
- **Visor dentro de la app**: páginas web/PDF/Google Drive cuando el sitio y los permisos permiten vista previa; video directo compatible; YouTube mediante reproductor oficial integrado para contenido gratuito que admita inserción.
- **Administrador local (demostración)** para registrar enlaces HTTPS individuales de Drive, páginas, videos, título, subtítulo y encabezados por líneas. Los recursos nuevos se guardan en el propio dispositivo.
- **Buscador interno transversal**: consulta el título de cada tema (1.337), títulos y subtítulos de materiales, y encabezados/capítulos de libros registrados. Reconoce acentos y palabras combinadas. Permite filtrar por asignatura y tipo. **No busca en el texto del PDF** ni asume contenido inexistente en Drive.
- **Buscador de artículos científicos real**: consulta Europe PMC a través de su API REST; filtros de asignatura, tema, idioma, intervalo de fechas. La búsqueda requiere Internet. Es una fuente de cobertura biomédica amplia, *no todas las revistas del mundo*.
- **Flashcards** de ejemplo, navegación y centro de módulos (módulos futuros marcados expresamente).
- **Membresías simuladas** (prueba 7 días, básico, intermedio, completo, vitalicio). No existen cobros, cuentas de Google ni protección de acceso real en esta versión.

## Instalación y ejecución

Se necesita **Flutter SDK estable** compatible con Dart >=3.10, Android SDK, y un emulador o dispositivo Android. El repositorio contiene el código Flutter; los directorios nativos generados `android/` e `ios/` deben crearse con Flutter:

```bash
# Situado en la carpeta del proyecto
flutter create --platforms=android,ios --org com.medelite .
python3 tools/patch_android.py
flutter pub get
flutter test
flutter run
```

### Generar una APK instalable de demostración

```bash
flutter build apk --debug
# Archivo resultante:
# build/app/outputs/flutter-apk/app-debug.apk
```

Esta es una APK de **depuración**, no una compilación firmada y preparada para su publicación. Para generar una versión para distribuir en tiendas se requieren firma, configuración de publicación y pruebas de dispositivos reales. En iOS hay que compilar con macOS/Xcode. El flujo de GitHub Actions incluido permite compilar la APK de prueba en la nube sin un SDK local si subes el proyecto a un repositorio bajo tu control.

## Ejemplo: buscar «Shock»

1. Abrir la pestaña **Buscar**.
2. Introducir **shock** y dejar seleccionada **Todas las asignaturas**.
3. Encontrará, entre otros, el tema 466 (Fisiopatología), 794 (Infectología) y 989 (Anestesiología) del catálogo original.
4. Para localizar `Shock cardiogénico` en un libro de Cardiología, registrar el libro desde **Perfil → Administración local**, asignarle la materia y el tema, y agregar `Shock cardiogénico` como una línea del campo **Títulos y subtítulos de capítulos**. Entonces aparecerá al buscar «shock».

**Relevancia:** el buscador compara solo metadatos explícitos. Un archivo PDF de Drive no se abre, descarga, convierte ni rastrea automáticamente para crear su índice. Los capítulos pueden importarse de índices autorizados a través de `tools/import_resources_csv.py`, extraerse de marcadores PDF con `tools/extract_pdf_outline.py` o ingresarse manualmente en Administración.

### Extraer automáticamente títulos de capítulos de un PDF con marcadores

Si dispones de una copia local autorizada de un PDF que incorpora marcadores/índice en el lector, el script siguiente extrae **exclusivamente los títulos del índice** (nunca el texto completo). El recurso JSON resultante se puede agregar al catálogo de recursos de la app. Si el PDF no trae marcadores, se requiere un índice facilitado por el usuario/editor.

```bash
python3 -m pip install pymupdf
python3 tools/extract_pdf_outline.py \
  --pdf /ruta/al/libro_autorizado.pdf \
  --subject-id 18 --topic-id 711 \
  --title "Libro de Cardiología" \
  --url "https://drive.google.com/file/d/TU_ARCHIVO/view" \
  --output /tmp/capitulos_cardiologia.json
```

Este ejemplo muestra el formato del comando, **no una URL real**; reemplaza `TU_ARCHIVO` por un identificador válido que tengas permiso de compartir. Los libros asignados a varias asignaturas deben registrar una entrada por asignatura en este prototipo.

### Registro de archivos

Los enlaces a archivos propios de Google Drive deben tener permisos que permitan su lectura. Un enlace compartido **no garantiza** privacidad ni control de suscripción, y es posible que ciertos archivos de Drive requieran abrirse en una pestaña externa si el visor integrado no obtiene autorización. Para el sistema comercial se necesitará un backend con cuentas y verificación de acceso por archivo.

`assets/data/resources.json` contiene algunos enlaces públicos y legalmente accesibles para explorar la navegación; **no contiene archivos privados del usuario** porque aún no se han proporcionado vínculos concretos. Los archivos originales no se incorporan a la APK.

### Importación masiva opcional de capítulos catalogados

Formato CSV: columnas `id,subjectId,topicId,title,subtitle,headings,url,category,kind,access,source`. El campo `headings` incluye uno o más títulos separados por `|`. El script valida las URLs HTTPS y genera JSON para integrar a `assets/data/resources.json` o al futuro servidor. No descarga contenido ni realiza OCR.

```bash
python3 tools/import_resources_csv.py tools/resources_example.csv /tmp/med_elite_resources.json
```

> El archivo de ejemplo contiene solo la estructura y ninguna URL ficticia que aparente ser material del usuario.

## Arquitectura

```text
lib/main.dart                            Navegación, pantallas y visores
lib/models.dart                          Modelos y colores
lib/state.dart                           Estado y almacenamiento local
lib/screens/internal_search_screen.dart  Búsqueda interna
lib/services/internal_search_service.dart Índice de títulos, subtítulos y capítulos
lib/screens/science_screen.dart          UI de literatura científica
lib/services/scientific_service.dart     Cliente de Europe PMC
assets/data/subjects.json                44 asignaturas y colores
assets/data/topics.json                  1.337 temas
assets/data/resources.json               Recursos públicos iniciales
assets/data/flashcards.json              Tarjetas de demostración
test/internal_search_test.dart            Pruebas del buscador y catálogo
```

## Antes de comercializar

1. **Auth y permisos**: Firebase Auth/Google Sign-In, roles de administrador, backend y reglas de acceso protegidas. `SharedPreferences` no sirve como control de membresías.
2. **Pagos**: implementar Google Play Billing / Apple In-App Purchase y verificación segura de compras; los botones actuales son simulaciones.
3. **Drive**: conectar cuentas y API de Google Drive de manera autorizada o migrar contenidos de pago a almacenamiento privado con URL temporal emitida por servidor. Revisar licencias y privacidad.
4. **Videos**: YouTube integrado **solo para videos gratuitos no restringidos** y siempre de acuerdo con las políticas del reproductor; para cursos de pago usar alojamiento compatible con membresías y URL/sesiones protegidas.
5. **Artículos**: Europe PMC no indexa toda la literatura mundial. Complementar opcionalmente con fuentes como PubMed, Crossref u otros proveedores cumpliendo sus términos y límites de uso. Si crece el tráfico, utilizar un proxy con caché, control de cuota y paginación.
6. **Seguridad**: validación de enlaces, gestión de datos personales, pruebas automatizadas y protección de la configuración de administrador.

## Estado de entrega

Se entrega **código fuente**. Este entorno de generación no dispone del compilador Flutter/Android SDK, por lo que **la compilación APK y la ejecución de `flutter test` no han podido verificarse aquí**. Usa los comandos indicados o el flujo GitHub Actions y reporta cualquier error de compilación para corregirlo.

### Referencias técnicas

- Flutter y paquetes: https://flutter.dev/ · https://pub.dev/packages/webview_flutter · https://pub.dev/packages/youtube_player_iframe · https://pub.dev/packages/shared_preferences
- Europe PMC API REST: https://www.ebi.ac.uk/europepmc/webservices/rest/search
- Políticas de YouTube API: https://developers.google.com/youtube/terms/api-services-terms-of-service
