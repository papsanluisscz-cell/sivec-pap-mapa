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

## Paso 6 — Consulta con figuras, especialidad y reloj del cuello (recomendado, sin riesgo)

- `consultas.detalle`: lo marcado con toques (síntomas, gotas, colores, tratamientos) para volver a abrir la consulta tal cual.
- `consultas.especialidad` / `codigo_esp`: Medicina general (17576016) o Ginecología (17576012); el código sale en el D1.
- `colposcopias.cuello_mapa`: las lesiones marcadas en el reloj del cuello.

```sql
alter table consultas add column if not exists detalle jsonb;
alter table consultas add column if not exists especialidad text;
alter table consultas add column if not exists codigo_esp text;
alter table colposcopias add column if not exists cuello_mapa jsonb;
```

---

## Paso 7 — Reparar la tabla de consultas (si al guardar sale "Could not find the '…' column of 'consultas'")

Pasa cuando la tabla `consultas` ya existía de una versión anterior: el Paso 5 no la vuelve a crear, entonces le faltan columnas.
Este SQL agrega todas las que faltan (las que ya existen no se tocan) y le pide a Supabase que vuelva a leer la estructura.

```sql
alter table consultas add column if not exists paciente_id text;
alter table consultas add column if not exists fecha date default current_date;
alter table consultas add column if not exists doctora text;
alter table consultas add column if not exists subjetivo text;
alter table consultas add column if not exists objetivo_oce text;
alter table consultas add column if not exists objetivo_leucorrea text;
alter table consultas add column if not exists objetivo_color text;
alter table consultas add column if not exists objetivo text;
alter table consultas add column if not exists analisis text;
alter table consultas add column if not exists observaciones text;
alter table consultas add column if not exists plan jsonb;
alter table consultas add column if not exists plan_texto text;
alter table consultas add column if not exists derivacion text;
alter table consultas add column if not exists created_at timestamptz default now();
alter table consultas add column if not exists detalle jsonb;
alter table consultas add column if not exists especialidad text;
alter table consultas add column if not exists codigo_esp text;
notify pgrst, 'reload schema';
```

---

## Paso 8 — Redes, centros y usuarios con rol (SIVEC PAP para toda la red)

Crea las **redes**, los **establecimientos** y el **perfil** de cada usuario (rol + centro o red).
Todas las pacientes que ya existen quedan en **C.S. San Luis (Red Centro)** y todas las cuentas que ya existen quedan como personal de San Luis.

**Antes:** cada persona que usa el sistema tiene que tener su cuenta (Paso 3.1). Desde este paso **el inicio de sesión es obligatorio**: sin cuenta no se entra.
**Cambiá `TU_CORREO@gmail.com`** (casi al final) por tu correo: esa cuenta queda como administradora (sigue viendo sus pacientes de San Luis y además ve el botón **Admin**).

Roles:
- **Centro de salud**: ve y registra solo las pacientes de su centro.
- **Gestor de red**: ve todos los centros de su red (con selector "Todos / centro X"), no edita.
- **Oncológico / laboratorio** y **Colposcopia 2º nivel**: su portal (se programa en los próximos pasos).
- **Administrador**: crea redes, establecimientos y usuarios; **no ve datos clínicos**. Una persona de centro puede además ser administradora (casilla "Administra").

```sql
-- 1) Redes, establecimientos y perfiles
create table if not exists redes (
  id bigint generated always as identity primary key,
  nombre text not null unique,
  municipio text,
  created_at timestamptz not null default now()
);
create table if not exists centros (
  id bigint generated always as identity primary key,
  nombre text not null unique,
  red_id bigint references redes(id),
  tipo text not null default 'primer_nivel',  -- primer_nivel · segundo_nivel · oncologico
  codigo text,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists perfiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  correo text,
  nombre text,
  rol text not null default 'centro',          -- centro · gestor · oncologico · colposcopia · admin
  es_admin boolean not null default false,     -- además de su rol, administra redes/centros/usuarios
  centro_id bigint references centros(id),
  red_id bigint references redes(id),
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

-- 2) Quién soy (las usa el sistema y las reglas de seguridad)
create or replace function sivec_rol() returns text language sql stable security definer set search_path = public as $$
  select rol from perfiles where user_id = auth.uid() and activo limit 1 $$;
create or replace function sivec_es_admin() returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select rol = 'admin' or es_admin from perfiles where user_id = auth.uid() and activo limit 1), false) $$;
create or replace function sivec_centro() returns bigint language sql stable security definer set search_path = public as $$
  select centro_id from perfiles where user_id = auth.uid() and activo limit 1 $$;
create or replace function sivec_red() returns bigint language sql stable security definer set search_path = public as $$
  select coalesce(p.red_id, c.red_id) from perfiles p left join centros c on c.id = p.centro_id
  where p.user_id = auth.uid() and p.activo limit 1 $$;
-- Ver: el centro ve lo suyo; el gestor ve todos los centros de su red. El administrador puro no ve datos clínicos.
create or replace function sivec_ve_centro(c bigint) returns boolean language sql stable security definer set search_path = public as $$
  select case sivec_rol()
    when 'centro' then c = sivec_centro()
    when 'gestor' then exists (select 1 from centros where id = c and red_id = sivec_red())
    else false end $$;
-- Registrar y editar: solo el personal del propio centro.
create or replace function sivec_edita_centro(c bigint) returns boolean language sql stable security definer set search_path = public as $$
  select sivec_rol() = 'centro' and c = sivec_centro() $$;
-- Buscar la cuenta de un correo (solo el administrador), para asignarle perfil.
create or replace function sivec_uid_por_correo(p_correo text) returns uuid language sql stable security definer set search_path = public, auth as $$
  select u.id from auth.users u where sivec_es_admin() and lower(u.email) = lower(trim(p_correo)) limit 1 $$;

-- 3) Reglas de las tablas nuevas
alter table redes enable row level security;
alter table centros enable row level security;
alter table perfiles enable row level security;
drop policy if exists "ver redes" on redes;
drop policy if exists "admin redes" on redes;
drop policy if exists "ver centros" on centros;
drop policy if exists "admin centros" on centros;
drop policy if exists "ver perfil" on perfiles;
drop policy if exists "admin perfiles" on perfiles;
create policy "ver redes" on redes for select to authenticated using (true);
create policy "admin redes" on redes for all to authenticated using (sivec_es_admin()) with check (sivec_es_admin());
create policy "ver centros" on centros for select to authenticated using (true);
create policy "admin centros" on centros for all to authenticated using (sivec_es_admin()) with check (sivec_es_admin());
create policy "ver perfil" on perfiles for select to authenticated using (user_id = auth.uid() or sivec_es_admin());
create policy "admin perfiles" on perfiles for all to authenticated using (sivec_es_admin()) with check (sivec_es_admin());
grant select, insert, update, delete on redes, centros, perfiles to authenticated;
grant select on perfiles to anon;  -- no ve ninguna fila: solo sirve para que el sistema sepa que ya hay roles y pida iniciar sesión

-- 4) Cada paciente pertenece a un centro (si no se manda, el del usuario que la registra)
alter table pacientes add column if not exists centro_id bigint references centros(id);
alter table pacientes alter column centro_id set default sivec_centro();
create index if not exists pacientes_centro_idx on pacientes (centro_id);

-- 5) El piloto: Red Centro y C.S. San Luis; todas las pacientes de hoy son de San Luis
insert into redes (nombre, municipio) values ('Red Centro', 'Santa Cruz de la Sierra') on conflict (nombre) do nothing;
insert into centros (nombre, red_id, tipo) select 'C.S. San Luis', id, 'primer_nivel' from redes where nombre = 'Red Centro' on conflict (nombre) do nothing;
update pacientes set centro_id = (select id from centros where nombre = 'C.S. San Luis') where centro_id is null;

-- 6) Las cuentas que ya existen = personal de San Luis
insert into perfiles (user_id, correo, nombre, rol, centro_id)
  select u.id, u.email, split_part(u.email, '@', 1), 'centro', (select id from centros where nombre = 'C.S. San Luis')
  from auth.users u on conflict (user_id) do nothing;

-- 7) Vos sos la administradora (cambiá el correo por el tuyo)
update perfiles set es_admin = true where lower(correo) = lower('TU_CORREO@gmail.com');

notify pgrst, 'reload schema';
```

Después, en el sistema: botón **Admin** → agregar los otros centros de la red, el oncológico, el hospital de 2º nivel y los usuarios.
Cada usuario ve arriba a la derecha su nombre, su rol y su centro.

---

## Paso 9 — Que cada centro vea solo lo suyo, protegido por la base de datos (IMPORTANTE)

El Paso 8 ya separa los centros en la pantalla. Este paso hace que la separación la ponga **Supabase**, no el navegador:
aunque alguien tenga la clave, solo recibe las filas de su centro (o de su red, si es gestor), y solo el personal del centro puede registrar o editar.
Reemplaza al Paso 3.3.

**Hacerlo recién cuando** todas las personas entran con su usuario y cada una tiene rol y centro en **Admin → Usuarios**.

```sql
alter table pacientes enable row level security;
alter table colposcopias enable row level security;
alter table consultas enable row level security;

-- Se sacan las reglas viejas ("cualquier usuario con sesión ve todo")
drop policy if exists "Solo usuarias con sesión - pacientes" on pacientes;
drop policy if exists "Solo usuarias con sesión - colposcopias" on colposcopias;
drop policy if exists "Solo usuarias con sesión - consultas" on consultas;
drop policy if exists "consultas acceso del sistema" on consultas;
drop policy if exists "ver por centro" on pacientes;
drop policy if exists "editar por centro" on pacientes;
drop policy if exists "ver por centro" on colposcopias;
drop policy if exists "editar por centro" on colposcopias;
drop policy if exists "ver por centro" on consultas;
drop policy if exists "editar por centro" on consultas;

create policy "ver por centro" on pacientes for select to authenticated using (sivec_ve_centro(centro_id));
create policy "editar por centro" on pacientes for all to authenticated
  using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));

create policy "ver por centro" on colposcopias for select to authenticated using (
  exists (select 1 from pacientes p where p.id::text = colposcopias.paciente_id::text and sivec_ve_centro(p.centro_id)));
create policy "editar por centro" on colposcopias for all to authenticated
  using (exists (select 1 from pacientes p where p.id::text = colposcopias.paciente_id::text and sivec_edita_centro(p.centro_id)))
  with check (exists (select 1 from pacientes p where p.id::text = colposcopias.paciente_id::text and sivec_edita_centro(p.centro_id)));

create policy "ver por centro" on consultas for select to authenticated using (
  exists (select 1 from pacientes p where p.id::text = consultas.paciente_id::text and sivec_ve_centro(p.centro_id)));
create policy "editar por centro" on consultas for all to authenticated
  using (exists (select 1 from pacientes p where p.id::text = consultas.paciente_id::text and sivec_edita_centro(p.centro_id)))
  with check (exists (select 1 from pacientes p where p.id::text = consultas.paciente_id::text and sivec_edita_centro(p.centro_id)));
```

### Deshacer el Paso 9 (vuelve a "cualquier usuario con sesión ve todo")

```sql
drop policy if exists "ver por centro" on pacientes;
drop policy if exists "editar por centro" on pacientes;
drop policy if exists "ver por centro" on colposcopias;
drop policy if exists "editar por centro" on colposcopias;
drop policy if exists "ver por centro" on consultas;
drop policy if exists "editar por centro" on consultas;
create policy "Solo usuarias con sesión - pacientes" on pacientes for all to authenticated using (true) with check (true);
create policy "Solo usuarias con sesión - colposcopias" on colposcopias for all to authenticated using (true) with check (true);
create policy "Solo usuarias con sesión - consultas" on consultas for all to authenticated using (true) with check (true);
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

> Si ya hiciste el **Paso 8**, usá el **Paso 9** en lugar de este.

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
