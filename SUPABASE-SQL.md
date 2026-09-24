# SIVEC-PAP — Cambios en Supabase

Se hacen una sola vez, en **Supabase → SQL Editor → New query**: pegar el bloque y apretar **Run**.

---

## Paso 1 — Ubicaciones compartidas del mapa (recomendado, sin riesgo)

Hoy cada computadora guarda las ubicaciones del mapa solo en su navegador. Con estas columnas,
lo que una persona marca o corrige en el mapa lo ven todas, y el mapa no vuelve a buscar las
direcciones en cada computadora.

```sql
alter table pacientes
  add column if not exists lat double precision,
  add column if not exists lng double precision,
  add column if not exists geo_manual boolean default false;
```

- `lat` / `lng`: posición de la casa.
- `geo_manual`: `true` cuando alguien la marcó o arrastró a mano (el botón "Volver a localizar" nunca la pisa).

No hace falta nada más: el sistema detecta las columnas solo. Si no se crean, todo sigue funcionando como antes.

---

## Paso 2 — Genotipo del VPH (recomendado, sin riesgo)

Agrega el campo "Genotipo VPH" (16, 18, otros de alto riesgo) en Editar paciente cuando el VPH es positivo.

```sql
alter table pacientes add column if not exists vph_genotipo text;
```

Sin esta columna el campo aparece deshabilitado y todo lo demás funciona igual.

---

## Paso 4 — Seguimiento por etapas y envíos al laboratorio (recomendado, sin riesgo)

- `seg_etapa` / `seg_fechas`: en PAP+ y VPH+, cada etapa del seguimiento (notificada, colposcopia, tratamiento, alta) se registra con un toque y su fecha.
- `fecha_envio` / `lote_envio`: en Balance, qué muestras se enviaron al laboratorio y cuándo (sirve para medir cuánto tarda el resultado).

```sql
alter table pacientes add column if not exists seg_etapa text;
alter table pacientes add column if not exists seg_fechas jsonb;
alter table pacientes add column if not exists fecha_envio date;
alter table pacientes add column if not exists lote_envio text;
```

---

## Paso 5 — Consulta (SOAP) aparte de la colposcopia (recomendado, sin riesgo)

Crea la tabla `consultas` (nota S-O-A-P de cada atención). Al imprimir, la Historia clínica junta la consulta + la colposcopia.

```sql
create table if not exists consultas (
  id bigint generated always as identity primary key,
  paciente_id text not null,
  fecha date not null default current_date,
  doctora text,
  subjetivo text,
  objetivo_oce text,
  objetivo_leucorrea text,
  objetivo_color text,
  objetivo text,
  analisis text,
  observaciones text,
  plan jsonb,
  plan_texto text,
  derivacion text,
  created_at timestamptz not null default now()
);
create index if not exists consultas_paciente_idx on consultas (paciente_id);
alter table consultas enable row level security;
create policy "consultas acceso del sistema" on consultas for all to anon, authenticated using (true) with check (true);
grant select, insert, update, delete on consultas to anon, authenticated;
```

---

## Paso 3 — Proteger los datos de las pacientes (IMPORTANTE)

Hoy cualquiera que tenga la URL y la clave *anon* de Supabase puede leer todos los datos.
El login del sistema solo esconde la pantalla; la protección real son las reglas **RLS**.

### 3.1 Crear las cuentas
Supabase → **Authentication → Users → Add user → Create new user**: un correo y contraseña
para cada doctora/persona que usa el sistema (marcar *Auto Confirm User*).

### 3.2 Probar el login
En cada computadora: ⚙ Configuración → **Exigir inicio de sesión** → entrar con el correo y
la contraseña creados. Verificar que todo carga bien.

### 3.3 Activar RLS (recién cuando todas puedan entrar)

```sql
alter table pacientes enable row level security;
alter table colposcopias enable row level security;

create policy "Solo usuarias con sesión - pacientes"
  on pacientes for all to authenticated using (true) with check (true);

create policy "Solo usuarias con sesión - colposcopias"
  on colposcopias for all to authenticated using (true) with check (true);

-- Si ya ejecutaste el Paso 5 (consultas):
drop policy if exists "consultas acceso del sistema" on consultas;
create policy "Solo usuarias con sesión - consultas"
  on consultas for all to authenticated using (true) with check (true);
```

Desde ese momento, sin iniciar sesión el sistema **no muestra ningún dato**
(por eso hay que activar "Exigir inicio de sesión" en todas las computadoras antes).

### Deshacer (si algo sale mal)

```sql
drop policy if exists "Solo usuarias con sesión - pacientes" on pacientes;
drop policy if exists "Solo usuarias con sesión - colposcopias" on colposcopias;
alter table pacientes disable row level security;
alter table colposcopias disable row level security;
```
