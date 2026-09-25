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

Usa las tablas que ya existen en el Supabase del piloto (**`centros_salud`**, **`perfiles_usuario`**, todo con `uuid`) y crea **`redes`**.
Las pacientes sin centro quedan en **San Luis** (si ya hay un centro con "San Luis" en el nombre, se usa ese) y todas las cuentas que ya existen quedan como personal de San Luis.
Se puede ejecutar más de una vez sin problema. Al final muestra cuántas pacientes quedaron en cada centro y la lista de usuarios.

**Antes:** cada persona que usa el sistema tiene que tener su cuenta (Paso 3.1). Desde este paso **el inicio de sesión es obligatorio**.
El correo del paso 7 del SQL (`pap.sanluis.scz@gmail.com`) queda como administrador: si entrás al sistema con otro correo, cambialo.

Roles:
- **Centro de salud**: ve y registra solo las pacientes de su centro.
- **Gestor de red**: ve todos los centros de su red (con selector "Todos / centro X"), no edita.
- **Oncológico / laboratorio** y **Colposcopia 2º nivel**: su portal (se programa en los próximos pasos).
- **Administrador**: crea redes, establecimientos y usuarios; **no ve datos clínicos**. Una persona de centro puede además administrar (casilla "Administra").

```sql
-- 1) Redes (nueva) + completar centros_salud y perfiles_usuario (ya existen)
create table if not exists redes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  municipio text,
  created_at timestamptz not null default now()
);
alter table centros_salud add column if not exists red_id uuid;
alter table centros_salud add column if not exists tipo text not null default 'primer_nivel';  -- primer_nivel · segundo_nivel · oncologico
alter table centros_salud add column if not exists codigo text;
alter table perfiles_usuario add column if not exists correo text;
alter table perfiles_usuario add column if not exists es_admin boolean not null default false;
alter table perfiles_usuario add column if not exists red_id uuid;
alter table perfiles_usuario add column if not exists activo boolean not null default true;
alter table perfiles_usuario drop constraint if exists perfiles_usuario_rol_check;  -- regla vieja con otros nombres de rol
alter table perfiles_usuario alter column rol set default 'centro';
create unique index if not exists perfiles_usuario_id_uq on perfiles_usuario (id);

-- 2) Quién soy (las usa el sistema y las reglas de seguridad)
create or replace function sivec_rol() returns text language sql stable security definer set search_path = public as $$
  select rol from perfiles_usuario where id = auth.uid() and activo limit 1 $$;
create or replace function sivec_es_admin() returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select rol = 'admin' or es_admin from perfiles_usuario where id = auth.uid() and activo limit 1), false) $$;
create or replace function sivec_centro() returns uuid language sql stable security definer set search_path = public as $$
  select centro_id from perfiles_usuario where id = auth.uid() and activo limit 1 $$;
create or replace function sivec_red() returns uuid language sql stable security definer set search_path = public as $$
  select coalesce(p.red_id, c.red_id) from perfiles_usuario p left join centros_salud c on c.id = p.centro_id
  where p.id = auth.uid() and p.activo limit 1 $$;
-- Ver: el centro ve lo suyo; el gestor ve todos los centros de su red. El administrador puro no ve datos clínicos.
create or replace function sivec_ve_centro(c uuid) returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(case sivec_rol()
    when 'centro' then c = sivec_centro()
    when 'gestor' then exists (select 1 from centros_salud where id = c and red_id = sivec_red())
    else false end, false) $$;
-- Registrar y editar: solo el personal del propio centro.
create or replace function sivec_edita_centro(c uuid) returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(sivec_rol() = 'centro' and c = sivec_centro(), false) $$;
-- Buscar la cuenta de un correo (solo el administrador), para asignarle perfil.
create or replace function sivec_uid_por_correo(p_correo text) returns uuid language sql stable security definer set search_path = public, auth as $$
  select u.id from auth.users u where sivec_es_admin() and lower(u.email) = lower(trim(p_correo)) limit 1 $$;

-- 3) Reglas de redes, centros y perfiles (se quitan las reglas viejas de esas tablas)
do $$ declare r record; begin
  for r in select policyname, tablename from pg_policies where schemaname = 'public' and tablename in ('redes', 'centros_salud', 'perfiles_usuario') loop
    execute format('drop policy %I on %I', r.policyname, r.tablename);
  end loop;
end $$;
alter table redes enable row level security;
alter table centros_salud enable row level security;
alter table perfiles_usuario enable row level security;
create policy "ver redes" on redes for select to authenticated using (true);
create policy "admin redes" on redes for all to authenticated using (sivec_es_admin()) with check (sivec_es_admin());
create policy "ver centros" on centros_salud for select to authenticated using (true);
create policy "admin centros" on centros_salud for all to authenticated using (sivec_es_admin()) with check (sivec_es_admin());
create policy "ver perfil" on perfiles_usuario for select to authenticated using (id = auth.uid() or sivec_es_admin());
create policy "admin perfiles" on perfiles_usuario for all to authenticated using (sivec_es_admin()) with check (sivec_es_admin());
grant select, insert, update, delete on redes, centros_salud, perfiles_usuario to authenticated;
grant select on perfiles_usuario to anon;  -- no ve ninguna fila: solo sirve para que el sistema sepa que ya hay roles y pida iniciar sesión

-- 4) El piloto: Red Centro y C.S. San Luis (si ya hay un centro "San Luis", se usa ese)
insert into redes (nombre, municipio) values ('Red Centro', 'Santa Cruz de la Sierra') on conflict (nombre) do nothing;
insert into redes (nombre) select distinct trim(red) from centros_salud where coalesce(trim(red), '') <> '' on conflict (nombre) do nothing;
update centros_salud c set red_id = r.id from redes r where c.red_id is null and r.nombre = trim(c.red);
insert into centros_salud (nombre, red, red_id, tipo, activo)
  select 'C.S. San Luis', 'Red Centro', (select id from redes where nombre = 'Red Centro'), 'primer_nivel', true
  where not exists (select 1 from centros_salud where nombre ilike '%san luis%');
create or replace function sivec_san_luis() returns uuid language sql stable as $$
  select id from centros_salud where nombre ilike '%san luis%' order by created_at nulls last, nombre limit 1 $$;
update centros_salud set red_id = coalesce(red_id, (select id from redes where nombre = 'Red Centro')) where id = sivec_san_luis();

-- 5) Cada paciente pertenece a un centro: las de hoy (sin centro) son de San Luis; las nuevas, del centro de quien las registra
update pacientes set centro_id = sivec_san_luis() where centro_id is null;
alter table pacientes alter column centro_id set default sivec_centro();
create index if not exists pacientes_centro_idx on pacientes (centro_id);

-- 6) Las cuentas que ya existen = personal de San Luis
insert into perfiles_usuario (id, correo, nombre_completo, rol, centro_id)
  select u.id, u.email, split_part(u.email, '@', 1), 'centro', sivec_san_luis()
  from auth.users u where not exists (select 1 from perfiles_usuario p where p.id = u.id);
update perfiles_usuario p set correo = u.email from auth.users u where u.id = p.id and p.correo is null;
update perfiles_usuario set rol = 'centro' where rol is null or rol not in ('centro', 'gestor', 'oncologico', 'colposcopia', 'admin');
update perfiles_usuario set centro_id = sivec_san_luis() where rol = 'centro' and centro_id is null;
alter table perfiles_usuario add constraint perfiles_usuario_rol_check check (rol in ('centro', 'gestor', 'oncologico', 'colposcopia', 'admin'));

-- 7) Vos: centro San Luis + administradora (cambiá el correo si hace falta)
update perfiles_usuario set es_admin = true, rol = 'centro', centro_id = coalesce(centro_id, sivec_san_luis())
  where lower(correo) = lower('pap.sanluis.scz@gmail.com');

notify pgrst, 'reload schema';

-- Resultado: cuántas pacientes quedaron en cada centro, y los usuarios
select 'Pacientes en ' || coalesce(c.nombre, '(sin centro)') as resumen, count(*)::text as cantidad
  from pacientes p left join centros_salud c on c.id = p.centro_id where p.deleted_at is null group by c.nombre
union all
select 'Usuario ' || coalesce(correo, id::text), rol || case when es_admin then ' + admin' else '' end from perfiles_usuario;
```

Después, en el sistema: botón **Admin** → agregar los otros centros de la red, el oncológico, el hospital de 2º nivel y los usuarios.

---

## Paso 9 — Que cada centro vea solo lo suyo, protegido por la base de datos (IMPORTANTE)

El Paso 8 separa los centros en la pantalla. Este paso hace que la separación la ponga **Supabase**:
aunque alguien tenga la clave, solo recibe las filas de su centro (o de su red, si es gestor), y solo el personal del centro puede registrar o editar.
Quita todas las reglas anteriores de `pacientes`, `colposcopias` y `consultas`. Reemplaza al Paso 3.3.

**Hacerlo recién cuando** todas las personas entran con su usuario y cada una tiene rol y centro en **Admin → Usuarios**.

```sql
-- Se quitan TODAS las reglas viejas de estas tablas ("cualquiera ve todo")
do $$ declare r record; begin
  for r in select policyname, tablename from pg_policies where schemaname = 'public' and tablename in ('pacientes', 'colposcopias', 'consultas') loop
    execute format('drop policy %I on %I', r.policyname, r.tablename);
  end loop;
end $$;
alter table pacientes enable row level security;
alter table colposcopias enable row level security;
alter table consultas enable row level security;

create policy "ver por centro" on pacientes for select to authenticated using (sivec_ve_centro(centro_id));
create policy "editar por centro" on pacientes for all to authenticated
  using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));

create policy "ver por centro" on colposcopias for select to authenticated using (
  exists (select 1 from pacientes p where p.id = colposcopias.paciente_id and sivec_ve_centro(p.centro_id)));
create policy "editar por centro" on colposcopias for all to authenticated
  using (exists (select 1 from pacientes p where p.id = colposcopias.paciente_id and sivec_edita_centro(p.centro_id)))
  with check (exists (select 1 from pacientes p where p.id = colposcopias.paciente_id and sivec_edita_centro(p.centro_id)));

create policy "ver por centro" on consultas for select to authenticated using (
  exists (select 1 from pacientes p where p.id = consultas.paciente_id and sivec_ve_centro(p.centro_id)));
create policy "editar por centro" on consultas for all to authenticated
  using (exists (select 1 from pacientes p where p.id = consultas.paciente_id and sivec_edita_centro(p.centro_id)))
  with check (exists (select 1 from pacientes p where p.id = consultas.paciente_id and sivec_edita_centro(p.centro_id)));
```

### Deshacer el Paso 9 (vuelve a "cualquier usuario con sesión ve todo")

```sql
do $$ declare r record; begin
  for r in select policyname, tablename from pg_policies where schemaname = 'public' and tablename in ('pacientes', 'colposcopias', 'consultas') loop
    execute format('drop policy %I on %I', r.policyname, r.tablename);
  end loop;
end $$;
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
