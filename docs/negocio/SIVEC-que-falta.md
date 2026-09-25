# SIVEC — Qué falta para el SIVEC completo

> Base: módulos ya dibujados en `docs/` y programas del Sistema Único de Salud (SUS, Ley 1152) del Ministerio de Salud y Deportes.
> Los nombres de programas y normas deben validarse con el Ministerio/SEDES antes de presentarlos como oficiales.

## 1. Lo que ya existe

| Estado | Módulos |
|---|---|
| **Funcionando (piloto C.S. San Luis)** | PAP/VPH, consulta con figuras (SOAP), colposcopia, ficha con línea de tiempo, documentos oficiales, informes |
| **Dibujado y aprobado** | Admin, agenda/fichas, recepción con huella, triaje/TV, consultorio, historia clínica, referencias “sin fila”, laboratorio, imagen, farmacia, enfermería, piso (internación), emergencias, hospital/quirófano, materno + historia perinatal, pediatría/RN, vacunas + carnet infantil, odontología, almacén, personal y guardias, epidemiología, telesalud, SIVEC en el celular, tablero del gestor |
| **Dibujado, por aprobar** | Programas (TB, Chagas, Zoonosis, Nutrición, Salud mental) |

## 2. Especialidades que faltan

Cada una es una **plantilla** dentro del mismo SIVEC (examen, escalas, procedimientos, formularios), no un sistema nuevo.

| Prioridad | Especialidad | Qué necesita |
|---|---|---|
| Alta | **Medicina interna / crónicos** | HTA, diabetes, enfermedad renal: metas, pie diabético, fondo de ojo, riesgo cardiovascular |
| Alta | **Cirugía general y traumatología** | nota preoperatoria, yesos y férulas, control de heridas, lista de espera quirúrgica |
| Alta | **Neonatología / UCIN y terapia intensiva** | hojas de UTI por hora, ventilación, balance, escalas (SOFA, Silverman) |
| Alta | **Banco de sangre / transfusión** | pedido, compatibilidad, trazabilidad bolsa → paciente, reacciones |
| Media | **Oftalmología** | agudeza visual, tamizaje de retinopatía diabética, recetas de lentes |
| Media | **Otorrino / fonoaudiología** | tamizaje auditivo neonatal, audiometría |
| Media | **Cardiología** | ECG adjunto, ecocardiograma, riesgo |
| Media | **Oncología** | registro de cáncer, estadificación, esquemas de quimioterapia |
| Media | **Nefrología / hemodiálisis** | sesiones, accesos, laboratorio mensual (programa renal) |
| Media | **Anatomía patológica** | biopsias y piezas quirúrgicas (hoy solo citología PAP) |
| Media | **Rehabilitación / fisioterapia** | sesiones, escalas funcionales |
| Media | **Psicología y psiquiatría** | historia completa, plan terapéutico (hoy solo tamizaje y seguimiento) |
| Baja | Dermatología, neurología, urología, geriatría | plantillas de examen y procedimientos |
| Baja | **Trabajo social** | ficha social, casos de violencia, abandono, apoyo |
| Baja | **Medicina tradicional y parteras** | registro intercultural, derivación de parteras (enfoque SAFCI) |

## 3. Programas del SUS que faltan

| Prioridad | Programa | Por qué importa |
|---|---|---|
| **Muy alta** | **Bono Juana Azurduy** | los controles prenatales y del niño ya están en SIVEC: el cumplimiento para el pago sale solo |
| **Muy alta** | **SAFCI: carpeta familiar y visitas domiciliarias** | adscripción de la población al centro; base de toda la búsqueda activa |
| **Muy alta** | **Adscripción / registro SUS del beneficiario** | quién pertenece a qué centro, para planificar y justificar recursos |
| Alta | **VIH, ITS y hepatitis virales** | prueba rápida, tratamiento antirretroviral, confidencialidad reforzada |
| Alta | **Enfermedades no transmisibles** | tamizaje de HTA/diabetes, seguimiento de crónicos |
| Alta | **Cáncer de mama** (y registro de otros cánceres) | se une al PAP/VPH: “salud de la mujer” completa |
| Alta | **Malaria y leishmaniasis** | notificación, tratamiento supervisado (regiones endémicas) |
| Alta | **Vigilancia de muerte materna y perinatal** | ficha, comité, análisis de cada caso |
| Media | **Salud sexual y reproductiva / planificación familiar** | ampliar el módulo “Métodos” a toda la población |
| Media | **Adolescentes (atención diferenciada)** | consulta confidencial, embarazo adolescente |
| Media | **Adulto mayor** | valoración geriátrica, fragilidad, complemento Carmelo |
| Media | **Discapacidad** | calificación y carnet (sistema de registro nacional) |
| Media | **Lepra** | tratamiento supervisado, contactos |
| Media | **Farmacovigilancia** | reacciones adversas a medicamentos (igual que ESAVI) |
| Media | **Salud escolar** | tamizajes en escuelas (ya hay brigadas para vacunas y odonto) |
| Baja | Donación y trasplante, salud ocupacional | registros específicos |

## 4. Lo transversal que falta (sin esto no se vende)

1. **Inicio de sesión real con roles, auditoría y cifrado** (Fase 0), y ley de protección de datos.
2. **Integraciones**: SEGIP (identidad), SNIS (informes), herramientas del Ministerio, laboratorios. Estándar **HL7 FHIR**.
3. **Funcionamiento sin internet** con sincronización (hoy dibujado, no programado).
4. **Prestaciones y costos del SUS**: cuánto produce y cuánto cuesta cada centro, para el municipio.
5. **Base de DEMO** con pacientes inventados para mostrar en vivo: nunca datos reales.
6. **Manuales y capacitación**: videos cortos por función.
7. **Informe mensual**: maqueta todavía por aprobar.

## 5. Orden sugerido

1. Fase 0: login y roles, base de demo, informe mensual.
2. Juana Azurduy, SAFCI/carpeta familiar, adscripción SUS: son los que más le importan al gobierno y usan datos que SIVEC ya tiene.
3. Crónicos (ENT) y cáncer de mama.
4. Especialidades de hospital (UTI/UCIN, banco de sangre, cirugía).
5. El resto como plantillas.
