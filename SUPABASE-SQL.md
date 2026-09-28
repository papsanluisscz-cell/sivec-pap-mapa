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

### Paso 7b — Si al guardar sale "violates foreign key constraint consultas_paciente_id_fkey"

En el Supabase del piloto, la tabla `consultas` venía de una versión vieja que la ataba a `pacientes_generales`.
Las consultas del SIVEC PAP son de las pacientes de la tabla `pacientes`: esto cambia la regla (las consultas viejas no se tocan).

```sql
alter table consultas drop constraint if exists consultas_paciente_id_fkey;
alter table consultas add constraint consultas_paciente_id_fkey
  foreign key (paciente_id) references pacientes(id) on delete cascade not valid;
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
insert into redes (nombre, municipio) select 'Red Centro', 'Santa Cruz de la Sierra' where not exists (select 1 from redes where nombre ilike 'red centro') and not exists (select 1 from centros_salud where trim(red) ilike 'red centro');
insert into redes (nombre) select distinct on (lower(trim(red))) trim(red) from centros_salud where coalesce(trim(red), '') <> '' and not exists (select 1 from redes r where lower(r.nombre) = lower(trim(red)));
update centros_salud c set red_id = r.id from redes r where c.red_id is null and lower(r.nombre) = lower(trim(c.red));
insert into centros_salud (nombre, red, red_id, tipo, activo)
  select 'C.S. San Luis', 'Red Centro', (select id from redes where nombre ilike 'red centro' limit 1), 'primer_nivel', true
  where not exists (select 1 from centros_salud where nombre ilike '%san luis%');
create or replace function sivec_san_luis() returns uuid language sql stable as $$
  select id from centros_salud where nombre ilike '%san luis%' order by created_at nulls last, nombre limit 1 $$;
update centros_salud set red_id = coalesce(red_id, (select id from redes where nombre ilike 'red centro' limit 1)) where id = sivec_san_luis();

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

## Paso 10 — Lote de envío al oncológico (código de cada lámina + hoja de remisión)

Desde el **Balance**, el centro marca las tomas y toca **📦 Armar lote**: se crea el lote (ej. `L-2026-0042`) con su destino,
cada lámina recibe su código (`M-26-000123`), y se imprimen las **etiquetas** con código de barras y la **hoja de remisión**
(firma de entrega y de recepción). Abajo del Balance quedan los últimos lotes: "en camino · N días" o "recibido".
Requiere los Pasos 8 y 4, y el oncológico cargado en **Admin → Establecimientos** (tipo "Oncológico / laboratorio").

```sql
-- 1) Lotes de envío (centro → oncológico) y código de cada muestra
create sequence if not exists lote_seq;
create sequence if not exists muestra_seq;
create table if not exists lotes (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique,
  centro_id uuid not null,
  destino_id uuid,
  fecha_envio date not null default current_date,
  transporte text,
  entregado_por text,
  n_muestras int not null default 0,
  estado text not null default 'enviado',          -- enviado · recibido
  recibido_por text,
  fecha_recepcion timestamptz,
  observaciones text,
  creado_por uuid default auth.uid(),
  created_at timestamptz not null default now()
);
create index if not exists lotes_centro_idx on lotes (centro_id);
create index if not exists lotes_destino_idx on lotes (destino_id);
alter table pacientes add column if not exists lote_id uuid references lotes(id);
alter table pacientes add column if not exists codigo_muestra text;
alter table pacientes add column if not exists muestra_estado text;    -- enviada · recibida · rechazada
alter table pacientes add column if not exists muestra_rechazo text;
create unique index if not exists pacientes_codigo_muestra_uq on pacientes (codigo_muestra) where codigo_muestra is not null;

-- 2) Quién ve cada lote: el centro que lo mandó, el gestor de su red y el oncológico que lo recibe
create or replace function sivec_ve_lote(c uuid, d uuid) returns boolean language sql stable security definer set search_path = public as $$
  select sivec_ve_centro(c) or (sivec_rol() = 'oncologico' and d = sivec_centro()) $$;
alter table lotes enable row level security;
drop policy if exists "ver lotes" on lotes;
drop policy if exists "centro arma lotes" on lotes;
drop policy if exists "centro corrige lotes" on lotes;
drop policy if exists "oncologico recibe lotes" on lotes;
create policy "ver lotes" on lotes for select to authenticated using (sivec_ve_lote(centro_id, destino_id));
create policy "centro arma lotes" on lotes for insert to authenticated with check (sivec_edita_centro(centro_id));
create policy "centro corrige lotes" on lotes for update to authenticated using (sivec_edita_centro(centro_id) and estado = 'enviado') with check (sivec_edita_centro(centro_id));
create policy "oncologico recibe lotes" on lotes for update to authenticated using (sivec_rol() = 'oncologico' and destino_id = sivec_centro()) with check (sivec_rol() = 'oncologico' and destino_id = sivec_centro());
grant select, insert, update on lotes to authenticated;
grant usage on sequence lote_seq, muestra_seq to authenticated;

-- 3) Armar un lote en un solo paso: crea el lote, da un código a cada muestra y las marca como enviadas
create or replace function sivec_armar_lote(p_ids uuid[], p_destino uuid, p_fecha date, p_transporte text, p_entregado text)
returns lotes language plpgsql security invoker set search_path = public as $$
declare v_centro uuid; v_lote lotes; v_n int;
begin
  select min(centro_id::text)::uuid, count(*) into v_centro, v_n from pacientes where id = any(p_ids) and lote_id is null and deleted_at is null;
  if v_n = 0 then raise exception 'Ninguna de las muestras marcadas está libre (ya estaban en otro lote).'; end if;
  if (select count(distinct centro_id) from pacientes where id = any(p_ids) and lote_id is null) > 1 then raise exception 'Todas las muestras de un lote tienen que ser del mismo centro.'; end if;
  insert into lotes (codigo, centro_id, destino_id, fecha_envio, transporte, entregado_por, n_muestras)
    values ('L-' || to_char(coalesce(p_fecha, current_date), 'YYYY') || '-' || lpad(nextval('lote_seq')::text, 4, '0'),
            v_centro, p_destino, coalesce(p_fecha, current_date), nullif(trim(p_transporte), ''), nullif(trim(p_entregado), ''), v_n)
    returning * into v_lote;
  update pacientes p set lote_id = v_lote.id, lote_envio = v_lote.codigo, fecha_envio = v_lote.fecha_envio, muestra_estado = 'enviada',
         codigo_muestra = coalesce(p.codigo_muestra, 'M-' || to_char(coalesce(p_fecha, current_date), 'YY') || '-' || lpad(nextval('muestra_seq')::text, 6, '0'))
   where p.id = any(p_ids) and p.lote_id is null and p.deleted_at is null;
  get diagnostics v_n = row_count;
  if v_n <> v_lote.n_muestras then raise exception 'No se pudieron marcar todas las muestras (permisos del centro).'; end if;
  return v_lote;
end $$;
grant execute on function sivec_armar_lote(uuid[], uuid, date, text, text) to authenticated;

notify pgrst, 'reload schema';
```

---

## Paso 11 — Servicios de cada establecimiento (colposcopia · recibe muestras) y oncológico de 4º nivel

El oncológico no pertenece a una red: es **4º nivel, departamental**, recibe las muestras de todas las redes y también hace colposcopia.
La colposcopia no depende del nivel: en **Admin → Establecimientos** se marca en cada uno si **hace colposcopia** y si **recibe muestras**.
Los demás establecimientos quedan **sin** colposcopia hasta que se marque la casilla (tener colposcopias registradas no significa que el centro las haga: pueden ser resultados de la contrarreferencia).

```sql
-- Servicios de cada establecimiento (independientes del nivel)
alter table centros_salud alter column red drop not null;  -- el oncológico y otros de 4º nivel no tienen red
alter table centros_salud add column if not exists hace_colposcopia boolean not null default false;
alter table centros_salud add column if not exists recibe_muestras boolean not null default false;

-- El oncológico: 4º nivel, departamental (sin red), recibe las muestras y hace colposcopia
update centros_salud set tipo = 'oncologico', red_id = null, red = null, recibe_muestras = true, hace_colposcopia = true
  where tipo = 'oncologico' or nombre ilike '%oncol%';

notify pgrst, 'reload schema';

select nombre, coalesce((select nombre from redes where id = red_id), 'departamental') as red, tipo,
       hace_colposcopia as colposcopia, recibe_muestras
  from centros_salud order by recibe_muestras desc, nombre;
```

---

## Paso 12 — Portal del laboratorio (oncológico): recepción, informe PAP/VPH y resultado digital al centro

El usuario con rol **Laboratorio de citología** (establecimiento que recibe muestras) entra al **Portal**:
recibe cada lote (escaneando el código de barras de cada lámina o marcándola), rechaza con motivo las que no sirven,
informa **Bethesda + hallazgos + VPH/genotipo**, con validación del patólogo si no es NILM, y firma.
El resultado se escribe en la ficha del centro y aparece como **"🔬 Resultado nuevo"** hasta que el centro lo marca como visto.
El oncológico **no tiene acceso a la tabla de pacientes**: solo a sus muestras, por estas funciones.

```sql
-- 1) Informe del laboratorio en cada toma
alter table pacientes add column if not exists fecha_recepcion_muestra timestamptz;
alter table pacientes add column if not exists fecha_informe timestamptz;
alter table pacientes add column if not exists informado_por text;
alter table pacientes add column if not exists informe_lab jsonb;
alter table pacientes add column if not exists resultado_visto_at timestamptz;
alter table pacientes add column if not exists vph_genotipo text;

-- 2) El oncológico ve SOLO las muestras que le mandaron, con lo necesario para leerlas (no la ficha entera)
create or replace function sivec_lab_muestras(p_lote uuid default null)
returns table (id uuid, codigo_muestra text, nombre text, carnet text, fecha_nacimiento date, fecha_toma date,
  tipo_examen text, hizo_prueba_vph boolean, anticonceptivo_metodo text, doctora text, pap_anterior text,
  lote_id uuid, lote_codigo text, centro_id uuid, fecha_envio date, muestra_estado text, muestra_rechazo text,
  fecha_recepcion_muestra timestamptz, resultado_pap text, resultado_vph text, vph_genotipo text,
  informe_lab jsonb, fecha_informe timestamptz, informado_por text)
language sql stable security definer set search_path = public as $$
  select p.id, p.codigo_muestra, p.nombre, p.carnet, p.fecha_nacimiento, p.fecha_toma, p.tipo_examen, p.hizo_prueba_vph,
    p.anticonceptivo_metodo, p.doctora,
    (select q.resultado_pap || ' (' || to_char(q.fecha_toma, 'YYYY') || ')' from pacientes q
       where coalesce(p.carnet, '') <> '' and q.carnet = p.carnet and q.id <> p.id and q.fecha_toma < p.fecha_toma
         and coalesce(q.resultado_pap, '') <> '' and q.deleted_at is null order by q.fecha_toma desc limit 1),
    l.id, l.codigo, l.centro_id, l.fecha_envio, p.muestra_estado, p.muestra_rechazo, p.fecha_recepcion_muestra,
    p.resultado_pap, p.resultado_vph, p.vph_genotipo, p.informe_lab, p.fecha_informe, p.informado_por
  from pacientes p join lotes l on l.id = p.lote_id
  where sivec_rol() = 'oncologico' and l.destino_id = sivec_centro() and p.deleted_at is null
    and (p_lote is null or l.id = p_lote)
  order by l.fecha_envio, p.codigo_muestra $$;

-- 3) Recepción del lote: todas llegan salvo las rechazadas (con motivo); el centro se entera del rechazo
create or replace function sivec_lab_recibir(p_lote uuid, p_rechazos jsonb, p_recibido_por text)
returns lotes language plpgsql security definer set search_path = public as $$
declare v_lote lotes; v_rech int;
begin
  select * into v_lote from lotes where id = p_lote and destino_id = sivec_centro() and sivec_rol() = 'oncologico';
  if not found then raise exception 'Este lote no fue enviado a su establecimiento.'; end if;
  update pacientes set muestra_estado = 'rechazada', muestra_rechazo = p_rechazos ->> id::text,
         fecha_recepcion_muestra = now(), fecha_informe = now(), informado_por = nullif(trim(p_recibido_por), ''), resultado_visto_at = null
   where lote_id = p_lote and coalesce(p_rechazos, '{}'::jsonb) ? id::text and coalesce(muestra_estado, 'enviada') = 'enviada';
  get diagnostics v_rech = row_count;
  update pacientes set muestra_estado = 'recibida', fecha_recepcion_muestra = now()
   where lote_id = p_lote and coalesce(muestra_estado, 'enviada') = 'enviada';
  update lotes set estado = 'recibido', fecha_recepcion = now(), recibido_por = nullif(trim(p_recibido_por), ''),
         observaciones = case when v_rech > 0 then v_rech || ' muestra(s) rechazada(s)' else observaciones end
   where id = p_lote returning * into v_lote;
  return v_lote;
end $$;

-- 4) Informe (Bethesda + VPH): el resultado aparece en la ficha del centro y queda "sin ver" hasta que el centro lo marca
create or replace function sivec_lab_informar(p_id uuid, p_bethesda text, p_texto text, p_vph text, p_genotipo text, p_informe jsonb, p_informado_por text)
returns void language plpgsql security definer set search_path = public as $$
declare v_ok boolean; v_estado text;
begin
  select true into v_ok from pacientes p join lotes l on l.id = p.lote_id
   where p.id = p_id and l.destino_id = sivec_centro() and sivec_rol() = 'oncologico'
     and p.muestra_estado in ('recibida', 'informada', 'insatisfactoria');
  if v_ok is null then raise exception 'La muestra no está recibida en su establecimiento.'; end if;
  v_estado := case when p_bethesda is null then null when p_bethesda = 'NILM' then 'Negativo' when p_bethesda = 'Insatisfactoria' then 'Pendiente' else 'Positivo' end;
  update pacientes set
    resultado_pap = case when p_bethesda is null then resultado_pap else coalesce(nullif(trim(p_texto), ''), p_bethesda) end,
    estado_pap = coalesce(v_estado, estado_pap),
    resultado_vph = coalesce(p_vph, resultado_vph),
    vph_genotipo = case when p_vph = 'Positiva' then nullif(p_genotipo, '') when p_vph = 'Negativa' then null else vph_genotipo end,
    informe_lab = p_informe, fecha_informe = now(), informado_por = nullif(trim(p_informado_por), ''),
    muestra_estado = case when p_bethesda = 'Insatisfactoria' then 'insatisfactoria' else 'informada' end,
    resultado_visto_at = null
  where id = p_id;
end $$;

revoke execute on function sivec_lab_muestras(uuid), sivec_lab_recibir(uuid, jsonb, text), sivec_lab_informar(uuid, text, text, text, text, jsonb, text) from public, anon;
grant execute on function sivec_lab_muestras(uuid), sivec_lab_recibir(uuid, jsonb, text), sivec_lab_informar(uuid, text, text, text, text, jsonb, text) to authenticated;
notify pgrst, 'reload schema';
```

---

## Paso 13 — Derivación digital a colposcopia / biopsia y contrarreferencia

El centro deriva desde la paciente (⋯ → **🩺 Derivar a colposcopia / biopsia**) a un establecimiento con colposcopia habilitada.
El usuario con rol **Colposcopia** de ese establecimiento la ve en su **Portal**: da la cita, registra colposcopia, biopsia y tratamiento,
y envía la **contrarreferencia**, que llega a la ficha del centro ("🩺 contrarreferencia · nueva"). El resultado de la biopsia se carga después
y vuelve a avisar al centro. El seguimiento PAP+ avanza solo (colposcopia agendada → realizada → tratamiento) y la colposcopia queda en la ficha.

```sql
-- 1) Derivación a colposcopia / biopsia y contrarreferencia
create table if not exists derivaciones (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references pacientes(id) on delete cascade,
  centro_origen uuid not null,
  destino_id uuid not null,
  motivo text,
  indicacion text,                      -- Colposcopia · Colposcopia + biopsia · Tratamiento
  prioridad text not null default 'normal',
  notas text,
  derivado_por text,
  fecha_derivacion date not null default current_date,
  estado text not null default 'enviada', -- enviada · citada · atendida · contrarreferida · no_asistio · cancelada
  fecha_cita date,
  fecha_atencion date,
  atendido_por text,
  colposcopia jsonb,
  biopsia_tomada boolean,
  biopsia_resultado text,
  fecha_biopsia_resultado date,
  tratamiento text,
  contrarreferencia text,
  proximo_control text,
  fecha_contrarreferencia timestamptz,
  visto_origen_at timestamptz,
  creado_por uuid default auth.uid(),
  created_at timestamptz not null default now()
);
create index if not exists derivaciones_paciente_idx on derivaciones (paciente_id);
create index if not exists derivaciones_destino_idx on derivaciones (destino_id, estado);
alter table derivaciones enable row level security;
drop policy if exists "origen ve sus derivaciones" on derivaciones;
drop policy if exists "destino ve sus derivadas" on derivaciones;
create policy "origen ve sus derivaciones" on derivaciones for select to authenticated using (sivec_ve_centro(centro_origen));
create policy "destino ve sus derivadas" on derivaciones for select to authenticated using (sivec_rol() = 'colposcopia' and destino_id = sivec_centro());
grant select on derivaciones to authenticated;

-- 2) El centro deriva (solo a establecimientos con colposcopia habilitada)
create or replace function sivec_derivar(p_paciente uuid, p_destino uuid, p_motivo text, p_indicacion text, p_prioridad text, p_notas text, p_por text)
returns derivaciones language plpgsql security definer set search_path = public as $$
declare v_p pacientes; v_d derivaciones; v_dest text;
begin
  select * into v_p from pacientes where id = p_paciente and deleted_at is null;
  if not found or not sivec_edita_centro(v_p.centro_id) then raise exception 'Solo el centro de la paciente puede derivarla.'; end if;
  select nombre into v_dest from centros_salud where id = p_destino and hace_colposcopia and activo is not false;
  if v_dest is null then raise exception 'Ese establecimiento no tiene colposcopia habilitada.'; end if;
  if exists (select 1 from derivaciones where paciente_id = p_paciente and estado in ('enviada', 'citada', 'atendida')) then
    raise exception 'Esta toma ya tiene una derivación en curso.'; end if;
  insert into derivaciones (paciente_id, centro_origen, destino_id, motivo, indicacion, prioridad, notas, derivado_por)
    values (p_paciente, v_p.centro_id, p_destino, nullif(trim(p_motivo), ''), nullif(trim(p_indicacion), ''), coalesce(nullif(p_prioridad, ''), 'normal'), nullif(trim(p_notas), ''), nullif(trim(p_por), ''))
    returning * into v_d;
  update pacientes set derivacion_pap = v_dest where id = p_paciente;
  return v_d;
end $$;

create or replace function sivec_der_cancelar(p_id uuid) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set estado = 'cancelada' where id = p_id and estado in ('enviada', 'citada') and sivec_edita_centro(centro_origen);
  if not found then raise exception 'No se puede cancelar esta derivación.'; end if;
end $$;

create or replace function sivec_der_visto(p_ids uuid[]) returns void language sql security definer set search_path = public as $$
  update derivaciones set visto_origen_at = now() where id = any(p_ids) and sivec_edita_centro(centro_origen) $$;

-- 3) Portal de colposcopia: solo las pacientes derivadas a este establecimiento, con sus antecedentes de PAP/VPH
create or replace function sivec_colpo_lista()
returns table (id uuid, paciente_id uuid, nombre text, carnet text, fecha_nacimiento date, celular text, direccion text,
  centro_origen uuid, motivo text, indicacion text, prioridad text, notas text, derivado_por text, fecha_derivacion date,
  estado text, fecha_cita date, fecha_atencion date, atendido_por text, colposcopia jsonb, biopsia_tomada boolean,
  biopsia_resultado text, tratamiento text, contrarreferencia text, proximo_control text, fecha_contrarreferencia timestamptz, antecedentes text)
language sql stable security definer set search_path = public as $$
  select d.id, d.paciente_id, p.nombre, p.carnet, p.fecha_nacimiento, p.celular, p.direccion,
    d.centro_origen, d.motivo, d.indicacion, d.prioridad, d.notas, d.derivado_por, d.fecha_derivacion,
    d.estado, d.fecha_cita, d.fecha_atencion, d.atendido_por, d.colposcopia, d.biopsia_tomada,
    d.biopsia_resultado, d.tratamiento, d.contrarreferencia, d.proximo_control, d.fecha_contrarreferencia,
    (select string_agg(to_char(q.fecha_toma, 'MM/YYYY') || ' ' || coalesce(nullif(q.resultado_pap, ''), 'PAP pendiente')
        || case when q.resultado_vph is not null and q.resultado_vph <> '' then ' · VPH ' || q.resultado_vph || coalesce(' ' || q.vph_genotipo, '') else '' end, '  |  ' order by q.fecha_toma desc)
       from pacientes q where q.deleted_at is null and (q.id = p.id or (coalesce(p.carnet, '') <> '' and q.carnet = p.carnet)))
  from derivaciones d join pacientes p on p.id = d.paciente_id
  where sivec_rol() = 'colposcopia' and d.destino_id = sivec_centro() and d.estado <> 'cancelada'
  order by (d.prioridad = 'urgente') desc, d.fecha_derivacion $$;

create or replace function sivec_colpo_etapa(p_paciente uuid, p_etapa text) returns void language sql security definer set search_path = public as $$
  update pacientes set seg_etapa = p_etapa, seg_fechas = coalesce(seg_fechas, '{}'::jsonb) || jsonb_build_object(p_etapa, to_char(current_date, 'YYYY-MM-DD'))
   where id = p_paciente $$;

create or replace function sivec_colpo_cita(p_id uuid, p_fecha date) returns void language plpgsql security definer set search_path = public as $$
declare v_pac uuid;
begin
  update derivaciones set estado = 'citada', fecha_cita = p_fecha
   where id = p_id and sivec_rol() = 'colposcopia' and destino_id = sivec_centro() and estado in ('enviada', 'citada', 'no_asistio')
   returning paciente_id into v_pac;
  if v_pac is null then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
  perform sivec_colpo_etapa(v_pac, 'colpo_agendada');
end $$;

create or replace function sivec_colpo_no_asistio(p_id uuid) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set estado = 'no_asistio', fecha_contrarreferencia = now(), visto_origen_at = null,
         contrarreferencia = coalesce(contrarreferencia, 'La paciente no asistió a la cita: realizar búsqueda activa y volver a citar.')
   where id = p_id and sivec_rol() = 'colposcopia' and destino_id = sivec_centro() and estado in ('enviada', 'citada');
  if not found then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
end $$;

-- Atender: colposcopia (+ biopsia) y, si p_enviar, la contrarreferencia vuelve al centro
create or replace function sivec_colpo_atender(p_id uuid, p_colpo jsonb, p_biopsia boolean, p_tratamiento text, p_contrarref text, p_proximo text, p_por text, p_enviar boolean)
returns void language plpgsql security definer set search_path = public as $$
declare v_d derivaciones;
begin
  select * into v_d from derivaciones where id = p_id and sivec_rol() = 'colposcopia' and destino_id = sivec_centro() and estado <> 'cancelada';
  if not found then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
  update derivaciones set colposcopia = p_colpo, biopsia_tomada = p_biopsia, tratamiento = nullif(trim(p_tratamiento), ''),
         contrarreferencia = nullif(trim(p_contrarref), ''), proximo_control = nullif(trim(p_proximo), ''),
         atendido_por = nullif(trim(p_por), ''), fecha_atencion = coalesce(fecha_atencion, current_date),
         estado = case when p_enviar then 'contrarreferida' else 'atendida' end,
         fecha_contrarreferencia = case when p_enviar then now() else fecha_contrarreferencia end,
         visto_origen_at = case when p_enviar then null else visto_origen_at end
   where id = p_id;
  perform sivec_colpo_etapa(v_d.paciente_id, case when coalesce(p_tratamiento, '') not in ('', 'Ninguno (control)') then 'tratamiento' else 'colpo_realizada' end);
  -- Compatibilidad: también queda como colposcopia en la ficha (Historia clínica)
  if v_d.fecha_atencion is null then
    begin
      insert into colposcopias (paciente_id, fecha, zona_afectada, lesion, otros_hallazgos, prueba_schiller, centro_id)
      values (v_d.paciente_id, current_date, p_colpo ->> 'zt',
              array(select jsonb_array_elements_text(coalesce(p_colpo -> 'hallazgos', '[]'::jsonb))),
              concat_ws(' · ', 'Impresión: ' || (p_colpo ->> 'impresion'), case when p_biopsia then 'Biopsia tomada' end, p_colpo ->> 'observaciones'),
              p_colpo ->> 'schiller', v_d.destino_id);
    exception when others then null;
    end;
  end if;
end $$;

create or replace function sivec_colpo_biopsia(p_id uuid, p_resultado text) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set biopsia_resultado = nullif(trim(p_resultado), ''), fecha_biopsia_resultado = current_date,
         visto_origen_at = case when estado = 'contrarreferida' then null else visto_origen_at end
   where id = p_id and sivec_rol() = 'colposcopia' and destino_id = sivec_centro() and biopsia_tomada;
  if not found then raise exception 'Derivación sin biopsia o de otro establecimiento.'; end if;
end $$;

revoke execute on function sivec_derivar(uuid, uuid, text, text, text, text, text), sivec_der_cancelar(uuid), sivec_der_visto(uuid[]),
  sivec_colpo_lista(), sivec_colpo_etapa(uuid, text), sivec_colpo_cita(uuid, date), sivec_colpo_no_asistio(uuid),
  sivec_colpo_atender(uuid, jsonb, boolean, text, text, text, text, boolean), sivec_colpo_biopsia(uuid, text) from public, anon;
grant execute on function sivec_derivar(uuid, uuid, text, text, text, text, text), sivec_der_cancelar(uuid), sivec_der_visto(uuid[]),
  sivec_colpo_lista(), sivec_colpo_cita(uuid, date), sivec_colpo_no_asistio(uuid),
  sivec_colpo_atender(uuid, jsonb, boolean, text, text, text, text, boolean), sivec_colpo_biopsia(uuid, text) to authenticated;
notify pgrst, 'reload schema';
```

---

## Paso 14 — Un usuario por persona con permisos (Laboratorio / Colposcopia) y cobertura SUS

Un hospital puede tomar PAP, leer láminas, hacer colposcopia y biopsia: no hace falta un correo por servicio.
Cada persona es **Profesional de salud** de su establecimiento (registra tomas ahí) y, en **Admin → Usuarios**, se le marcan
los permisos **Laboratorio** y/o **Colposcopia** (solo si el establecimiento tiene ese servicio). Los usuarios que tenían rol
"Laboratorio"/"Colposcopia" pasan solos a este esquema. La derivación registra la **cobertura**: SUS (gratis) o sin SUS
(paga en la caja del hospital, por defecto Bs 30), y el hospital anota el número de recibo.
Requiere el Paso 13 (si no se ejecutó, correr primero la parte de la tabla `derivaciones`).

```sql
-- 1) Permisos por persona (un solo usuario por profesional): registrar tomas en su establecimiento
--    y, si el establecimiento tiene el servicio, también Laboratorio y/o Colposcopia.
alter table perfiles_usuario add column if not exists puede_laboratorio boolean not null default false;
alter table perfiles_usuario add column if not exists puede_colposcopia boolean not null default false;
update perfiles_usuario set puede_laboratorio = true, rol = 'centro' where rol = 'oncologico';
update perfiles_usuario set puede_colposcopia = true, rol = 'centro' where rol = 'colposcopia';

create or replace function sivec_es_lab() returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select p.puede_laboratorio and c.recibe_muestras from perfiles_usuario p join centros_salud c on c.id = p.centro_id
                    where p.id = auth.uid() and p.activo limit 1), false) $$;
create or replace function sivec_es_colpo() returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select p.puede_colposcopia and c.hace_colposcopia from perfiles_usuario p join centros_salud c on c.id = p.centro_id
                    where p.id = auth.uid() and p.activo limit 1), false) $$;

-- 2) Cobertura: con SUS es gratis; sin SUS paga en la caja del hospital
alter table pacientes add column if not exists cobertura text;
alter table derivaciones add column if not exists cobertura text;
alter table derivaciones add column if not exists monto numeric;
alter table derivaciones add column if not exists pago_recibo text;

-- 3) Lotes y laboratorio con el permiso nuevo
create or replace function sivec_ve_lote(c uuid, d uuid) returns boolean language sql stable security definer set search_path = public as $$
  select sivec_ve_centro(c) or (sivec_es_lab() and d = sivec_centro()) $$;
drop policy if exists "oncologico recibe lotes" on lotes;
create policy "oncologico recibe lotes" on lotes for update to authenticated using (sivec_es_lab() and destino_id = sivec_centro()) with check (sivec_es_lab() and destino_id = sivec_centro());

create or replace function sivec_lab_muestras(p_lote uuid default null)
returns table (id uuid, codigo_muestra text, nombre text, carnet text, fecha_nacimiento date, fecha_toma date,
  tipo_examen text, hizo_prueba_vph boolean, anticonceptivo_metodo text, doctora text, pap_anterior text,
  lote_id uuid, lote_codigo text, centro_id uuid, fecha_envio date, muestra_estado text, muestra_rechazo text,
  fecha_recepcion_muestra timestamptz, resultado_pap text, resultado_vph text, vph_genotipo text,
  informe_lab jsonb, fecha_informe timestamptz, informado_por text)
language sql stable security definer set search_path = public as $$
  select p.id, p.codigo_muestra, p.nombre, p.carnet, p.fecha_nacimiento, p.fecha_toma, p.tipo_examen, p.hizo_prueba_vph,
    p.anticonceptivo_metodo, p.doctora,
    (select q.resultado_pap || ' (' || to_char(q.fecha_toma, 'YYYY') || ')' from pacientes q
       where coalesce(p.carnet, '') <> '' and q.carnet = p.carnet and q.id <> p.id and q.fecha_toma < p.fecha_toma
         and coalesce(q.resultado_pap, '') <> '' and q.deleted_at is null order by q.fecha_toma desc limit 1),
    l.id, l.codigo, l.centro_id, l.fecha_envio, p.muestra_estado, p.muestra_rechazo, p.fecha_recepcion_muestra,
    p.resultado_pap, p.resultado_vph, p.vph_genotipo, p.informe_lab, p.fecha_informe, p.informado_por
  from pacientes p join lotes l on l.id = p.lote_id
  where sivec_es_lab() and l.destino_id = sivec_centro() and p.deleted_at is null
    and (p_lote is null or l.id = p_lote)
  order by l.fecha_envio, p.codigo_muestra $$;

create or replace function sivec_lab_recibir(p_lote uuid, p_rechazos jsonb, p_recibido_por text)
returns lotes language plpgsql security definer set search_path = public as $$
declare v_lote lotes; v_rech int;
begin
  select * into v_lote from lotes where id = p_lote and destino_id = sivec_centro() and sivec_es_lab();
  if not found then raise exception 'Este lote no fue enviado a su establecimiento.'; end if;
  update pacientes set muestra_estado = 'rechazada', muestra_rechazo = p_rechazos ->> id::text,
         fecha_recepcion_muestra = now(), fecha_informe = now(), informado_por = nullif(trim(p_recibido_por), ''), resultado_visto_at = null
   where lote_id = p_lote and coalesce(p_rechazos, '{}'::jsonb) ? id::text and coalesce(muestra_estado, 'enviada') = 'enviada';
  get diagnostics v_rech = row_count;
  update pacientes set muestra_estado = 'recibida', fecha_recepcion_muestra = now()
   where lote_id = p_lote and coalesce(muestra_estado, 'enviada') = 'enviada';
  update lotes set estado = 'recibido', fecha_recepcion = now(), recibido_por = nullif(trim(p_recibido_por), ''),
         observaciones = case when v_rech > 0 then v_rech || ' muestra(s) rechazada(s)' else observaciones end
   where id = p_lote returning * into v_lote;
  return v_lote;
end $$;

create or replace function sivec_lab_informar(p_id uuid, p_bethesda text, p_texto text, p_vph text, p_genotipo text, p_informe jsonb, p_informado_por text)
returns void language plpgsql security definer set search_path = public as $$
declare v_ok boolean; v_estado text;
begin
  select true into v_ok from pacientes p join lotes l on l.id = p.lote_id
   where p.id = p_id and l.destino_id = sivec_centro() and sivec_es_lab()
     and p.muestra_estado in ('recibida', 'informada', 'insatisfactoria');
  if v_ok is null then raise exception 'La muestra no está recibida en su establecimiento.'; end if;
  v_estado := case when p_bethesda is null then null when p_bethesda = 'NILM' then 'Negativo' when p_bethesda = 'Insatisfactoria' then 'Pendiente' else 'Positivo' end;
  update pacientes set
    resultado_pap = case when p_bethesda is null then resultado_pap else coalesce(nullif(trim(p_texto), ''), p_bethesda) end,
    estado_pap = coalesce(v_estado, estado_pap),
    resultado_vph = coalesce(p_vph, resultado_vph),
    vph_genotipo = case when p_vph = 'Positiva' then nullif(p_genotipo, '') when p_vph = 'Negativa' then null else vph_genotipo end,
    informe_lab = p_informe, fecha_informe = now(), informado_por = nullif(trim(p_informado_por), ''),
    muestra_estado = case when p_bethesda = 'Insatisfactoria' then 'insatisfactoria' else 'informada' end,
    resultado_visto_at = null
  where id = p_id;
end $$;

-- 4) Colposcopia con el permiso nuevo
drop policy if exists "destino ve sus derivadas" on derivaciones;
create policy "destino ve sus derivadas" on derivaciones for select to authenticated using (sivec_es_colpo() and destino_id = sivec_centro());

drop function if exists sivec_derivar(uuid, uuid, text, text, text, text, text);
create or replace function sivec_derivar(p_paciente uuid, p_destino uuid, p_motivo text, p_indicacion text, p_prioridad text, p_notas text, p_por text, p_cobertura text default null, p_monto numeric default null)
returns derivaciones language plpgsql security definer set search_path = public as $$
declare v_p pacientes; v_d derivaciones; v_dest text;
begin
  select * into v_p from pacientes where id = p_paciente and deleted_at is null;
  if not found or not sivec_edita_centro(v_p.centro_id) then raise exception 'Solo el centro de la paciente puede derivarla.'; end if;
  select nombre into v_dest from centros_salud where id = p_destino and hace_colposcopia and activo is not false;
  if v_dest is null then raise exception 'Ese establecimiento no tiene colposcopia habilitada.'; end if;
  if exists (select 1 from derivaciones where paciente_id = p_paciente and estado in ('enviada', 'citada', 'atendida')) then
    raise exception 'Esta toma ya tiene una derivación en curso.'; end if;
  insert into derivaciones (paciente_id, centro_origen, destino_id, motivo, indicacion, prioridad, notas, derivado_por, cobertura, monto)
    values (p_paciente, v_p.centro_id, p_destino, nullif(trim(p_motivo), ''), nullif(trim(p_indicacion), ''), coalesce(nullif(p_prioridad, ''), 'normal'), nullif(trim(p_notas), ''), nullif(trim(p_por), ''), nullif(p_cobertura, ''), case when p_cobertura = 'Sin SUS' then p_monto end)
    returning * into v_d;
  update pacientes set derivacion_pap = v_dest, cobertura = coalesce(nullif(p_cobertura, ''), cobertura) where id = p_paciente;
  return v_d;
end $$;

drop function if exists sivec_colpo_lista();
create or replace function sivec_colpo_lista()
returns table (id uuid, paciente_id uuid, nombre text, carnet text, fecha_nacimiento date, celular text, direccion text,
  centro_origen uuid, motivo text, indicacion text, prioridad text, notas text, derivado_por text, fecha_derivacion date,
  estado text, fecha_cita date, fecha_atencion date, atendido_por text, colposcopia jsonb, biopsia_tomada boolean,
  biopsia_resultado text, tratamiento text, contrarreferencia text, proximo_control text, fecha_contrarreferencia timestamptz, antecedentes text, cobertura text, monto numeric, pago_recibo text)
language sql stable security definer set search_path = public as $$
  select d.id, d.paciente_id, p.nombre, p.carnet, p.fecha_nacimiento, p.celular, p.direccion,
    d.centro_origen, d.motivo, d.indicacion, d.prioridad, d.notas, d.derivado_por, d.fecha_derivacion,
    d.estado, d.fecha_cita, d.fecha_atencion, d.atendido_por, d.colposcopia, d.biopsia_tomada,
    d.biopsia_resultado, d.tratamiento, d.contrarreferencia, d.proximo_control, d.fecha_contrarreferencia,
    (select string_agg(to_char(q.fecha_toma, 'MM/YYYY') || ' ' || coalesce(nullif(q.resultado_pap, ''), 'PAP pendiente')
        || case when q.resultado_vph is not null and q.resultado_vph <> '' then ' · VPH ' || q.resultado_vph || coalesce(' ' || q.vph_genotipo, '') else '' end, '  |  ' order by q.fecha_toma desc)
       from pacientes q where q.deleted_at is null and (q.id = p.id or (coalesce(p.carnet, '') <> '' and q.carnet = p.carnet))),
    d.cobertura, d.monto, d.pago_recibo
  from derivaciones d join pacientes p on p.id = d.paciente_id
  where sivec_es_colpo() and d.destino_id = sivec_centro() and d.estado <> 'cancelada'
  order by (d.prioridad = 'urgente') desc, d.fecha_derivacion $$;

create or replace function sivec_der_cancelar(p_id uuid) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set estado = 'cancelada' where id = p_id and estado in ('enviada', 'citada') and sivec_edita_centro(centro_origen);
  if not found then raise exception 'No se puede cancelar esta derivación.'; end if;
end $$;

create or replace function sivec_der_visto(p_ids uuid[]) returns void language sql security definer set search_path = public as $$
  update derivaciones set visto_origen_at = now() where id = any(p_ids) and sivec_edita_centro(centro_origen) $$;

create or replace function sivec_colpo_etapa(p_paciente uuid, p_etapa text) returns void language sql security definer set search_path = public as $$
  update pacientes set seg_etapa = p_etapa, seg_fechas = coalesce(seg_fechas, '{}'::jsonb) || jsonb_build_object(p_etapa, to_char(current_date, 'YYYY-MM-DD'))
   where id = p_paciente $$;

create or replace function sivec_colpo_cita(p_id uuid, p_fecha date) returns void language plpgsql security definer set search_path = public as $$
declare v_pac uuid;
begin
  update derivaciones set estado = 'citada', fecha_cita = p_fecha
   where id = p_id and sivec_es_colpo() and destino_id = sivec_centro() and estado in ('enviada', 'citada', 'no_asistio')
   returning paciente_id into v_pac;
  if v_pac is null then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
  perform sivec_colpo_etapa(v_pac, 'colpo_agendada');
end $$;

create or replace function sivec_colpo_no_asistio(p_id uuid) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set estado = 'no_asistio', fecha_contrarreferencia = now(), visto_origen_at = null,
         contrarreferencia = coalesce(contrarreferencia, 'La paciente no asistió a la cita: realizar búsqueda activa y volver a citar.')
   where id = p_id and sivec_es_colpo() and destino_id = sivec_centro() and estado in ('enviada', 'citada');
  if not found then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
end $$;

create or replace function sivec_colpo_atender(p_id uuid, p_colpo jsonb, p_biopsia boolean, p_tratamiento text, p_contrarref text, p_proximo text, p_por text, p_enviar boolean)
returns void language plpgsql security definer set search_path = public as $$
declare v_d derivaciones;
begin
  select * into v_d from derivaciones where id = p_id and sivec_es_colpo() and destino_id = sivec_centro() and estado <> 'cancelada';
  if not found then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
  update derivaciones set colposcopia = p_colpo, biopsia_tomada = p_biopsia, tratamiento = nullif(trim(p_tratamiento), ''),
         contrarreferencia = nullif(trim(p_contrarref), ''), proximo_control = nullif(trim(p_proximo), ''),
         atendido_por = nullif(trim(p_por), ''), fecha_atencion = coalesce(fecha_atencion, current_date),
         estado = case when p_enviar then 'contrarreferida' else 'atendida' end,
         fecha_contrarreferencia = case when p_enviar then now() else fecha_contrarreferencia end,
         visto_origen_at = case when p_enviar then null else visto_origen_at end
   where id = p_id;
  perform sivec_colpo_etapa(v_d.paciente_id, case when coalesce(p_tratamiento, '') not in ('', 'Ninguno (control)') then 'tratamiento' else 'colpo_realizada' end);
  -- Compatibilidad: también queda como colposcopia en la ficha (Historia clínica)
  if v_d.fecha_atencion is null then
    begin
      insert into colposcopias (paciente_id, fecha, zona_afectada, lesion, otros_hallazgos, prueba_schiller, centro_id)
      values (v_d.paciente_id, current_date, p_colpo ->> 'zt',
              array(select jsonb_array_elements_text(coalesce(p_colpo -> 'hallazgos', '[]'::jsonb))),
              concat_ws(' · ', 'Impresión: ' || (p_colpo ->> 'impresion'), case when p_biopsia then 'Biopsia tomada' end, p_colpo ->> 'observaciones'),
              p_colpo ->> 'schiller', v_d.destino_id);
    exception when others then null;
    end;
  end if;
end $$;

create or replace function sivec_colpo_biopsia(p_id uuid, p_resultado text) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set biopsia_resultado = nullif(trim(p_resultado), ''), fecha_biopsia_resultado = current_date,
         visto_origen_at = case when estado = 'contrarreferida' then null else visto_origen_at end
   where id = p_id and sivec_es_colpo() and destino_id = sivec_centro() and biopsia_tomada;
  if not found then raise exception 'Derivación sin biopsia o de otro establecimiento.'; end if;
end $$;

create or replace function sivec_colpo_pago(p_id uuid, p_recibo text) returns void language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set pago_recibo = nullif(trim(p_recibo), '') where id = p_id and sivec_es_colpo() and destino_id = sivec_centro();
  if not found then raise exception 'Derivación no encontrada en este establecimiento.'; end if;
end $$;

revoke execute on function sivec_es_lab(), sivec_es_colpo(), sivec_derivar(uuid, uuid, text, text, text, text, text, text, numeric), sivec_colpo_lista(), sivec_colpo_pago(uuid, text) from public, anon;
grant execute on function sivec_es_lab(), sivec_es_colpo(), sivec_derivar(uuid, uuid, text, text, text, text, text, text, numeric), sivec_colpo_lista(), sivec_colpo_pago(uuid, text) to authenticated;
notify pgrst, 'reload schema';
```

---

## Paso 15 — Cobro de la toma de PAP (sin SUS: Bs 30 en la caja del hospital)

Al registrar o editar una toma: **Cobertura** SUS (gratis) o sin SUS (monto, por defecto Bs 30, y N° de recibo de caja).
El Balance muestra cuántas fueron SUS / sin SUS, lo cobrado y cuántas no tienen recibo.

```sql
alter table pacientes add column if not exists cobertura text;
alter table pacientes add column if not exists monto_pago numeric;
alter table pacientes add column if not exists recibo_caja text;
notify pgrst, 'reload schema';
```

---

## Paso 16 — Tablero de la red (gestor y administración)

Botón **Red**: tomas, % de la meta, enviadas al laboratorio, resultados atrasados, positivas sin tratar, días del laboratorio y
cobro sin SUS, por establecimiento y por mes, con descarga en Excel. El **gestor de red** ve solo este tablero (números de su red,
sin fichas de pacientes); la única lista con nombres es la de **positivas sin tratar**, para coordinar la búsqueda activa.
Los administradores ven todas las redes y cargan la **meta anual de PAP** de cada establecimiento en la misma tabla.

```sql
-- 1) Meta anual de PAP de cada establecimiento (la carga el administrador)
alter table centros_salud add column if not exists meta_pap_anual int;

-- 2) Quién puede ver el tablero de la red: gestor (su red) y administradores (todas)
create or replace function sivec_ve_tablero() returns boolean language sql stable security definer set search_path = public as $$
  select sivec_rol() in ('gestor', 'admin') or sivec_es_admin() $$;

create or replace function sivec_centros_tablero() returns setof uuid language sql stable security definer set search_path = public as $$
  select c.id from centros_salud c
   where sivec_ve_tablero() and (sivec_rol() <> 'gestor' or c.red_id = sivec_red()) $$;

-- Una toma es "positiva sin tratar" si el PAP o el VPH salió alterado y todavía no tiene derivación ni colposcopia/tratamiento/alta.
create or replace function sivec_pos_sin_tratar(p pacientes) returns boolean language sql immutable as $$
  select (p.estado_pap = 'Positivo' or p.resultado_vph = 'Positiva')
     and coalesce(p.derivacion_pap, '') = '' and coalesce(p.recibio_tratamiento_vph, false) = false
     and coalesce(p.seg_etapa, '') not in ('colpo_agendada', 'colpo_realizada', 'tratamiento', 'alta') $$;

-- 3) Resumen por establecimiento (solo números)
create or replace function sivec_red_resumen(p_desde date, p_hasta date)
returns table (centro_id uuid, centro text, red text, meta_pap_anual int, tomas bigint, mujeres bigint, enviadas bigint, con_resultado bigint,
  pendientes bigint, atrasadas bigint, positivas bigint, pos_sin_tratar bigint, derivadas bigint, contrarreferidas bigint,
  entregadas bigint, rechazadas bigint, dias_lab numeric, sin_sus bigint, cobrado numeric)
language sql stable security definer set search_path = public as $$
  select c.id, c.nombre, (select r.nombre from redes r where r.id = c.red_id), c.meta_pap_anual,
    count(p.id),
    count(distinct coalesce(nullif(p.carnet, ''), p.id::text)),
    count(p.id) filter (where p.fecha_envio is not null),
    count(p.id) filter (where p.estado_pap in ('Positivo', 'Negativo') or coalesce(p.resultado_vph, '') <> ''),
    count(p.id) filter (where coalesce(p.estado_pap, 'Pendiente') = 'Pendiente' and coalesce(p.tipo_examen, '') <> 'VPH'),
    count(p.id) filter (where coalesce(p.estado_pap, 'Pendiente') = 'Pendiente' and coalesce(p.tipo_examen, '') <> 'VPH'
                          and coalesce(p.fecha_estimada, p.fecha_toma + 90) < current_date),
    count(p.id) filter (where p.estado_pap = 'Positivo' or p.resultado_vph = 'Positiva'),
    count(p.id) filter (where sivec_pos_sin_tratar(p)),
    (select count(*) from derivaciones d join pacientes q on q.id = d.paciente_id
      where d.centro_origen = c.id and d.estado <> 'cancelada' and q.fecha_toma between p_desde and p_hasta),
    (select count(*) from derivaciones d join pacientes q on q.id = d.paciente_id
      where d.centro_origen = c.id and d.estado = 'contrarreferida' and q.fecha_toma between p_desde and p_hasta),
    count(p.id) filter (where p.recibio_resultado),
    count(p.id) filter (where p.muestra_estado in ('rechazada', 'insatisfactoria') or p.resultado_pap ilike '%insatisf%'),
    round(avg(extract(epoch from (p.fecha_informe - p.fecha_envio::timestamptz)) / 86400) filter (where p.fecha_informe is not null and p.fecha_envio is not null)::numeric, 1),
    count(p.id) filter (where p.cobertura = 'Sin SUS'),
    coalesce(sum(p.monto_pago) filter (where p.cobertura = 'Sin SUS'), 0)
  from centros_salud c
  left join pacientes p on p.centro_id = c.id and p.deleted_at is null and p.fecha_toma between p_desde and p_hasta
  where c.id in (select sivec_centros_tablero()) and c.activo is not false
  group by c.id
  order by c.nombre $$;

-- 4) Tomas por mes (toda la red)
create or replace function sivec_red_mensual(p_desde date, p_hasta date)
returns table (mes date, centro_id uuid, tomas bigint)
language sql stable security definer set search_path = public as $$
  select date_trunc('month', p.fecha_toma)::date, p.centro_id, count(*)
  from pacientes p
  where p.deleted_at is null and p.fecha_toma between p_desde and p_hasta and p.centro_id in (select sivec_centros_tablero())
  group by 1, 2 order by 1 $$;

-- 5) Positivas sin tratar: la única lista con nombres (para coordinar la búsqueda activa)
create or replace function sivec_red_pendientes()
returns table (id uuid, centro_id uuid, nombre text, carnet text, celular text, fecha_toma date, resultado_pap text, resultado_vph text,
  vph_genotipo text, fecha_resultado date, seg_etapa text, notificada boolean)
language sql stable security definer set search_path = public as $$
  select p.id, p.centro_id, p.nombre, p.carnet, p.celular, p.fecha_toma, p.resultado_pap, p.resultado_vph, p.vph_genotipo,
    coalesce(p.fecha_informe::date, p.fecha_toma), p.seg_etapa, coalesce(p.recibio_resultado, false)
  from pacientes p
  where p.deleted_at is null and sivec_pos_sin_tratar(p) and p.centro_id in (select sivec_centros_tablero())
  order by p.fecha_toma $$;

revoke execute on function sivec_ve_tablero(), sivec_centros_tablero(), sivec_red_resumen(date, date), sivec_red_mensual(date, date), sivec_red_pendientes() from public, anon;
grant execute on function sivec_ve_tablero(), sivec_centros_tablero(), sivec_red_resumen(date, date), sivec_red_mensual(date, date), sivec_red_pendientes() to authenticated;
notify pgrst, 'reload schema';
```

---

## Paso 17 — Tablero de la red "en vivo" (gráficos y actividad)

El tablero del gestor pasa a tener el estilo del Panel: indicadores animados con anillos y minigráficos, embudo del tamizaje
al tratamiento, tomas por mes (detalle por centro), avance de la meta, Bethesda, PAP/VPH, edad, cobertura, días del laboratorio
y el **feed "Actividad de la red"** (lotes enviados/recibidos, resultados, derivaciones, contrarreferencias; sin nombres).
Se actualiza solo cada 30 segundos y los números pasan del valor anterior al nuevo. Filtro por establecimiento. Requiere el Paso 16.

```sql
-- Tablero de la red "en vivo": detalle para los gráficos y actividad reciente (sin nombres de pacientes)
create or replace function sivec_bethesda(t text) returns text language sql immutable as $$
  select case
    when t is null or trim(t) = '' then null
    when lower(t) ~ 'insatisf' then 'Insatisfactoria'
    when lower(t) ~ 'carcinoma' and lower(t) !~ 'in situ' then 'Carcinoma'
    when lower(t) ~ '\mais\M|adenocarcinoma in situ' then 'AIS'
    when lower(t) ~ '\magc\M|\magus\M|glandulares at' then 'AGC'
    when lower(t) ~ '\mhsil\M|alto grado|\m(nic|cin) ?(2|3|ii|iii)\M|carcinoma in situ' then 'HSIL'
    when lower(t) ~ 'asc ?-? ?h' then 'ASC-H'
    when lower(t) ~ '\mlsil\M|bajo grado|\m(nic|cin) ?(1|i)\M' then 'LSIL'
    when lower(t) ~ 'asc ?-? ?us|ascus' then 'ASC-US'
    when lower(t) ~ 'nilm|negativ' then 'NILM'
    else null end $$;

create or replace function sivec_red_detalle(p_desde date, p_hasta date, p_centro uuid default null) returns jsonb
language sql stable security definer set search_path = public as $$
  with p as (
    select * from pacientes
     where deleted_at is null and fecha_toma between p_desde and p_hasta
       and centro_id in (select sivec_centros_tablero()) and (p_centro is null or centro_id = p_centro)),
  d as (select dv.* from derivaciones dv join p on p.id = dv.paciente_id where dv.estado <> 'cancelada')
  select jsonb_build_object(
    'estado', jsonb_build_object(
       'Negativo', (select count(*) from p where estado_pap = 'Negativo'),
       'Pendiente', (select count(*) from p where coalesce(estado_pap, 'Pendiente') = 'Pendiente' and coalesce(tipo_examen, '') <> 'VPH'),
       'Positivo', (select count(*) from p where estado_pap = 'Positivo')),
    'vph', jsonb_build_object('Negativa', (select count(*) from p where resultado_vph = 'Negativa'), 'Positiva', (select count(*) from p where resultado_vph = 'Positiva'),
       'g16', (select count(*) from p where resultado_vph = 'Positiva' and vph_genotipo ~ '16'), 'g18', (select count(*) from p where resultado_vph = 'Positiva' and vph_genotipo ~ '18')),
    'bethesda', (select coalesce(jsonb_object_agg(b, n), '{}'::jsonb) from (select sivec_bethesda(resultado_pap) b, count(*) n from p where sivec_bethesda(resultado_pap) is not null group by 1) x),
    'edad', (select coalesce(jsonb_object_agg(g, n), '{}'::jsonb) from (
       select case when e < 25 then '< 25' when e < 35 then '25–34' when e < 45 then '35–44' when e < 55 then '45–54' when e < 65 then '55–64' else '65 +' end g, count(*) n
         from (select extract(year from age(fecha_toma, fecha_nacimiento))::int e from p where fecha_nacimiento is not null) y group by 1) x),
    'cobertura', jsonb_build_object('SUS', (select count(*) from p where cobertura = 'SUS'), 'Sin SUS', (select count(*) from p where cobertura = 'Sin SUS'), 'Sin dato', (select count(*) from p where cobertura is null)),
    'embudo', jsonb_build_object(
       'tomas', (select count(*) from p),
       'enviadas', (select count(*) from p where fecha_envio is not null),
       'con_resultado', (select count(*) from p where estado_pap in ('Positivo', 'Negativo') or coalesce(resultado_vph, '') <> ''),
       'entregadas', (select count(*) from p where recibio_resultado),
       'positivas', (select count(*) from p where estado_pap = 'Positivo' or resultado_vph = 'Positiva'),
       'con_conducta', (select count(*) from p where (estado_pap = 'Positivo' or resultado_vph = 'Positiva') and not sivec_pos_sin_tratar(p)),
       'derivadas', (select count(*) from d),
       'atendidas', (select count(*) from d where estado in ('atendida', 'contrarreferida')),
       'tratadas', (select count(*) from d where coalesce(tratamiento, '') not in ('', 'Ninguno (control)'))),
    'lab_mes', (select coalesce(jsonb_agg(jsonb_build_object('mes', m, 'dias', dias) order by m), '[]'::jsonb) from (
       select to_char(date_trunc('month', fecha_toma), 'YYYY-MM') m, round(avg(extract(epoch from (fecha_informe - fecha_envio::timestamptz)) / 86400)::numeric, 1) dias
         from p where fecha_informe is not null and fecha_envio is not null group by 1) x)
  ) where sivec_ve_tablero() $$;

drop function if exists sivec_red_mensual(date, date);
create or replace function sivec_red_mensual(p_desde date, p_hasta date, p_centro uuid default null)
returns table (mes date, centro_id uuid, tomas bigint)
language sql stable security definer set search_path = public as $$
  select date_trunc('month', p.fecha_toma)::date, p.centro_id, count(*)
  from pacientes p
  where p.deleted_at is null and p.fecha_toma between p_desde and p_hasta and p.centro_id in (select sivec_centros_tablero())
    and (p_centro is null or p.centro_id = p_centro)
  group by 1, 2 order by 1 $$;

create or replace function sivec_red_actividad(p_centro uuid default null)
returns table (fecha timestamptz, tipo text, centro_id uuid, otro_id uuid, codigo text, n bigint, alterados bigint)
language sql stable security definer set search_path = public as $$
  with vis as (select sivec_centros_tablero() id)
  select * from (
    select max(p.created_at), 'tomas', p.centro_id, null::uuid, null, count(*), null::bigint
      from pacientes p where p.created_at > now() - interval '21 days' and p.deleted_at is null and p.centro_id in (select id from vis)
      group by p.centro_id, date_trunc('day', p.created_at)
    union all
    select l.created_at, 'lote_enviado', l.centro_id, l.destino_id, l.codigo, l.n_muestras, null from lotes l
      where l.created_at > now() - interval '60 days' and l.centro_id in (select id from vis)
    union all
    select l.fecha_recepcion, 'lote_recibido', l.centro_id, l.destino_id, l.codigo, l.n_muestras, null from lotes l
      where l.fecha_recepcion > now() - interval '60 days' and l.centro_id in (select id from vis)
    union all
    select max(p.fecha_informe), 'resultados', p.centro_id, null, null, count(*), count(*) filter (where p.estado_pap = 'Positivo' or p.resultado_vph = 'Positiva')
      from pacientes p where p.fecha_informe > now() - interval '60 days' and p.centro_id in (select id from vis)
      group by p.centro_id, date_trunc('hour', p.fecha_informe)
    union all
    select d.created_at, 'derivacion', d.centro_origen, d.destino_id, d.prioridad, 1, null from derivaciones d
      where d.created_at > now() - interval '60 days' and d.estado <> 'cancelada' and d.centro_origen in (select id from vis)
    union all
    select d.fecha_contrarreferencia, case when d.estado = 'no_asistio' then 'no_asistio' else 'contrarreferencia' end, d.centro_origen, d.destino_id, d.biopsia_resultado, 1, null from derivaciones d
      where d.fecha_contrarreferencia > now() - interval '60 days' and d.centro_origen in (select id from vis)
  ) x where p_centro is null or x.centro_id = p_centro
  order by 1 desc limit 40 $$;

revoke execute on function sivec_red_detalle(date, date, uuid), sivec_red_mensual(date, date, uuid), sivec_red_actividad(uuid) from public, anon;
grant execute on function sivec_red_detalle(date, date, uuid), sivec_red_mensual(date, date, uuid), sivec_red_actividad(uuid) to authenticated;
notify pgrst, 'reload schema';
```

---

## Paso 18 — Tablero: contar como "enviada" también la toma que ya tiene resultado

Antes del lote digital las láminas se llevaban en papel y no se marcaba la fecha de envío: sin esto el tablero mostraba "0% enviadas".

```sql
-- Una toma cuenta como enviada al laboratorio si tiene fecha de envío o si ya tiene resultado
-- (antes del lote digital las láminas se llevaban en papel y no se marcaba el envío).
create or replace function sivec_enviada(p pacientes) returns boolean language sql immutable as $$
  select p.fecha_envio is not null or p.estado_pap in ('Positivo', 'Negativo')
      or coalesce(p.resultado_pap, '') <> '' or coalesce(p.resultado_vph, '') <> '' $$;

create or replace function sivec_red_resumen(p_desde date, p_hasta date)
returns table (centro_id uuid, centro text, red text, meta_pap_anual int, tomas bigint, mujeres bigint, enviadas bigint, con_resultado bigint,
  pendientes bigint, atrasadas bigint, positivas bigint, pos_sin_tratar bigint, derivadas bigint, contrarreferidas bigint,
  entregadas bigint, rechazadas bigint, dias_lab numeric, sin_sus bigint, cobrado numeric)
language sql stable security definer set search_path = public as $$
  select c.id, c.nombre, (select r.nombre from redes r where r.id = c.red_id), c.meta_pap_anual,
    count(p.id),
    count(distinct coalesce(nullif(p.carnet, ''), p.id::text)),
    count(p.id) filter (where sivec_enviada(p)),
    count(p.id) filter (where p.estado_pap in ('Positivo', 'Negativo') or coalesce(p.resultado_vph, '') <> ''),
    count(p.id) filter (where coalesce(p.estado_pap, 'Pendiente') = 'Pendiente' and coalesce(p.tipo_examen, '') <> 'VPH'),
    count(p.id) filter (where coalesce(p.estado_pap, 'Pendiente') = 'Pendiente' and coalesce(p.tipo_examen, '') <> 'VPH'
                          and coalesce(p.fecha_estimada, p.fecha_toma + 90) < current_date),
    count(p.id) filter (where p.estado_pap = 'Positivo' or p.resultado_vph = 'Positiva'),
    count(p.id) filter (where sivec_pos_sin_tratar(p)),
    (select count(*) from derivaciones d join pacientes q on q.id = d.paciente_id
      where d.centro_origen = c.id and d.estado <> 'cancelada' and q.fecha_toma between p_desde and p_hasta),
    (select count(*) from derivaciones d join pacientes q on q.id = d.paciente_id
      where d.centro_origen = c.id and d.estado = 'contrarreferida' and q.fecha_toma between p_desde and p_hasta),
    count(p.id) filter (where p.recibio_resultado),
    count(p.id) filter (where p.muestra_estado in ('rechazada', 'insatisfactoria') or p.resultado_pap ilike '%insatisf%'),
    round(avg(extract(epoch from (p.fecha_informe - p.fecha_envio::timestamptz)) / 86400) filter (where p.fecha_informe is not null and p.fecha_envio is not null)::numeric, 1),
    count(p.id) filter (where p.cobertura = 'Sin SUS'),
    coalesce(sum(p.monto_pago) filter (where p.cobertura = 'Sin SUS'), 0)
  from centros_salud c
  left join pacientes p on p.centro_id = c.id and p.deleted_at is null and p.fecha_toma between p_desde and p_hasta
  where c.id in (select sivec_centros_tablero()) and c.activo is not false
  group by c.id
  order by c.nombre $$;

create or replace function sivec_red_detalle(p_desde date, p_hasta date, p_centro uuid default null) returns jsonb
language sql stable security definer set search_path = public as $$
  with p as (
    select * from pacientes
     where deleted_at is null and fecha_toma between p_desde and p_hasta
       and centro_id in (select sivec_centros_tablero()) and (p_centro is null or centro_id = p_centro)),
  d as (select dv.* from derivaciones dv join p on p.id = dv.paciente_id where dv.estado <> 'cancelada')
  select jsonb_build_object(
    'estado', jsonb_build_object(
       'Negativo', (select count(*) from p where estado_pap = 'Negativo'),
       'Pendiente', (select count(*) from p where coalesce(estado_pap, 'Pendiente') = 'Pendiente' and coalesce(tipo_examen, '') <> 'VPH'),
       'Positivo', (select count(*) from p where estado_pap = 'Positivo')),
    'vph', jsonb_build_object('Negativa', (select count(*) from p where resultado_vph = 'Negativa'), 'Positiva', (select count(*) from p where resultado_vph = 'Positiva'),
       'g16', (select count(*) from p where resultado_vph = 'Positiva' and vph_genotipo ~ '16'), 'g18', (select count(*) from p where resultado_vph = 'Positiva' and vph_genotipo ~ '18')),
    'bethesda', (select coalesce(jsonb_object_agg(b, n), '{}'::jsonb) from (select sivec_bethesda(resultado_pap) b, count(*) n from p where sivec_bethesda(resultado_pap) is not null group by 1) x),
    'edad', (select coalesce(jsonb_object_agg(g, n), '{}'::jsonb) from (
       select case when e < 25 then '< 25' when e < 35 then '25–34' when e < 45 then '35–44' when e < 55 then '45–54' when e < 65 then '55–64' else '65 +' end g, count(*) n
         from (select extract(year from age(fecha_toma, fecha_nacimiento))::int e from p where fecha_nacimiento is not null) y group by 1) x),
    'cobertura', jsonb_build_object('SUS', (select count(*) from p where cobertura = 'SUS'), 'Sin SUS', (select count(*) from p where cobertura = 'Sin SUS'), 'Sin dato', (select count(*) from p where cobertura is null)),
    'embudo', jsonb_build_object(
       'tomas', (select count(*) from p),
       'enviadas', (select count(*) from p where sivec_enviada(p)),
       'con_resultado', (select count(*) from p where estado_pap in ('Positivo', 'Negativo') or coalesce(resultado_vph, '') <> ''),
       'entregadas', (select count(*) from p where recibio_resultado),
       'positivas', (select count(*) from p where estado_pap = 'Positivo' or resultado_vph = 'Positiva'),
       'con_conducta', (select count(*) from p where (estado_pap = 'Positivo' or resultado_vph = 'Positiva') and not sivec_pos_sin_tratar(p)),
       'derivadas', (select count(*) from d),
       'atendidas', (select count(*) from d where estado in ('atendida', 'contrarreferida')),
       'tratadas', (select count(*) from d where coalesce(tratamiento, '') not in ('', 'Ninguno (control)'))),
    'lab_mes', (select coalesce(jsonb_agg(jsonb_build_object('mes', m, 'dias', dias) order by m), '[]'::jsonb) from (
       select to_char(date_trunc('month', fecha_toma), 'YYYY-MM') m, round(avg(extract(epoch from (fecha_informe - fecha_envio::timestamptz)) / 86400)::numeric, 1) dias
         from p where fecha_informe is not null and fecha_envio is not null group by 1) x)
  ) where sivec_ve_tablero() $$;

notify pgrst, 'reload schema';
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


---

## Ajuste de datos (26/09/2026) — marcar como entregados los resultados de tomas de más de 90 días

Pedido del autor: los resultados de tomas de más de 90 días que ya tienen resultado fueron entregados, pero no se marcaron.
Se marcan como entregados con fecha = toma + 3 meses (toma 03/04 → entrega 03/07). No se tocan las tomas sin resultado
ni las de menos de 90 días. Antes se guarda un respaldo en `respaldo_entregas_2026_09` para poder deshacerlo.

```sql
-- 1) Respaldo: qué tomas se van a marcar (para poder deshacer)
create table if not exists respaldo_entregas_2026_09 as
  select id, recibio_resultado, fecha_recibio_resultado, now() as marcado_el from pacientes where false;
insert into respaldo_entregas_2026_09 (id, recibio_resultado, fecha_recibio_resultado, marcado_el)
  select id, recibio_resultado, fecha_recibio_resultado, now() from pacientes
   where deleted_at is null and coalesce(recibio_resultado, false) = false
     and fecha_toma <= current_date - 90
     and (estado_pap in ('Positivo', 'Negativo') or coalesce(resultado_pap, '') <> '' or coalesce(resultado_vph, '') <> '')
     and id not in (select id from respaldo_entregas_2026_09);

-- 2) Marcar como entregado, con fecha = toma + 3 meses (toma 03/04 → entrega 03/07)
with u as (
  update pacientes p set recibio_resultado = true,
         fecha_recibio_resultado = coalesce(p.fecha_recibio_resultado, (p.fecha_toma + interval '3 months')::date)
   where p.id in (select id from respaldo_entregas_2026_09) and coalesce(p.recibio_resultado, false) = false
  returning 1)
select (select count(*) from u) as marcadas_ahora,
       (select count(*) from pacientes where deleted_at is null and coalesce(estado_pap, 'Pendiente') = 'Pendiente'
          and coalesce(resultado_pap, '') = '' and coalesce(resultado_vph, '') = '' and fecha_toma <= current_date - 90) as sin_resultado_mas_de_90_dias,
       (select count(*) from pacientes where deleted_at is null and fecha_toma > current_date - 90) as tomas_de_menos_de_90_dias;
```

### Deshacer

```sql
update pacientes p set recibio_resultado = r.recibio_resultado, fecha_recibio_resultado = r.fecha_recibio_resultado
  from respaldo_entregas_2026_09 r where r.id = p.id;
```

## Ajuste de datos (26/09/2026) — todas las tomas de San Luis como enviadas al Oncológico e informadas

Pedido del autor: todas las muestras se enviaron al Oncológico (antes en papel); se registran como enviadas en la fecha de la toma,
en lotes históricos mensuales `L-HIST-AAAA-MM` ya recibidos. Las que tienen resultado quedan **informadas** en el portal del laboratorio
(devueltas a San Luis, sin aviso de "resultado nuevo": `fecha_informe` queda vacía); las que no tienen resultado quedan **Por leer**.
Respaldo en `respaldo_envios_2026_09`. Es idempotente.

```sql
-- 0) Respaldo de lo que cambia (para poder deshacer)
create table if not exists respaldo_envios_2026_09 as
  select id, fecha_envio, lote_id, lote_envio, codigo_muestra, muestra_estado, fecha_recepcion_muestra, informado_por, informe_lab
    from pacientes where false;
insert into respaldo_envios_2026_09
  select id, fecha_envio, lote_id, lote_envio, codigo_muestra, muestra_estado, fecha_recepcion_muestra, informado_por, informe_lab
    from pacientes p
   where p.deleted_at is null and p.lote_id is null and p.fecha_toma is not null
     and p.centro_id = sivec_san_luis()
     and not exists (select 1 from respaldo_envios_2026_09 r where r.id = p.id);

-- 1) Un lote histórico por mes: San Luis → Oncológico, ya recibido
insert into lotes (codigo, centro_id, destino_id, fecha_envio, transporte, entregado_por, n_muestras, estado, recibido_por, fecha_recepcion, observaciones, created_at)
  select 'L-HIST-' || to_char(date_trunc('month', p.fecha_toma), 'YYYY-MM'), sivec_san_luis(),
         (select id from centros_salud where recibe_muestras order by created_at nulls last limit 1),
         max(p.fecha_toma), 'En papel (antes del SIVEC)', 'Registro histórico', count(*), 'recibido', 'Registro histórico',
         max(p.fecha_toma)::timestamptz, 'Envíos anteriores al lote digital, cargados el 26/09/2026', max(p.fecha_toma)::timestamptz
    from pacientes p where p.id in (select id from respaldo_envios_2026_09)
   group by date_trunc('month', p.fecha_toma)
  on conflict (codigo) do nothing;

-- 2) Cada toma a su lote: enviada el día de la toma; con resultado = informada; sin resultado = en el laboratorio
with h as (
  select p.id, 'H-' || to_char(p.fecha_toma, 'YY') || '-' || lpad((row_number() over (order by p.fecha_toma, p.created_at, p.id))::text, 6, '0') cod
    from pacientes p where p.id in (select id from respaldo_envios_2026_09) and p.lote_id is null)
update pacientes p set
  lote_id = l.id, lote_envio = l.codigo,
  fecha_envio = coalesce(p.fecha_envio, p.fecha_toma),
  codigo_muestra = coalesce(p.codigo_muestra, h.cod),
  fecha_recepcion_muestra = coalesce(p.fecha_recepcion_muestra, p.fecha_toma::timestamptz),
  muestra_estado = case
    when p.estado_pap in ('Positivo', 'Negativo') or coalesce(p.resultado_pap, '') <> '' or coalesce(p.resultado_vph, '') <> ''
      then case when p.resultado_pap ilike '%insatisf%' then 'insatisfactoria' else 'informada' end
    else 'recibida' end,
  informado_por = case when p.estado_pap in ('Positivo', 'Negativo') or coalesce(p.resultado_pap, '') <> '' or coalesce(p.resultado_vph, '') <> ''
    then coalesce(p.informado_por, 'Registro histórico (papel)') else p.informado_por end,
  informe_lab = coalesce(p.informe_lab, jsonb_build_object('historico', true, 'fuente', 'papel', 'bethesda', sivec_bethesda(p.resultado_pap)))
from h, lotes l
where p.id = h.id and l.codigo = 'L-HIST-' || to_char(date_trunc('month', p.fecha_toma), 'YYYY-MM');

-- 3) Resultado
select count(*) filter (where lote_envio like 'L-HIST-%') as tomas_en_lotes_historicos,
       count(*) filter (where lote_envio like 'L-HIST-%' and muestra_estado = 'informada') as informadas,
       count(*) filter (where lote_envio like 'L-HIST-%' and muestra_estado = 'insatisfactoria') as insatisfactorias,
       count(*) filter (where lote_envio like 'L-HIST-%' and muestra_estado = 'recibida') as en_el_laboratorio_sin_resultado,
       (select count(*) from lotes where codigo like 'L-HIST-%') as lotes_historicos
  from pacientes where deleted_at is null;
```

Deshacer:

```sql
update pacientes p set fecha_envio = r.fecha_envio, lote_id = r.lote_id, lote_envio = r.lote_envio, codigo_muestra = r.codigo_muestra,
       muestra_estado = r.muestra_estado, fecha_recepcion_muestra = r.fecha_recepcion_muestra, informado_por = r.informado_por, informe_lab = r.informe_lab
  from respaldo_envios_2026_09 r where r.id = p.id;
delete from lotes where codigo like 'L-HIST-%';
```

## Paso 19 — Cada uno en su función (administrador general, gestor de red, médico del centro) + profesionales por establecimiento

El administrador queda sin centro ni red: ve el tablero general de todas las redes (con tomas por profesional) y la administración.
Las contraseñas provisorias NO se guardan en este archivo: reemplazar `<clave>` al ejecutar. Cada uno la cambia con el botón 🔑 del encabezado.

```sql
-- PASO 19 · Cada uno en su función: administrador general, gestor de la Red Centro y médico de San Luis
-- A) Profesionales de cada establecimiento (los carga el administrador)
alter table centros_salud add column if not exists profesionales text[] not null default '{}';
update centros_salud set profesionales = array['Dra. Ortuño', 'Dra. Aguilera', 'Dra. Delina', 'Dr. Tola']
 where id = sivec_san_luis() and profesionales = '{}';

-- B) Tomas por profesional para el tablero (gestor: su red; administrador: todas)
create or replace function sivec_red_profesionales(p_desde date, p_hasta date, p_centro uuid default null)
returns table (centro_id uuid, profesional text, tomas bigint, positivas bigint, entregadas bigint)
language sql stable security definer set search_path = public as $$
  select p.centro_id, coalesce(nullif(trim(p.doctora), ''), 'Sin profesional'), count(*),
         count(*) filter (where p.estado_pap = 'Positivo' or p.resultado_vph = 'Positiva'),
         count(*) filter (where p.recibio_resultado)
    from pacientes p
   where p.deleted_at is null and p.fecha_toma between p_desde and p_hasta
     and p.centro_id in (select sivec_centros_tablero()) and (p_centro is null or p.centro_id = p_centro)
   group by 1, 2 $$;
revoke execute on function sivec_red_profesionales(date, date, uuid) from public, anon;
grant execute on function sivec_red_profesionales(date, date, uuid) to authenticated;

-- C) Cuentas: una para cada función
do $$
declare
  u record;
  v_uid uuid;
  v_red uuid := (select id from redes where nombre ilike '%centro%' order by created_at nulls last limit 1);
begin
  -- Administrador general: sin centro ni red (ve todo, configura todo). Conserva su contraseña.
  update perfiles_usuario set rol = 'admin', es_admin = true, centro_id = null, red_id = null, activo = true,
         puede_laboratorio = false, puede_colposcopia = false
   where id in (select id from auth.users where lower(email) = 'rferreiramedicine@gmail.com');
  -- Nadie más administra "de costado": el administrador es un perfil propio.
  update perfiles_usuario set es_admin = false
   where rol <> 'admin' and id not in (select id from auth.users where lower(email) = 'rferreiramedicine@gmail.com');

  for u in select * from (values
      ('medico.sanluis@sivec.bo',  '<clave>', 'Médico · C.S. San Luis',  'centro'),
      ('gestor.redcentro@sivec.bo', '<clave>',  'Gestor · Red Centro',     'gestor')) t(correo, clave, nombre, rol)
  loop
    select id into v_uid from auth.users where lower(email) = u.correo;
    if v_uid is null then
      v_uid := gen_random_uuid();
      insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
        raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change, email_change_token_new, recovery_token)
      values ('00000000-0000-0000-0000-000000000000', v_uid, 'authenticated', 'authenticated', u.correo,
        extensions.crypt(u.clave, extensions.gen_salt('bf')), now(),
        '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');
      insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
      values (gen_random_uuid(), v_uid, v_uid::text, jsonb_build_object('sub', v_uid::text, 'email', u.correo, 'email_verified', true),
        'email', now(), now(), now());
    end if;
    insert into perfiles_usuario (id, correo, nombre_completo, rol, activo)
      select v_uid, u.correo, u.nombre, u.rol, true where not exists (select 1 from perfiles_usuario where id = v_uid);
    update perfiles_usuario set rol = u.rol, nombre_completo = u.nombre, activo = true, es_admin = false,
           centro_id = case when u.rol = 'centro' then sivec_san_luis() end,
           red_id = case when u.rol = 'gestor' then v_red end
     where id = v_uid;
  end loop;
end $$;

notify pgrst, 'reload schema';

-- Resultado
select coalesce(nombre_completo, '') as nombre, correo, rol,
       coalesce((select nombre from centros_salud c where c.id = centro_id), (select nombre from redes r where r.id = red_id), 'Todas las redes') as lugar,
       es_admin, activo
  from perfiles_usuario order by rol, correo;
```

## Paso 20 — Ubicación de cada establecimiento en el mapa

El administrador marca en el Mapa (📍 Ubicar establecimiento…) dónde queda cada centro, hospital y el oncológico.
El centro ve su ícono como punto de partida; el gestor, los de su red; el administrador, todos más el área de cada red.

```sql
alter table centros_salud add column if not exists lat double precision;
alter table centros_salud add column if not exists lng double precision;
notify pgrst, 'reload schema';
select nombre, lat, lng from centros_salud order by nombre;
```

## Paso 21 — Dirección de cada establecimiento (Red Centro precargada) y ubicación del Oncológico

Con la dirección, el botón 🛰 **Buscar ubicaciones** del Mapa (administrador) ubica cada establecimiento de forma aproximada; después se ajusta arrastrando el ícono.

```sql
-- PASO 21 · Dirección de cada establecimiento (para ubicarlo en el mapa) + direcciones de la Red Centro
alter table centros_salud add column if not exists direccion text;
alter table centros_salud add column if not exists lat double precision;
alter table centros_salud add column if not exists lng double precision;

update centros_salud c set direccion = v.dir
  from (values
    ('%elvira%',        'Av. Trompillo, a 2 cuadras del 2do anillo (C. Yacuiba)'),
    ('%perpetuo%',      'Barrio Los Chinos, entre Av. Busch y Av. Roca y Coronado'),
    ('%roque%',         'C. Santiago Vaca Guzmán #319, esq. pasillo 1, barrio Mac Donald'),
    ('%san carlos%',    'C. Sor Estéfana Cámara, radial 27, entre 3er y 4to anillo'),
    ('%san luis%',      'Barrio Bibosi'),
    ('%santa rosita%',  'C. Mataral, barrio Santa Rosita, UV-30'),
    ('%cotoca%',        'C. San Pedro'),
    ('%f_tima%',        'Villa Fátima, Av. Pilcomayo, entre 2do y 3er anillo'),
    ('%lemaitre%',      'C. 7 Oeste'),
    ('%oncol%',         'Av. Noel Kempff Mercado #890, 3er anillo interno')) v(patron, dir)
 where c.nombre ilike v.patron and c.direccion is null;

-- El Oncológico ya con su ubicación (Google Maps)
update centros_salud set lat = -17.763879, lng = -63.194321
 where nombre ilike '%oncol%' and lat is null;

notify pgrst, 'reload schema';
select nombre, direccion, lat, lng from centros_salud order by nombre;
```

## Paso 22 — Protección de datos: cada centro lee solo lo suyo + línea de tiempo entre centros (reemplaza al Paso 9)

- Centro: lee y edita solo sus pacientes. Gestor: lee las de su red. Administrador: lee todas (no edita). Sin sesión: nada.
- Tablas viejas o de respaldo sin reglas: quedan cerradas (solo el administrador las lee).
- Línea de tiempo: si la misma mujer (carnet, o nombre + fecha de nacimiento) se hizo tomas en otro centro, la ficha las muestra (solo el resumen) y el registro avisa. Cada consulta queda guardada en `historial_accesos`.

```sql
-- PASO 22 · Protección de datos: cada centro lee solo lo suyo + línea de tiempo entre centros
-- A) Quién ve qué (el administrador ahora puede LEER todo; solo el centro registra y edita lo suyo)
create or replace function sivec_ve_centro(c uuid) returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(case sivec_rol()
    when 'centro' then c = sivec_centro()
    when 'gestor' then exists (select 1 from centros_salud where id = c and red_id = sivec_red())
    when 'admin'  then true
    else false end, false) $$;

-- B) Reglas en la base de datos (reemplazan a todas las anteriores de estas tablas)
do $$ declare r record; begin
  for r in select policyname, tablename from pg_policies where schemaname = 'public' and tablename in ('pacientes', 'colposcopias', 'consultas') loop
    execute format('drop policy %I on %I', r.policyname, r.tablename);
  end loop;
end $$;
alter table pacientes enable row level security;
alter table colposcopias enable row level security;
alter table consultas enable row level security;
create policy "ver por centro" on pacientes for select to authenticated using (sivec_ve_centro(centro_id));
create policy "registrar en su centro" on pacientes for insert to authenticated with check (sivec_edita_centro(centro_id));
create policy "editar en su centro" on pacientes for update to authenticated using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));
create policy "borrar en su centro" on pacientes for delete to authenticated using (sivec_edita_centro(centro_id));
create policy "ver por centro" on colposcopias for select to authenticated using (
  exists (select 1 from pacientes p where p.id = colposcopias.paciente_id and sivec_ve_centro(p.centro_id)));
create policy "editar por centro" on colposcopias for all to authenticated
  using (exists (select 1 from pacientes p where p.id = colposcopias.paciente_id and sivec_edita_centro(p.centro_id)))
  with check (exists (select 1 from pacientes p where p.id = colposcopias.paciente_id and sivec_edita_centro(p.centro_id)));
create policy "ver por centro" on consultas for select to authenticated using (
  exists (select 1 from pacientes p where p.id::text = consultas.paciente_id::text and sivec_ve_centro(p.centro_id)));
create policy "editar por centro" on consultas for all to authenticated
  using (exists (select 1 from pacientes p where p.id::text = consultas.paciente_id::text and sivec_edita_centro(p.centro_id)))
  with check (exists (select 1 from pacientes p where p.id::text = consultas.paciente_id::text and sivec_edita_centro(p.centro_id)));

-- C) Tablas viejas o de respaldo: cerradas (solo el administrador las lee). Sin reglas, cualquiera con la clave podía leerlas.
do $$ declare t text; begin
  for t in select tablename from pg_tables where schemaname = 'public' and not rowsecurity loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "solo administrador" on %I', t);
    execute format('create policy "solo administrador" on %I for select to authenticated using (sivec_es_admin())', t);
  end loop;
end $$;

-- D) Línea de tiempo entre centros: la misma mujer (mismo carnet, o mismo nombre + fecha de nacimiento)
--    se ve en la ficha aunque se haya hecho la toma en otro centro. Solo resumen clínico, y queda registrado quién consultó.
create or replace function sivec_norm(t text) returns text language sql immutable as $$
  select btrim(regexp_replace(translate(lower(coalesce(t, '')), 'áàäâãéèëêíìïîóòöôõúùüûñç', 'aaaaaeeeeiiiiooooouuuunc'), '\s+', ' ', 'g')) $$;
create or replace function sivec_norm_ci(t text) returns text language sql immutable as $$
  select nullif(regexp_replace(regexp_replace(sivec_norm(t), '[^a-z0-9]', '', 'g'), '^([0-9]{4,})(lp|sc|scz|cb|or|pt|ch|tj|be|pd)$', '\1'), '') $$;

create table if not exists historial_accesos (
  id bigserial primary key, usuario uuid default auth.uid(), centro_id uuid, carnet text, nombre text,
  encontrados int, created_at timestamptz not null default now());
alter table historial_accesos enable row level security;
drop policy if exists "solo administrador" on historial_accesos;
create policy "solo administrador" on historial_accesos for select to authenticated using (sivec_es_admin());

create or replace function sivec_linea_tiempo(p_carnet text, p_nombre text, p_nac date) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_ci text := sivec_norm_ci(p_carnet);
  v_nom text := sivec_norm(p_nombre);
  v jsonb;
begin
  if sivec_rol() not in ('centro', 'gestor', 'admin') then return '[]'::jsonb; end if;
  if v_ci is not null and (length(v_ci) < 5 or v_ci ~ '^0+$') then v_ci := null; end if;
  if v_ci is null and (v_nom = '' or p_nac is null) then return '[]'::jsonb; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', p.id, 'centro_id', p.centro_id, 'centro', c.nombre, 'fecha_toma', p.fecha_toma, 'tipo_examen', p.tipo_examen,
           'estado_pap', p.estado_pap, 'resultado_pap', p.resultado_pap, 'resultado_vph', p.resultado_vph, 'vph_genotipo', p.vph_genotipo,
           'recibio_resultado', p.recibio_resultado, 'fecha_recibio_resultado', p.fecha_recibio_resultado,
           'derivacion_pap', p.derivacion_pap, 'seg_etapa', p.seg_etapa, 'doctora', p.doctora) order by p.fecha_toma), '[]'::jsonb)
    into v
    from pacientes p left join centros_salud c on c.id = p.centro_id
   where p.deleted_at is null and not sivec_ve_centro(p.centro_id)
     and ((v_ci is not null and sivec_norm_ci(p.carnet) = v_ci)
       or (p_nac is not null and v_nom <> '' and p.fecha_nacimiento = p_nac and sivec_norm(p.nombre) = v_nom));
  if jsonb_array_length(v) > 0 then
    insert into historial_accesos (centro_id, carnet, nombre, encontrados) values (sivec_centro(), p_carnet, p_nombre, jsonb_array_length(v));
  end if;
  return v;
end $$;
revoke execute on function sivec_linea_tiempo(text, text, date) from public, anon;
grant execute on function sivec_linea_tiempo(text, text, date) to authenticated;

notify pgrst, 'reload schema';

-- Resultado: reglas activas
select tablename as tabla, count(*) as reglas, bool_and(t.rowsecurity) as protegida
  from pg_policies p join pg_tables t using (schemaname, tablename)
 where schemaname = 'public' group by tablename order by tablename;
```

### Deshacer el Paso 22

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

## Paso 23 — Línea de tiempo completa: de la toma al tratamiento (requiere los Pasos 10, 12, 13 y 22)

La ficha de la paciente muestra cada paso como un evento propio: toma → muestra enviada (lote) → recibida o rechazada en el laboratorio →
informe firmado → resultado entregado → derivada a colposcopia → cita → colposcopia → biopsia → contrarreferencia → derivada a tratamiento → tratamiento realizado.
La parte del propio centro ya estaba guardada; este paso agrega el mismo recorrido cuando la mujer se atendió en **otro** establecimiento
(solo lectura, y cada consulta queda en `historial_accesos`).

```sql
-- PASO 23 · Línea de tiempo completa: envío, laboratorio, derivación, colposcopia, biopsia, tratamiento y contrarreferencia
-- A) Lo que el centro ve de otros establecimientos ahora incluye el recorrido de cada toma (sigue siendo solo lectura y queda registrado)
create or replace function sivec_linea_tiempo(p_carnet text, p_nombre text, p_nac date) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_ci text := sivec_norm_ci(p_carnet);
  v_nom text := sivec_norm(p_nombre);
  v jsonb;
begin
  if sivec_rol() not in ('centro', 'gestor', 'admin') then return '[]'::jsonb; end if;
  if v_ci is not null and (length(v_ci) < 5 or v_ci ~ '^0+$') then v_ci := null; end if;
  if v_ci is null and (v_nom = '' or p_nac is null) then return '[]'::jsonb; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', p.id, 'centro_id', p.centro_id, 'centro', c.nombre, 'fecha_toma', p.fecha_toma, 'tipo_examen', p.tipo_examen,
           'estado_pap', p.estado_pap, 'resultado_pap', p.resultado_pap, 'resultado_vph', p.resultado_vph, 'vph_genotipo', p.vph_genotipo,
           'recibio_resultado', p.recibio_resultado, 'fecha_recibio_resultado', p.fecha_recibio_resultado,
           'derivacion_pap', p.derivacion_pap, 'seg_etapa', p.seg_etapa, 'doctora', p.doctora,
           -- recorrido de la muestra
           'fecha_envio', p.fecha_envio, 'lote_envio', p.lote_envio, 'laboratorio', lab.nombre,
           'fecha_recepcion_muestra', p.fecha_recepcion_muestra, 'muestra_estado', p.muestra_estado, 'muestra_rechazo', p.muestra_rechazo,
           'fecha_informe', p.fecha_informe, 'informado_por', p.informado_por,
           -- derivaciones a colposcopia y su contrarreferencia
           'derivaciones', (select coalesce(jsonb_agg(jsonb_build_object(
                'destino', dc.nombre, 'fecha_derivacion', d.fecha_derivacion, 'motivo', d.motivo, 'indicacion', d.indicacion,
                'prioridad', d.prioridad, 'estado', d.estado, 'fecha_cita', d.fecha_cita, 'fecha_atencion', d.fecha_atencion,
                'atendido_por', d.atendido_por, 'colposcopia', d.colposcopia, 'biopsia_tomada', d.biopsia_tomada,
                'biopsia_resultado', d.biopsia_resultado, 'fecha_biopsia_resultado', d.fecha_biopsia_resultado,
                'tratamiento', d.tratamiento, 'contrarreferencia', d.contrarreferencia, 'proximo_control', d.proximo_control,
                'fecha_contrarreferencia', d.fecha_contrarreferencia) order by d.created_at), '[]'::jsonb)
              from derivaciones d left join centros_salud dc on dc.id = d.destino_id
             where d.paciente_id = p.id and d.estado <> 'cancelada')
         ) order by p.fecha_toma), '[]'::jsonb)
    into v
    from pacientes p
    left join centros_salud c on c.id = p.centro_id
    left join lotes l on l.id = p.lote_id
    left join centros_salud lab on lab.id = l.destino_id
   where p.deleted_at is null and not sivec_ve_centro(p.centro_id)
     and ((v_ci is not null and sivec_norm_ci(p.carnet) = v_ci)
       or (p_nac is not null and v_nom <> '' and p.fecha_nacimiento = p_nac and sivec_norm(p.nombre) = v_nom));
  if jsonb_array_length(v) > 0 then
    insert into historial_accesos (centro_id, carnet, nombre, encontrados) values (sivec_centro(), p_carnet, p_nombre, jsonb_array_length(v));
  end if;
  return v;
end $$;
revoke execute on function sivec_linea_tiempo(text, text, date) from public, anon;
grant execute on function sivec_linea_tiempo(text, text, date) to authenticated;

-- B) El centro puede leer los lotes que envió (para mostrar a qué laboratorio fue cada muestra)
grant select on lotes to authenticated;

-- C) Para que la ficha abra rápido
create index if not exists pacientes_lote_idx on pacientes (lote_id);
create index if not exists colposcopias_paciente_idx on colposcopias (paciente_id);

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when pg_get_functiondef('sivec_linea_tiempo(text, text, date)'::regprocedure) like '%derivaciones%' then 'listo' else 'revisar' end as paso_23;
```

### Deshacer el Paso 23
Volver a ejecutar solo la parte **D)** del Paso 22 (la función `sivec_linea_tiempo` anterior). Los índices pueden quedar.


---

## Paso 24 — Prueba de VPH por autotoma y laboratorio propio, de otro establecimiento o externo (requiere los Pasos 10, 12, 14, 22 y 23)

- Al registrar la toma: **forma de toma del VPH** (autotoma vaginal o toma por profesional) y, si es autotoma, **dónde** (en el establecimiento o en casa con kit, con fecha de entrega y devolución).
- Un kit que sigue en casa no entra en un lote hasta que se marca **Devuelto**.
- Al armar el lote: **laboratorio propio**, **otro establecimiento del SIVEC** u **otro laboratorio fuera del SIVEC** (se escribe el nombre; el resultado se carga a mano en la ficha).
- En Admin → Establecimientos se marca qué pruebas procesa cada laboratorio (**PAP**, **VPH**).
- El laboratorio informa las muestras solo de VPH sin Bethesda y anota la prueba usada (GeneXpert, cobas, careHPV…).

```sql
-- PASO 24 · Prueba de VPH: autotoma (en el establecimiento o en casa con kit) y laboratorio propio, de otro establecimiento o fuera del SIVEC
-- A) Cómo se tomó la muestra de VPH
alter table pacientes add column if not exists vph_modo text;            -- 'Profesional' (cervical) · 'Autotoma' (vaginal)
alter table pacientes add column if not exists vph_lugar text;           -- 'Establecimiento' · 'Casa'
alter table pacientes add column if not exists vph_kit_entregado date;   -- autotoma en casa: día que se llevó el kit
alter table pacientes add column if not exists vph_kit_devuelto date;    -- día que devolvió la muestra (antes no entra en un lote)

-- B) Qué pruebas procesa cada laboratorio, y laboratorios fuera del SIVEC
alter table centros_salud add column if not exists lab_pruebas text[];
update centros_salud set lab_pruebas = array['PAP', 'VPH'] where recibe_muestras and lab_pruebas is null;
alter table lotes add column if not exists destino_externo text;          -- laboratorio que no usa el SIVEC (el centro carga el resultado a mano)
alter table lotes alter column destino_id drop not null;

-- C) Armar el lote: destino del SIVEC (propio u otro establecimiento) o externo; los kits que siguen en casa no entran
drop function if exists sivec_armar_lote(uuid[], uuid, date, text, text);
create or replace function sivec_armar_lote(p_ids uuid[], p_destino uuid, p_fecha date, p_transporte text, p_entregado text, p_externo text default null)
returns lotes language plpgsql security invoker set search_path = public as $$
declare v_centro uuid; v_lote lotes; v_n int;
begin
  if p_destino is null and nullif(trim(coalesce(p_externo, '')), '') is null then raise exception 'Elegí el laboratorio de destino.'; end if;
  if exists (select 1 from pacientes where id = any(p_ids) and vph_lugar = 'Casa' and vph_kit_devuelto is null) then
    raise exception 'Hay kits de autotoma que la paciente todavía no devolvió: marcá la fecha de devolución antes de enviarlos.'; end if;
  select min(centro_id::text)::uuid, count(*) into v_centro, v_n from pacientes where id = any(p_ids) and lote_id is null and deleted_at is null;
  if v_n = 0 then raise exception 'Ninguna de las muestras marcadas está libre (ya estaban en otro lote).'; end if;
  if (select count(distinct centro_id) from pacientes where id = any(p_ids) and lote_id is null) > 1 then raise exception 'Todas las muestras de un lote tienen que ser del mismo centro.'; end if;
  insert into lotes (codigo, centro_id, destino_id, destino_externo, fecha_envio, transporte, entregado_por, n_muestras)
    values ('L-' || to_char(coalesce(p_fecha, current_date), 'YYYY') || '-' || lpad(nextval('lote_seq')::text, 4, '0'),
            v_centro, p_destino, case when p_destino is null then nullif(trim(p_externo), '') end,
            coalesce(p_fecha, current_date), nullif(trim(p_transporte), ''), nullif(trim(p_entregado), ''), v_n)
    returning * into v_lote;
  update pacientes p set lote_id = v_lote.id, lote_envio = v_lote.codigo, fecha_envio = v_lote.fecha_envio, muestra_estado = 'enviada',
         codigo_muestra = coalesce(p.codigo_muestra, 'M-' || to_char(coalesce(p_fecha, current_date), 'YY') || '-' || lpad(nextval('muestra_seq')::text, 6, '0'))
   where p.id = any(p_ids) and p.lote_id is null and p.deleted_at is null;
  get diagnostics v_n = row_count;
  if v_n <> v_lote.n_muestras then raise exception 'No se pudieron marcar todas las muestras (permisos del centro).'; end if;
  return v_lote;
end $$;
revoke execute on function sivec_armar_lote(uuid[], uuid, date, text, text, text) from public, anon;
grant execute on function sivec_armar_lote(uuid[], uuid, date, text, text, text) to authenticated;

-- D) El laboratorio ve si la muestra de VPH es autotoma
drop function if exists sivec_lab_muestras(uuid);
create or replace function sivec_lab_muestras(p_lote uuid default null)
returns table (id uuid, codigo_muestra text, nombre text, carnet text, fecha_nacimiento date, fecha_toma date,
  tipo_examen text, hizo_prueba_vph boolean, anticonceptivo_metodo text, doctora text, pap_anterior text,
  lote_id uuid, lote_codigo text, centro_id uuid, fecha_envio date, muestra_estado text, muestra_rechazo text,
  fecha_recepcion_muestra timestamptz, resultado_pap text, resultado_vph text, vph_genotipo text,
  informe_lab jsonb, fecha_informe timestamptz, informado_por text, estado_pap text, vph_modo text, vph_lugar text)
language sql stable security definer set search_path = public as $$
  select p.id, p.codigo_muestra, p.nombre, p.carnet, p.fecha_nacimiento, p.fecha_toma, p.tipo_examen, p.hizo_prueba_vph,
    p.anticonceptivo_metodo, p.doctora,
    (select q.resultado_pap || ' (' || to_char(q.fecha_toma, 'YYYY') || ')' from pacientes q
       where coalesce(p.carnet, '') <> '' and q.carnet = p.carnet and q.id <> p.id and q.fecha_toma < p.fecha_toma
         and coalesce(q.resultado_pap, '') <> '' and q.deleted_at is null order by q.fecha_toma desc limit 1),
    l.id, l.codigo, l.centro_id, l.fecha_envio, p.muestra_estado, p.muestra_rechazo, p.fecha_recepcion_muestra,
    p.resultado_pap, p.resultado_vph, p.vph_genotipo, p.informe_lab, p.fecha_informe, p.informado_por,
    p.estado_pap, p.vph_modo, p.vph_lugar
  from pacientes p join lotes l on l.id = p.lote_id
  where sivec_es_lab() and l.destino_id = sivec_centro() and p.deleted_at is null
    and (p_lote is null or l.id = p_lote)
  order by l.fecha_envio, p.codigo_muestra $$;
revoke execute on function sivec_lab_muestras(uuid) from public, anon;
grant execute on function sivec_lab_muestras(uuid) to authenticated;

-- E) Línea de tiempo entre centros: también la forma de toma del VPH y el laboratorio externo
create or replace function sivec_linea_tiempo(p_carnet text, p_nombre text, p_nac date) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_ci text := sivec_norm_ci(p_carnet);
  v_nom text := sivec_norm(p_nombre);
  v jsonb;
begin
  if sivec_rol() not in ('centro', 'gestor', 'admin') then return '[]'::jsonb; end if;
  if v_ci is not null and (length(v_ci) < 5 or v_ci ~ '^0+$') then v_ci := null; end if;
  if v_ci is null and (v_nom = '' or p_nac is null) then return '[]'::jsonb; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', p.id, 'centro_id', p.centro_id, 'centro', c.nombre, 'fecha_toma', p.fecha_toma, 'tipo_examen', p.tipo_examen,
           'estado_pap', p.estado_pap, 'resultado_pap', p.resultado_pap, 'resultado_vph', p.resultado_vph, 'vph_genotipo', p.vph_genotipo,
           'recibio_resultado', p.recibio_resultado, 'fecha_recibio_resultado', p.fecha_recibio_resultado,
           'derivacion_pap', p.derivacion_pap, 'seg_etapa', p.seg_etapa, 'doctora', p.doctora,
           'hizo_prueba_vph', p.hizo_prueba_vph, 'vph_modo', p.vph_modo, 'vph_lugar', p.vph_lugar,
           'vph_kit_entregado', p.vph_kit_entregado, 'vph_kit_devuelto', p.vph_kit_devuelto,
           'fecha_envio', p.fecha_envio, 'lote_envio', p.lote_envio, 'laboratorio', coalesce(lab.nombre, l.destino_externo),
           'fecha_recepcion_muestra', p.fecha_recepcion_muestra, 'muestra_estado', p.muestra_estado, 'muestra_rechazo', p.muestra_rechazo,
           'fecha_informe', p.fecha_informe, 'informado_por', p.informado_por,
           'derivaciones', (select coalesce(jsonb_agg(jsonb_build_object(
                'destino', dc.nombre, 'fecha_derivacion', d.fecha_derivacion, 'motivo', d.motivo, 'indicacion', d.indicacion,
                'prioridad', d.prioridad, 'estado', d.estado, 'fecha_cita', d.fecha_cita, 'fecha_atencion', d.fecha_atencion,
                'atendido_por', d.atendido_por, 'colposcopia', d.colposcopia, 'biopsia_tomada', d.biopsia_tomada,
                'biopsia_resultado', d.biopsia_resultado, 'fecha_biopsia_resultado', d.fecha_biopsia_resultado,
                'tratamiento', d.tratamiento, 'contrarreferencia', d.contrarreferencia, 'proximo_control', d.proximo_control,
                'fecha_contrarreferencia', d.fecha_contrarreferencia) order by d.created_at), '[]'::jsonb)
              from derivaciones d left join centros_salud dc on dc.id = d.destino_id
             where d.paciente_id = p.id and d.estado <> 'cancelada')
         ) order by p.fecha_toma), '[]'::jsonb)
    into v
    from pacientes p
    left join centros_salud c on c.id = p.centro_id
    left join lotes l on l.id = p.lote_id
    left join centros_salud lab on lab.id = l.destino_id
   where p.deleted_at is null and not sivec_ve_centro(p.centro_id)
     and ((v_ci is not null and sivec_norm_ci(p.carnet) = v_ci)
       or (p_nac is not null and v_nom <> '' and p.fecha_nacimiento = p_nac and sivec_norm(p.nombre) = v_nom));
  if jsonb_array_length(v) > 0 then
    insert into historial_accesos (centro_id, carnet, nombre, encontrados) values (sivec_centro(), p_carnet, p_nombre, jsonb_array_length(v));
  end if;
  return v;
end $$;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when exists (select 1 from information_schema.columns where table_name = 'pacientes' and column_name = 'vph_modo')
             and exists (select 1 from information_schema.columns where table_name = 'lotes' and column_name = 'destino_externo')
             and pg_get_functiondef('sivec_lab_muestras(uuid)'::regprocedure) like '%vph_modo%'
            then 'listo' else 'revisar' end as paso_24;
```

### Deshacer el Paso 24
Las columnas nuevas pueden quedar (no molestan). Para volver a las funciones anteriores, ejecutar de nuevo la función `sivec_armar_lote` del Paso 10 (antes: `drop function if exists sivec_armar_lote(uuid[], uuid, date, text, text, text);`), `sivec_lab_muestras` del Paso 14 (antes: `drop function if exists sivec_lab_muestras(uuid);`) y la línea de tiempo del Paso 23.

---

## Paso 25 — Hospitales de 2º y 3º nivel con laboratorio propio (requiere el Paso 24)

Si el establecimiento **recibe muestras** (tiene laboratorio), al armar el lote aparece elegido su propio laboratorio y el botón dice **"🔬 Pasar a mi laboratorio"**.
Las muestras no viajan: quedan **recibidas** y listas para leer en el Portal del laboratorio. En la derivación a colposcopia también aparece primero el mismo hospital.

```sql
-- PASO 25 · Hospitales con laboratorio propio: las muestras pasan directo a su laboratorio (sin transporte ni recepción)
create or replace function sivec_armar_lote(p_ids uuid[], p_destino uuid, p_fecha date, p_transporte text, p_entregado text, p_externo text default null)
returns lotes language plpgsql security invoker set search_path = public as $$
declare v_centro uuid; v_lote lotes; v_n int; v_interno boolean;
begin
  if p_destino is null and nullif(trim(coalesce(p_externo, '')), '') is null then raise exception 'Elegí el laboratorio de destino.'; end if;
  if exists (select 1 from pacientes where id = any(p_ids) and vph_lugar = 'Casa' and vph_kit_devuelto is null) then
    raise exception 'Hay kits de autotoma que la paciente todavía no devolvió: marcá la fecha de devolución antes de enviarlos.'; end if;
  select min(centro_id::text)::uuid, count(*) into v_centro, v_n from pacientes where id = any(p_ids) and lote_id is null and deleted_at is null;
  if v_n = 0 then raise exception 'Ninguna de las muestras marcadas está libre (ya estaban en otro lote).'; end if;
  if (select count(distinct centro_id) from pacientes where id = any(p_ids) and lote_id is null) > 1 then raise exception 'Todas las muestras de un lote tienen que ser del mismo centro.'; end if;
  insert into lotes (codigo, centro_id, destino_id, destino_externo, fecha_envio, transporte, entregado_por, n_muestras)
    values ('L-' || to_char(coalesce(p_fecha, current_date), 'YYYY') || '-' || lpad(nextval('lote_seq')::text, 4, '0'),
            v_centro, p_destino, case when p_destino is null then nullif(trim(p_externo), '') end,
            coalesce(p_fecha, current_date), nullif(trim(p_transporte), ''), nullif(trim(p_entregado), ''), v_n)
    returning * into v_lote;
  v_interno := p_destino is not null and p_destino = v_centro;
  update pacientes p set lote_id = v_lote.id, lote_envio = v_lote.codigo, fecha_envio = v_lote.fecha_envio, muestra_estado = 'enviada',
         codigo_muestra = coalesce(p.codigo_muestra, 'M-' || to_char(coalesce(p_fecha, current_date), 'YY') || '-' || lpad(nextval('muestra_seq')::text, 6, '0'))
   where p.id = any(p_ids) and p.lote_id is null and p.deleted_at is null;
  get diagnostics v_n = row_count;
  if v_n <> v_lote.n_muestras then raise exception 'No se pudieron marcar todas las muestras (permisos del centro).'; end if;
  -- Laboratorio propio (hospital de 2º/3º nivel): la muestra no viaja, queda recibida y lista para leer
  if v_interno then
    update pacientes set muestra_estado = 'recibida', fecha_recepcion_muestra = now() where lote_id = v_lote.id;
    update lotes set estado = 'recibido', fecha_recepcion = now(), recibido_por = 'Laboratorio propio (interno)' where id = v_lote.id returning * into v_lote;
  end if;
  return v_lote;
end $$;
revoke execute on function sivec_armar_lote(uuid[], uuid, date, text, text, text) from public, anon;
grant execute on function sivec_armar_lote(uuid[], uuid, date, text, text, text) to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when pg_get_functiondef('sivec_armar_lote(uuid[], uuid, date, text, text, text)'::regprocedure) like '%v_interno%' then 'listo' else 'revisar' end as paso_25;
```

### Deshacer el Paso 25
Volver a ejecutar la función `sivec_armar_lote` del Paso 24.

---

## Paso 26 — Términos de uso aceptados y consentimiento de la paciente

- Al entrar por primera vez (y cada vez que cambien los términos), cada persona acepta los **Términos de uso** y la **Política de privacidad**; queda guardado con fecha.
- En el registro de la toma: casilla de **consentimiento de la paciente** para el registro digital y para compartir su resultado entre los establecimientos que la atienden (hoja para la paciente: docs/empresa/04-Consentimiento-paciente-SIVEC.docx).

```sql
-- PASO 26 · Términos de uso aceptados por cada persona y consentimiento de la paciente para el registro digital
-- A) Cada usuario acepta los términos de uso y la política de privacidad una vez por versión
create table if not exists sivec_aceptaciones (
  usuario uuid not null default auth.uid(),
  version text not null,
  aceptado_at timestamptz not null default now(),
  primary key (usuario, version)
);
alter table sivec_aceptaciones enable row level security;
drop policy if exists "ve lo suyo" on sivec_aceptaciones;
drop policy if exists "acepta lo suyo" on sivec_aceptaciones;
create policy "ve lo suyo" on sivec_aceptaciones for select to authenticated using (usuario = auth.uid() or sivec_es_admin());
create policy "acepta lo suyo" on sivec_aceptaciones for insert to authenticated with check (usuario = auth.uid());
grant select, insert on sivec_aceptaciones to authenticated;

-- B) Consentimiento de la paciente para el registro digital y para compartir su resultado entre los establecimientos que la atienden
alter table pacientes add column if not exists consent_registro_digital boolean;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when to_regclass('public.sivec_aceptaciones') is not null
             and exists (select 1 from information_schema.columns where table_name = 'pacientes' and column_name = 'consent_registro_digital')
            then 'listo' else 'revisar' end as paso_26;
```

### Deshacer el Paso 26
`drop table if exists sivec_aceptaciones;` y `alter table pacientes drop column if exists consent_registro_digital;` (se pierde lo registrado).

---

## Paso 27 — Antecedentes completos en la referencia (Formulario Nº 1)

Al derivar aparece el bloque **Antecedentes y examen**: gineco-obstétricos (menarca, ciclos, FUM, IRS, parejas, gestas, partos, cesáreas, abortos, hijos vivos, fecha del último parto, embarazo, lactancia, menopausia, método, vacuna VPH, PAP/VPH previos, tratamiento previo del cuello), personales y familiares, signos vitales y examen. Se completa solo con la última consulta y el historial de tomas; se guarda con la derivación, sale en el Formulario Nº 1 y el hospital lo ve en su portal.

```sql
-- PASO 27 · Antecedentes gineco-obstétricos, personales, signos vitales y examen en la referencia (Formulario Nº 1)
alter table derivaciones add column if not exists clinica jsonb;

-- El centro que derivó guarda los antecedentes de la referencia
create or replace function sivec_der_clinica(p_id uuid, p_clinica jsonb) returns void
language plpgsql security definer set search_path = public as $$
begin
  update derivaciones set clinica = p_clinica where id = p_id and sivec_edita_centro(centro_origen);
  if not found then raise exception 'Solo el centro que derivó puede completar los antecedentes.'; end if;
end $$;
revoke execute on function sivec_der_clinica(uuid, jsonb) from public, anon;
grant execute on function sivec_der_clinica(uuid, jsonb) to authenticated;

-- El hospital ve los antecedentes en su portal de colposcopia
drop function if exists sivec_colpo_lista();
create or replace function sivec_colpo_lista()
returns table (id uuid, paciente_id uuid, nombre text, carnet text, fecha_nacimiento date, celular text, direccion text,
  centro_origen uuid, motivo text, indicacion text, prioridad text, notas text, derivado_por text, fecha_derivacion date,
  estado text, fecha_cita date, fecha_atencion date, atendido_por text, colposcopia jsonb, biopsia_tomada boolean,
  biopsia_resultado text, tratamiento text, contrarreferencia text, proximo_control text, fecha_contrarreferencia timestamptz, antecedentes text, cobertura text, monto numeric, pago_recibo text, clinica jsonb)
language sql stable security definer set search_path = public as $$
  select d.id, d.paciente_id, p.nombre, p.carnet, p.fecha_nacimiento, p.celular, p.direccion,
    d.centro_origen, d.motivo, d.indicacion, d.prioridad, d.notas, d.derivado_por, d.fecha_derivacion,
    d.estado, d.fecha_cita, d.fecha_atencion, d.atendido_por, d.colposcopia, d.biopsia_tomada,
    d.biopsia_resultado, d.tratamiento, d.contrarreferencia, d.proximo_control, d.fecha_contrarreferencia,
    (select string_agg(to_char(q.fecha_toma, 'MM/YYYY') || ' ' || coalesce(nullif(q.resultado_pap, ''), 'PAP pendiente')
        || case when q.resultado_vph is not null and q.resultado_vph <> '' then ' · VPH ' || q.resultado_vph || coalesce(' ' || q.vph_genotipo, '') else '' end, '  |  ' order by q.fecha_toma desc)
       from pacientes q where q.deleted_at is null and (q.id = p.id or (coalesce(p.carnet, '') <> '' and q.carnet = p.carnet))),
    d.cobertura, d.monto, d.pago_recibo, d.clinica
  from derivaciones d join pacientes p on p.id = d.paciente_id
  where sivec_es_colpo() and d.destino_id = sivec_centro() and d.estado <> 'cancelada'
  order by (d.prioridad = 'urgente') desc, d.fecha_derivacion $$;
revoke execute on function sivec_colpo_lista() from public, anon;
grant execute on function sivec_colpo_lista() to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when exists (select 1 from information_schema.columns where table_name = 'derivaciones' and column_name = 'clinica')
             and pg_get_functiondef('sivec_colpo_lista()'::regprocedure) like '%clinica%'
            then 'listo' else 'revisar' end as paso_27;
```

### Deshacer el Paso 27
Volver a ejecutar `sivec_colpo_lista` del Paso 14 (antes: `drop function if exists sivec_colpo_lista();`). La columna `clinica` puede quedar.

---

## Paso 28 — Soporte dentro del sistema (chat con el equipo del SIVEC)

Aparece un botón redondo 💬 abajo a la derecha en todas las pantallas. Desde ahí la persona escribe por **WhatsApp** (con los datos del sistema ya escritos), **llama** o **escribe al equipo** en un chat que queda guardado. Cada consulta lleva la versión, la pantalla, la conexión y el último error del navegador — **nunca datos de pacientes**. Las personas marcadas como **soporte** (`es_soporte`) ven todas las consultas en la misma ventana, responden y cambian el estado (abierta, en curso, resuelta). Cuando hay una respuesta nueva, el botón muestra un número rojo.

```sql
-- PASO 28 · Soporte: consultas y mensajes entre los usuarios y el equipo del SIVEC
alter table perfiles_usuario add column if not exists es_soporte boolean not null default false;

create or replace function sivec_es_soporte() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select es_soporte from perfiles_usuario where id = auth.uid() and activo), false) $$;
revoke execute on function sivec_es_soporte() from public, anon;
grant execute on function sivec_es_soporte() to authenticated;

create table if not exists sivec_soporte_tickets (
  id bigserial primary key,
  usuario uuid not null default auth.uid() references auth.users(id) on delete cascade,
  usuario_nombre text,
  centro_id uuid,
  establecimiento text,
  categoria text not null default 'error',
  asunto text,
  urgente boolean not null default false,
  estado text not null default 'abierto' check (estado in ('abierto', 'en_curso', 'resuelto')),
  contexto jsonb,
  ultimo_de_soporte boolean not null default false,
  leido_usuario timestamptz,
  leido_soporte timestamptz,
  creado timestamptz not null default now(),
  actualizado timestamptz not null default now()
);
create table if not exists sivec_soporte_mensajes (
  id bigserial primary key,
  ticket_id bigint not null references sivec_soporte_tickets(id) on delete cascade,
  autor uuid not null default auth.uid() references auth.users(id) on delete cascade,
  de_soporte boolean not null default false,
  texto text not null check (length(texto) between 1 and 4000),
  creado timestamptz not null default now()
);
create index if not exists sivec_soporte_mensajes_ticket on sivec_soporte_mensajes (ticket_id, creado);
create index if not exists sivec_soporte_tickets_usuario on sivec_soporte_tickets (usuario, actualizado desc);

alter table sivec_soporte_tickets enable row level security;
alter table sivec_soporte_mensajes enable row level security;
drop policy if exists "ver consultas" on sivec_soporte_tickets;
drop policy if exists "crear consulta" on sivec_soporte_tickets;
drop policy if exists "actualizar consulta" on sivec_soporte_tickets;
drop policy if exists "ver mensajes" on sivec_soporte_mensajes;
drop policy if exists "escribir mensaje" on sivec_soporte_mensajes;
-- Cada persona ve sus consultas; el equipo de soporte ve todas
create policy "ver consultas" on sivec_soporte_tickets for select to authenticated using (usuario = auth.uid() or sivec_es_soporte());
create policy "crear consulta" on sivec_soporte_tickets for insert to authenticated with check (usuario = auth.uid());
create policy "actualizar consulta" on sivec_soporte_tickets for update to authenticated
  using (usuario = auth.uid() or sivec_es_soporte()) with check (usuario = auth.uid() or sivec_es_soporte());
create policy "ver mensajes" on sivec_soporte_mensajes for select to authenticated
  using (exists (select 1 from sivec_soporte_tickets t where t.id = ticket_id and (t.usuario = auth.uid() or sivec_es_soporte())));
-- Solo el equipo de soporte puede escribir como "soporte"
create policy "escribir mensaje" on sivec_soporte_mensajes for insert to authenticated
  with check (autor = auth.uid() and (de_soporte = false or sivec_es_soporte())
    and exists (select 1 from sivec_soporte_tickets t where t.id = ticket_id and (t.usuario = auth.uid() or sivec_es_soporte())));
grant select, insert, update on sivec_soporte_tickets to authenticated;
grant select, insert on sivec_soporte_mensajes to authenticated;
grant usage, select on sequence sivec_soporte_tickets_id_seq, sivec_soporte_mensajes_id_seq to authenticated;

-- Cada mensaje nuevo actualiza la consulta (orden de la lista y aviso de "respuesta nueva")
create or replace function sivec_soporte_al_mensaje() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  update sivec_soporte_tickets
     set actualizado = now(), ultimo_de_soporte = new.de_soporte,
         estado = case when not new.de_soporte and estado = 'resuelto' then 'abierto' else estado end
   where id = new.ticket_id;
  return new;
end $$;
drop trigger if exists sivec_soporte_al_mensaje on sivec_soporte_mensajes;
create trigger sivec_soporte_al_mensaje after insert on sivec_soporte_mensajes for each row execute function sivec_soporte_al_mensaje();

notify pgrst, 'reload schema';

-- Quién atiende el soporte: cambiar el correo por el tuyo (y el de cada persona del equipo)
-- update perfiles_usuario set es_soporte = true where correo = 'TU_CORREO_DEL_SIVEC';

-- Resultado: debe decir "listo"
select case when to_regclass('public.sivec_soporte_tickets') is not null
             and to_regclass('public.sivec_soporte_mensajes') is not null
             and exists (select 1 from information_schema.columns where table_name = 'perfiles_usuario' and column_name = 'es_soporte')
            then 'listo' else 'revisar' end as paso_28;
```

Después de "listo", ejecutá la línea del `update … es_soporte = true` con **tu correo** (sin el `--` del comienzo). Solo quien tenga `es_soporte` ve la bandeja de todas las consultas y responde como "Equipo SIVEC".

En `config.js` se completa el contacto que ve cada persona: `soporte: { whatsapp: '591…', telefono: '+591…', correo: '…', horario: 'Lunes a sábado, de 8:00 a 20:00' }`.

### Deshacer el Paso 28
Si hiciste el Paso 29, primero deshacelo. Después: `drop table if exists sivec_soporte_mensajes; drop table if exists sivec_soporte_tickets; drop function if exists sivec_soporte_al_mensaje(); drop function if exists sivec_es_soporte();` (se pierden las consultas). La columna `es_soporte` puede quedar.

---

## Paso 29 — Captura de pantalla en el chat de soporte (requiere el Paso 28)

Al tocar 💬 el sistema saca solo una captura de la pantalla donde estaba la persona (sin el botón ni la ventana de soporte). Para **abrir una consulta la captura es obligatoria**: se puede cambiar por otra imagen (📸 capturar la pantalla en la computadora, 📎 elegir del celular o pegar con Ctrl+V), pero no se puede enviar sin ninguna. En los mensajes siguientes el 📎 es opcional, y el equipo de soporte también puede mandar capturas ("tocá acá"). Las imágenes se guardan en un espacio **privado** de Supabase (Storage): solo las ven la persona que abrió la consulta y el equipo de soporte, con enlaces que vencen en una hora.

```sql
-- PASO 29 · Capturas de pantalla en el soporte (Supabase Storage, espacio privado "sivec-soporte")
alter table sivec_soporte_mensajes add column if not exists adjunto text;
-- Un mensaje puede ser solo la captura, sin texto
alter table sivec_soporte_mensajes drop constraint if exists sivec_soporte_mensajes_texto_check;
alter table sivec_soporte_mensajes add constraint sivec_soporte_mensajes_texto_check
  check (length(texto) <= 4000 and (length(texto) >= 1 or adjunto is not null));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('sivec-soporte', 'sivec-soporte', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = false, file_size_limit = 5242880, allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

-- Cada captura va en la carpeta de su consulta: <número de consulta>/<archivo>.jpg
drop policy if exists "soporte subir captura" on storage.objects;
drop policy if exists "soporte ver captura" on storage.objects;
create policy "soporte subir captura" on storage.objects for insert to authenticated
  with check (bucket_id = 'sivec-soporte' and exists (select 1 from public.sivec_soporte_tickets t
    where t.id::text = (storage.foldername(name))[1] and (t.usuario = auth.uid() or public.sivec_es_soporte())));
create policy "soporte ver captura" on storage.objects for select to authenticated
  using (bucket_id = 'sivec-soporte' and exists (select 1 from public.sivec_soporte_tickets t
    where t.id::text = (storage.foldername(name))[1] and (t.usuario = auth.uid() or public.sivec_es_soporte())));

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when exists (select 1 from information_schema.columns where table_name = 'sivec_soporte_mensajes' and column_name = 'adjunto')
             and exists (select 1 from storage.buckets where id = 'sivec-soporte' and not public)
            then 'listo' else 'revisar' end as paso_29;
```

Sin el Paso 29 la consulta igual se envía, pero sin la imagen (el sistema avisa y sugiere mandarla por WhatsApp).

### Deshacer el Paso 29
`drop policy if exists "soporte subir captura" on storage.objects; drop policy if exists "soporte ver captura" on storage.objects;` y borrar el espacio **sivec-soporte** desde Supabase → Storage (se pierden las capturas). La columna `adjunto` puede quedar.

---

## Paso 30 — Firma electrónica con PIN (laboratorio, colposcopia, referencia y contrarreferencia)

Cada profesional crea **su PIN de firma de 6 números** (una vez, en ⚙ Configuración o la primera vez que firma). El PIN se pide al **liberar un informe de laboratorio**, al **guardar una colposcopia**, al **enviar una referencia** y al **enviar una contrarreferencia**. Queda registrado quién firmó, cuándo, en qué establecimiento y la **huella SHA-256** del contenido firmado; el documento impreso muestra "Firmado electrónicamente por… · código de verificación". El PIN se guarda cifrado (bcrypt), nadie lo puede leer; 5 intentos fallidos lo bloquean 15 minutos, y el administrador lo puede restablecer si alguien lo olvida. No usa celular ni equipo nuevo. (Firma electrónica con PIN; la firma digital con certificado de la ADSIB/AGETIC y el lector de huella con el SEGIP quedan para el SIVEC completo.)

```sql
-- PASO 30 · Firma electrónica con PIN personal
create extension if not exists pgcrypto with schema extensions;

create table if not exists sivec_firma_pin (
  usuario uuid primary key references auth.users(id) on delete cascade,
  pin_hash text not null,
  intentos int not null default 0,
  bloqueado_hasta timestamptz,
  actualizado timestamptz not null default now()
);
alter table sivec_firma_pin enable row level security;   -- sin políticas: solo la tocan las funciones de abajo
revoke all on sivec_firma_pin from anon, authenticated;

create table if not exists sivec_firmas (
  id bigserial primary key,
  tipo text not null check (tipo in ('referencia', 'contrarreferencia', 'informe_lab', 'colposcopia')),
  documento text not null,
  firmante uuid not null references auth.users(id),
  firmante_nombre text,
  establecimiento text,
  huella text not null,
  codigo text not null unique,
  creado timestamptz not null default now()
);
create index if not exists sivec_firmas_doc on sivec_firmas (tipo, documento, creado desc);
alter table sivec_firmas enable row level security;
drop policy if exists "ver firmas" on sivec_firmas;
create policy "ver firmas" on sivec_firmas for select to authenticated using (true);  -- sin datos de pacientes
grant select on sivec_firmas to authenticated;

-- ¿Ya tengo PIN?
create or replace function sivec_pin_estado() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from sivec_firma_pin where usuario = auth.uid()) $$;

-- Crear o cambiar el PIN (para cambiarlo hay que dar el actual)
create or replace function sivec_pin_definir(p_pin text, p_actual text default null) returns void
language plpgsql security definer set search_path = public, extensions as $$
declare v sivec_firma_pin;
begin
  if auth.uid() is null then raise exception 'Iniciá sesión.'; end if;
  if p_pin !~ '^[0-9]{6}$' then raise exception 'El PIN tiene que tener 6 números.'; end if;
  if p_pin ~ '^(.)\1{5}$' or p_pin in ('123456', '654321', '012345', '543210') then raise exception 'Ese PIN es muy fácil de adivinar. Elegí otro.'; end if;
  select * into v from sivec_firma_pin where usuario = auth.uid();
  if found and (p_actual is null or v.pin_hash <> crypt(p_actual, v.pin_hash)) then raise exception 'El PIN actual no es correcto.'; end if;
  insert into sivec_firma_pin (usuario, pin_hash) values (auth.uid(), crypt(p_pin, gen_salt('bf', 8)))
  on conflict (usuario) do update set pin_hash = excluded.pin_hash, intentos = 0, bloqueado_hasta = null, actualizado = now();
end $$;

-- Comprobar el PIN: devuelve 'ok', 'sin_pin', 'bloqueado:HH:MI' o 'incorrecto:N' (N = intentos que quedan)
create or replace function sivec_pin_verificar(p_pin text) returns text
language plpgsql security definer set search_path = public, extensions as $$
declare v sivec_firma_pin;
begin
  select * into v from sivec_firma_pin where usuario = auth.uid() for update;
  if not found then return 'sin_pin'; end if;
  if v.bloqueado_hasta is not null and v.bloqueado_hasta > now() then
    return 'bloqueado:' || to_char(v.bloqueado_hasta at time zone 'America/La_Paz', 'HH24:MI'); end if;
  if v.pin_hash = crypt(coalesce(p_pin, ''), v.pin_hash) then
    update sivec_firma_pin set intentos = 0, bloqueado_hasta = null where usuario = auth.uid();
    return 'ok';
  end if;
  update sivec_firma_pin set intentos = intentos + 1,
    bloqueado_hasta = case when intentos + 1 >= 5 then now() + interval '15 minutes' else null end
   where usuario = auth.uid();
  if v.intentos + 1 >= 5 then return 'bloqueado:' || to_char((now() + interval '15 minutes') at time zone 'America/La_Paz', 'HH24:MI'); end if;
  return 'incorrecto:' || (5 - v.intentos - 1);
end $$;

-- Firmar un documento: comprueba el PIN y que la persona tenga que ver con ese documento
create or replace function sivec_firmar(p_tipo text, p_documento text, p_huella text, p_pin text) returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare v_est text; v_ok boolean := false; r sivec_firmas;
begin
  v_est := sivec_pin_verificar(p_pin);
  if v_est <> 'ok' then return jsonb_build_object('ok', false, 'motivo', v_est); end if;
  if p_huella !~ '^[0-9a-f]{64}$' then return jsonb_build_object('ok', false, 'motivo', 'huella'); end if;
  if p_tipo = 'referencia' then
    select true into v_ok from derivaciones d where d.id::text = p_documento and sivec_edita_centro(d.centro_origen);
  elsif p_tipo = 'contrarreferencia' then
    select true into v_ok from derivaciones d where d.id::text = p_documento and d.destino_id = sivec_centro() and sivec_es_colpo();
  elsif p_tipo = 'informe_lab' then
    select true into v_ok from pacientes p where p.id::text = p_documento and sivec_es_lab();
  elsif p_tipo = 'colposcopia' then
    select true into v_ok from colposcopias c join pacientes p on p.id = c.paciente_id where c.id::text = p_documento and sivec_edita_centro(p.centro_id);
  end if;
  if not coalesce(v_ok, false) then return jsonb_build_object('ok', false, 'motivo', 'sin_permiso'); end if;
  insert into sivec_firmas (tipo, documento, firmante, firmante_nombre, establecimiento, huella, codigo)
  values (p_tipo, p_documento, auth.uid(),
    (select coalesce(nullif(nombre_completo, ''), correo) from perfiles_usuario where id = auth.uid()),
    (select c.nombre from perfiles_usuario u join centros_salud c on c.id = u.centro_id where u.id = auth.uid()),
    p_huella, upper(encode(gen_random_bytes(4), 'hex')))
  returning * into r;
  return jsonb_build_object('ok', true, 'codigo', r.codigo, 'creado', r.creado, 'firmante_nombre', r.firmante_nombre, 'establecimiento', r.establecimiento, 'huella', r.huella);
end $$;

-- Verificar un código impreso en un documento (también sin sesión: no muestra datos de pacientes)
create or replace function sivec_firma_verificar(p_codigo text)
returns table (tipo text, firmante_nombre text, establecimiento text, creado timestamptz, huella text)
language sql stable security definer set search_path = public as $$
  select f.tipo, f.firmante_nombre, f.establecimiento, f.creado, f.huella from sivec_firmas f
   where f.codigo = upper(replace(trim(p_codigo), '-', '')) $$;

-- El administrador restablece el PIN de alguien que lo olvidó (la persona crea uno nuevo al firmar)
create or replace function sivec_pin_restablecer(p_usuario uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not sivec_es_admin() then raise exception 'Solo el administrador puede restablecer un PIN.'; end if;
  delete from sivec_firma_pin where usuario = p_usuario;
end $$;

revoke execute on function sivec_pin_estado(), sivec_pin_definir(text, text), sivec_pin_verificar(text), sivec_firmar(text, text, text, text), sivec_pin_restablecer(uuid) from public, anon;
grant execute on function sivec_pin_estado(), sivec_pin_definir(text, text), sivec_pin_verificar(text), sivec_firmar(text, text, text, text), sivec_pin_restablecer(uuid) to authenticated;
revoke execute on function sivec_firma_verificar(text) from public;
grant execute on function sivec_firma_verificar(text) to anon, authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when to_regclass('public.sivec_firmas') is not null and to_regclass('public.sivec_firma_pin') is not null
             and to_regprocedure('sivec_firmar(text, text, text, text)') is not null
            then 'listo' else 'revisar' end as paso_30;
```

### Deshacer el Paso 30
`drop function if exists sivec_firmar(text, text, text, text), sivec_pin_verificar(text), sivec_pin_definir(text, text), sivec_pin_estado(), sivec_firma_verificar(text), sivec_pin_restablecer(uuid); drop table if exists sivec_firmas; drop table if exists sivec_firma_pin;` (se pierden las firmas registradas; los documentos siguen igual, sin la leyenda de firma).

---

## Paso 31 — La firma con PIN en todo el recorrido (requiere el Paso 30)

El mismo PIN firma también: la **consulta** (su firma sale en el D1, el D8, el registro de PAP, el consentimiento y la historia clínica), la **aceptación de la referencia** en el hospital (al dar la cita; sale en "Nombre y firma de quien recibe" del Formulario Nº 1) y la **recepción de la contrarreferencia** en el centro (sale en "Recepción en el establecimiento de origen" del Formulario Nº 2).

```sql
-- PASO 31 · Más documentos firmados con el PIN: consulta, aceptación de la referencia y recepción de la contrarreferencia
alter table sivec_firmas drop constraint if exists sivec_firmas_tipo_check;
alter table sivec_firmas add constraint sivec_firmas_tipo_check check (tipo in
  ('referencia', 'contrarreferencia', 'informe_lab', 'colposcopia', 'consulta', 'recepcion', 'recepcion_contra'));

create or replace function sivec_firmar(p_tipo text, p_documento text, p_huella text, p_pin text) returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare v_est text; v_ok boolean := false; r sivec_firmas;
begin
  v_est := sivec_pin_verificar(p_pin);
  if v_est <> 'ok' then return jsonb_build_object('ok', false, 'motivo', v_est); end if;
  if p_huella !~ '^[0-9a-f]{64}$' then return jsonb_build_object('ok', false, 'motivo', 'huella'); end if;
  if p_tipo in ('referencia', 'recepcion_contra') then       -- el centro que derivó
    select true into v_ok from derivaciones d where d.id::text = p_documento and sivec_edita_centro(d.centro_origen);
  elsif p_tipo in ('contrarreferencia', 'recepcion') then    -- el hospital que recibe
    select true into v_ok from derivaciones d where d.id::text = p_documento and d.destino_id = sivec_centro() and sivec_es_colpo();
  elsif p_tipo = 'informe_lab' then
    select true into v_ok from pacientes p where p.id::text = p_documento and sivec_es_lab();
  elsif p_tipo = 'colposcopia' then
    select true into v_ok from colposcopias c join pacientes p on p.id = c.paciente_id where c.id::text = p_documento and sivec_edita_centro(p.centro_id);
  elsif p_tipo = 'consulta' then
    select true into v_ok from consultas c left join pacientes p on p.id::text = c.paciente_id::text
     where c.id::text = p_documento and sivec_edita_centro(coalesce(c.centro_id, p.centro_id));
  end if;
  if not coalesce(v_ok, false) then return jsonb_build_object('ok', false, 'motivo', 'sin_permiso'); end if;
  insert into sivec_firmas (tipo, documento, firmante, firmante_nombre, establecimiento, huella, codigo)
  values (p_tipo, p_documento, auth.uid(),
    (select coalesce(nullif(nombre_completo, ''), correo) from perfiles_usuario where id = auth.uid()),
    (select c.nombre from perfiles_usuario u join centros_salud c on c.id = u.centro_id where u.id = auth.uid()),
    p_huella, upper(encode(gen_random_bytes(4), 'hex')))
  returning * into r;
  return jsonb_build_object('ok', true, 'codigo', r.codigo, 'creado', r.creado, 'firmante_nombre', r.firmante_nombre, 'establecimiento', r.establecimiento, 'huella', r.huella);
end $$;
revoke execute on function sivec_firmar(text, text, text, text) from public, anon;
grant execute on function sivec_firmar(text, text, text, text) to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when pg_get_constraintdef((select oid from pg_constraint where conname = 'sivec_firmas_tipo_check')) like '%recepcion_contra%'
             and pg_get_functiondef('sivec_firmar(text, text, text, text)'::regprocedure) like '%consultas%'
            then 'listo' else 'revisar' end as paso_31;
```

### Deshacer el Paso 31
Volver a ejecutar el Paso 30 (deja solo los cuatro tipos del comienzo). Si ya hay firmas de consultas o recepciones, antes: `delete from sivec_firmas where tipo in ('consulta', 'recepcion', 'recepcion_contra');`

---

## Paso 32 — Funciones por persona y cola del día (recepción → consultorio)

Para hospitales y centros grandes. Cada usuario puede tener **funciones**: Admisión / recepción, Consultorio de toma (PAP/VPH), Consultorio de colposcopia, Recepción del laboratorio, Lectura del laboratorio, Jefe del establecimiento. Cada persona ve solo sus pantallas (sin funciones marcadas = ve todo, como hasta ahora). La recepción registra la llegada y **envía la paciente a un consultorio**; en el consultorio aparece en **"Pacientes de hoy"**; se la llama (en la pantalla de la sala de espera sale el número de turno, nunca el nombre) y se marca atendida. Los consultorios de cada establecimiento se cargan en Admin → Establecimientos → 🚪.

```sql
-- PASO 32 · Funciones por usuario, consultorios y cola del día
alter table perfiles_usuario add column if not exists funciones text[];
alter table centros_salud add column if not exists consultorios text[];

create table if not exists sivec_turnos (
  id bigserial primary key,
  centro_id uuid not null,
  fecha date not null default ((now() at time zone 'America/La_Paz')::date),
  numero int,
  paciente_id uuid,
  paciente_nombre text,
  carnet text,
  servicio text not null check (servicio in ('toma', 'colposcopia', 'consulta')),
  consultorio text,
  derivacion_id uuid,
  estado text not null default 'espera' check (estado in ('espera', 'llamada', 'en_atencion', 'atendida', 'no_se_presento', 'cancelado')),
  llegada timestamptz not null default now(),
  llamada_at timestamptz,
  atendida_at timestamptz,
  creado_por uuid default auth.uid(),
  atendido_por uuid,
  notas text
);
create index if not exists sivec_turnos_dia on sivec_turnos (centro_id, fecha, estado);

-- Número de turno correlativo por establecimiento y por día
create or replace function sivec_turno_numero() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform pg_advisory_xact_lock(hashtext(new.centro_id::text || new.fecha::text));
  new.numero := coalesce((select max(numero) from sivec_turnos where centro_id = new.centro_id and fecha = new.fecha), 0) + 1;
  return new;
end $$;
drop trigger if exists sivec_turno_numero on sivec_turnos;
create trigger sivec_turno_numero before insert on sivec_turnos for each row execute function sivec_turno_numero();

alter table sivec_turnos enable row level security;
drop policy if exists "turnos del establecimiento" on sivec_turnos;
create policy "turnos del establecimiento" on sivec_turnos for all to authenticated
  using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));
grant select, insert, update on sivec_turnos to authenticated;
grant usage, select on sequence sivec_turnos_id_seq to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when to_regclass('public.sivec_turnos') is not null
             and exists (select 1 from information_schema.columns where table_name = 'perfiles_usuario' and column_name = 'funciones')
             and exists (select 1 from information_schema.columns where table_name = 'centros_salud' and column_name = 'consultorios')
            then 'listo' else 'revisar' end as paso_32;
```

### Deshacer el Paso 32
`drop table if exists sivec_turnos; drop function if exists sivec_turno_numero();` (se pierden las colas del día). Las columnas `funciones` y `consultorios` pueden quedar: vacías, todos ven todo como antes.

## Paso 33 — Firma de la paciente (código por WhatsApp o firma en la pantalla) — requiere el Paso 30

La paciente firma sin papel, de una de dos maneras:
- **Código por WhatsApp:** el sistema arma un código de 6 números y abre WhatsApp (del celular o la computadora del centro) con el mensaje listo para la paciente; ella dice el código y el profesional lo escribe.
- **En la pantalla:** si no tiene celular, firma con el dedo (tableta o celular) o con el mouse.

Después el profesional firma como **testigo con su PIN**. Queda guardado: cómo firmó, los últimos 4 números del celular (nunca el número completo), la firma dibujada, la huella del documento, el testigo y la fecha. La firma sale impresa en el consentimiento y en el D1. Nadie puede cambiarla ni borrarla desde el sistema.

```sql
-- PASO 33 · Firma de la paciente (requiere el Paso 30: PIN de firma)
create table if not exists sivec_firmas_paciente (
  id bigserial primary key,
  centro_id uuid not null,
  paciente_id text not null,
  documento text not null check (documento in ('consentimiento', 'd1', 'referencia', 'otro')),
  metodo text not null check (metodo in ('whatsapp', 'pantalla')),
  celular text,              -- solo los últimos 4 números
  imagen text,               -- la firma dibujada (PNG), si firmó en la pantalla
  firmante_nombre text,      -- la paciente, o quien firma por ella (tutor o familiar)
  huella text not null,
  testigo uuid not null default auth.uid(),
  testigo_nombre text,
  creado timestamptz not null default now()
);
create index if not exists sivec_firmas_paciente_doc on sivec_firmas_paciente (paciente_id, documento);
alter table sivec_firmas_paciente enable row level security;
drop policy if exists "firmas de pacientes del establecimiento" on sivec_firmas_paciente;
create policy "firmas de pacientes del establecimiento" on sivec_firmas_paciente for select to authenticated
  using (sivec_edita_centro(centro_id));
grant select on sivec_firmas_paciente to authenticated;

-- Guardar la firma: comprueba el PIN del testigo y que la paciente sea de su establecimiento
create or replace function sivec_firma_paciente(p_paciente text, p_documento text, p_metodo text, p_celular text,
  p_imagen text, p_firmante text, p_huella text, p_pin text) returns jsonb
language plpgsql security definer set search_path = public, extensions as $$
declare v_est text; v_centro uuid; r sivec_firmas_paciente;
begin
  v_est := sivec_pin_verificar(p_pin);
  if v_est <> 'ok' then return jsonb_build_object('ok', false, 'motivo', v_est); end if;
  select centro_id into v_centro from pacientes where id::text = p_paciente;
  if v_centro is null or not sivec_edita_centro(v_centro) then return jsonb_build_object('ok', false, 'motivo', 'sin_permiso'); end if;
  if p_metodo = 'pantalla' and (p_imagen is null or p_imagen not like 'data:image/png;base64,%' or length(p_imagen) > 400000) then
    return jsonb_build_object('ok', false, 'motivo', 'firma_invalida'); end if;
  insert into sivec_firmas_paciente (centro_id, paciente_id, documento, metodo, celular, imagen, firmante_nombre, huella, testigo_nombre)
  values (v_centro, p_paciente, p_documento, p_metodo, right(regexp_replace(coalesce(p_celular, ''), '\D', '', 'g'), 4),
          case when p_metodo = 'pantalla' then p_imagen end, p_firmante, p_huella,
          (select nombre_completo from perfiles_usuario where id = auth.uid()))
  returning * into r;
  return jsonb_build_object('ok', true, 'id', r.id, 'creado', r.creado, 'testigo_nombre', r.testigo_nombre);
end $$;
revoke all on function sivec_firma_paciente(text, text, text, text, text, text, text, text) from public;
grant execute on function sivec_firma_paciente(text, text, text, text, text, text, text, text) to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when to_regclass('public.sivec_firmas_paciente') is not null
             and to_regprocedure('sivec_firma_paciente(text,text,text,text,text,text,text,text)') is not null
            then 'listo' else 'revisar' end as paso_33;
```

### Deshacer el Paso 33
`drop function if exists sivec_firma_paciente(text, text, text, text, text, text, text, text); drop table if exists sivec_firmas_paciente;` (se pierden las firmas de pacientes guardadas; los documentos vuelven a salir con la línea para firmar a mano).

## Paso 34 — Código SIVEC de los formularios (D1, D8 y PAP)

Si el establecimiento no usa talonario, el SIVEC arma solo el número de los formularios de cada toma: **un mismo número para toda la toma**, cambiando solo el prefijo del documento. Ejemplo: `PAP-SL-0926-014`, `D1-SL-0926-014`, `D8-SL-0926-014` (PAP · San Luis · septiembre de 2026 · toma Nº 14 del mes). El contador está en la base de datos: dos computadoras nunca reciben el mismo número. La sigla del establecimiento se arma sola con el nombre (San Luis → SL) o se escribe en Admin → Establecimientos → ✏️.

```sql
-- PASO 34 · Código SIVEC de los formularios
alter table centros_salud add column if not exists sigla text;

create table if not exists sivec_folios (
  centro_id uuid not null,
  periodo text not null,          -- 'AAAA-MM'
  ultimo int not null default 0,
  primary key (centro_id, periodo)
);
alter table sivec_folios enable row level security;   -- sin reglas: solo se usa por la función de abajo

create or replace function sivec_folio_siguiente(p_centro uuid, p_periodo text) returns int
language plpgsql security definer set search_path = public as $$
declare v int;
begin
  if not (sivec_edita_centro(p_centro) or sivec_es_admin()) then raise exception 'Sin permiso para numerar en este establecimiento.'; end if;
  if p_periodo !~ '^\d{4}-\d{2}$' then raise exception 'Periodo inválido.'; end if;
  insert into sivec_folios (centro_id, periodo, ultimo) values (p_centro, p_periodo, 1)
  on conflict (centro_id, periodo) do update set ultimo = sivec_folios.ultimo + 1
  returning ultimo into v;
  return v;
end $$;
revoke all on function sivec_folio_siguiente(uuid, text) from public;
grant execute on function sivec_folio_siguiente(uuid, text) to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when to_regprocedure('sivec_folio_siguiente(uuid,text)') is not null
             and exists (select 1 from information_schema.columns where table_name = 'centros_salud' and column_name = 'sigla')
            then 'listo' else 'revisar' end as paso_34;
```

Sin el Paso 34 el código igual se arma, contando las tomas que la computadora ya tiene cargadas (puede repetirse si dos computadoras registran al mismo tiempo).

### Deshacer el Paso 34
`drop function if exists sivec_folio_siguiente(uuid, text); drop table if exists sivec_folios;` (los códigos ya guardados en las pacientes no se tocan; la columna `sigla` puede quedar).
