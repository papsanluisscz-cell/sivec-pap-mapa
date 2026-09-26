-- =====================================================================================
--  SIVEC PAP/VPH · BASE DE DEMOSTRACIÓN (todo ficticio)
--  Para un proyecto de Supabase NUEVO y vacío (no usar en la base real).
--  1) Supabase → New project "SIVEC DEMO"  2) SQL Editor → pegar TODO este archivo → Run
--  3) En el sistema: Configuración → URL y clave del proyecto DEMO (o "Usar código de conexión")
--  Cuentas (contraseña para todas: Demo-2026):
--    admin@demo.sivec.bo · gestor.centro@demo.sivec.bo · gestor.norte@demo.sivec.bo
--    sanluis@demo.sivec.bo · santarosita@demo.sivec.bo · frances@demo.sivec.bo · laboratorio@demo.sivec.bo
-- =====================================================================================
-- 0) Tablas base del SIVEC PAP (como el Supabase del piloto antes de los pasos)
create table if not exists centros_salud (id uuid primary key default gen_random_uuid(), nombre text, red text, direccion text, activo boolean default true, created_at timestamptz default now());
create table if not exists perfiles_usuario (id uuid primary key, nombre_completo text, centro_id uuid references centros_salud(id), rol text, created_at timestamptz default now());
create table if not exists pacientes (
  id uuid primary key default gen_random_uuid(), created_at timestamptz default now(), nombre text, carnet text, fecha_nacimiento date, celular text, direccion text, doctora text,
  fecha_toma date, tipo_examen text, resultado_pap text, estado_pap text, hizo_prueba_vph boolean, resultado_vph text, recibio_tratamiento_vph boolean, notificada boolean,
  recogio_resultado boolean, observaciones text, numero_documento integer, estado_civil text, ocupacion text, numero_folio text, fecha_estimada date, seguimiento_pap text,
  fecha_seguimiento_pap date, seguimiento_vph text, fecha_seguimiento_vph date, derivacion_pap text, consent_telemedicina text, consent_interrogatorio text, consent_informado text,
  consent_dispositivos text, consent_dispositivos_lista text[], consent_explicacion text, recibio_resultado boolean, fecha_recibio_resultado date, deleted_at timestamptz,
  anticonceptivo_usa text, anticonceptivo_metodo text, anticonceptivo_fecha_inicio date, anticonceptivo_proximo_control date, anticonceptivo_observaciones text,
  numero_folio_d1 text, numero_folio_d8 text, numero_folio_pap text, latitude double precision, longitude double precision, centro_id uuid references centros_salud(id),
  lat double precision, lng double precision, geo_manual boolean, vph_genotipo text, seg_etapa text, seg_fechas jsonb, fecha_envio date, lote_envio text);
create table if not exists colposcopias (id uuid primary key default gen_random_uuid(), paciente_id uuid references pacientes(id) on delete cascade, fecha date, prueba_schiller text, zona_afectada text,
  lesion text[], otros_hallazgos text, soap_subjetivo text, soap_objetivo_oce text, soap_objetivo_leucorrea text, soap_objetivo_color text, soap_analisis text, soap_observaciones text,
  plan text[], derivacion text, created_at timestamptz default now(), centro_id uuid, cuello_mapa jsonb);
create table if not exists consultas (id uuid primary key default gen_random_uuid(), paciente_id uuid, centro_id uuid, doctor_id uuid, doctor_nombre text, especialidad text, fecha timestamptz default now(),
  motivo_consulta text, soap_subjetivo text, soap_objetivo text, soap_analisis text, soap_plan text, numero_folio_d1 text, numero_folio_d8 text, created_at timestamptz default now(),
  detalle jsonb, codigo_esp text, doctora text, subjetivo text, objetivo_oce text, objetivo_leucorrea text, objetivo_color text, objetivo text, analisis text, observaciones text,
  plan jsonb, plan_texto text, derivacion text);
create table if not exists auditoria (id uuid primary key default gen_random_uuid(), usuario_id uuid, usuario_email text, tabla text, registro_id uuid, accion text, campo text,
  valor_anterior text, valor_nuevo text, fecha timestamptz default now());
grant select, insert, update, delete on all tables in schema public to authenticated;
-- El centro de partida (como en el piloto)
insert into centros_salud (nombre, red) select 'Centro de Salud San Luis', 'Red Centro' where not exists (select 1 from centros_salud);

-- ===================== Paso 1 =====================
alter table pacientes
  add column if not exists lat double precision,
  add column if not exists lng double precision,
  add column if not exists geo_manual boolean default false;

-- ===================== Paso 2 =====================
alter table pacientes add column if not exists vph_genotipo text;

-- ===================== Paso 4 =====================
alter table pacientes add column if not exists seg_etapa text;
alter table pacientes add column if not exists seg_fechas jsonb;
alter table pacientes add column if not exists fecha_envio date;
alter table pacientes add column if not exists lote_envio text;

-- ===================== Paso 5 =====================
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

-- ===================== Paso 6 =====================
alter table consultas add column if not exists detalle jsonb;
alter table consultas add column if not exists especialidad text;
alter table consultas add column if not exists codigo_esp text;
alter table colposcopias add column if not exists cuello_mapa jsonb;

-- ===================== Paso 7 =====================
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

alter table consultas drop constraint if exists consultas_paciente_id_fkey;
alter table consultas add constraint consultas_paciente_id_fkey
  foreign key (paciente_id) references pacientes(id) on delete cascade not valid;
notify pgrst, 'reload schema';

-- ===================== Paso 8 =====================
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

-- ===================== Paso 10 =====================
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

-- ===================== Paso 11 =====================
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

-- ===================== Paso 12 =====================
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

-- ===================== Paso 13 =====================
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

-- ===================== Paso 14 =====================
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

-- ===================== Paso 15 =====================
alter table pacientes add column if not exists cobertura text;
alter table pacientes add column if not exists monto_pago numeric;
alter table pacientes add column if not exists recibo_caja text;
notify pgrst, 'reload schema';

-- ===================== Paso 16 =====================
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

-- ===================== Paso 17 =====================
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

-- ===================== Paso 18 =====================
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

-- ===================== Paso 19 =====================
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


-- ===================== Paso 20 =====================
alter table centros_salud add column if not exists lat double precision;
alter table centros_salud add column if not exists lng double precision;
notify pgrst, 'reload schema';
select nombre, lat, lng from centros_salud order by nombre;

-- ===================== Paso 21 =====================
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

-- ===================== Paso 22 =====================
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

-- ===================== DATOS DE DEMOSTRACIÓN (todo ficticio) =====================
-- Marca de "modo demostración": el sistema muestra la franja "DEMO · datos ficticios".
create table if not exists sivec_meta (clave text primary key, valor text);
alter table sivec_meta enable row level security;
drop policy if exists "todos leen" on sivec_meta;
create policy "todos leen" on sivec_meta for select to anon, authenticated using (true);
grant select on sivec_meta to anon, authenticated;
insert into sivec_meta values ('modo', 'demo') on conflict (clave) do update set valor = excluded.valor;

-- Redes y establecimientos (ubicaciones aproximadas)
insert into redes (nombre, municipio) values ('Red Centro', 'Santa Cruz de la Sierra'), ('Red Norte', 'Santa Cruz de la Sierra') on conflict (nombre) do nothing;

do $$
declare
  rc uuid := (select id from redes where nombre = 'Red Centro');
  rn uuid := (select id from redes where nombre = 'Red Norte');
begin
  update centros_salud set red_id = rc, red = 'Red Centro', tipo = 'primer_nivel', codigo = 'SLU', meta_pap_anual = 700, lat = -17.7968, lng = -63.2046,
         profesionales = array['Dra. Vargas', 'Dra. Rojas', 'Dr. Suárez', 'Dra. Mendoza'], direccion = 'Barrio Bibosi'
   where nombre ilike '%san luis%';
  insert into centros_salud (nombre, red, red_id, tipo, codigo, meta_pap_anual, lat, lng, profesionales, direccion, hace_colposcopia, recibe_muestras)
  select v.* from (values
    ('Centro de Salud Elvira Wunderlich', 'Red Centro', rc, 'primer_nivel', 'EWU', 450, -17.7905, -63.1835, array['Dra. Paz', 'Dr. Flores'], 'Av. Trompillo', false, false),
    ('Centro de Salud Perpetuo Socorro',  'Red Centro', rc, 'primer_nivel', 'PSO', 500, -17.7768, -63.1968, array['Dra. Justiniano', 'Dra. Ribera'], 'Barrio Los Chinos', false, false),
    ('Centro de Salud Roque Aguilera',    'Red Centro', rc, 'primer_nivel', 'RAG', 480, -17.7712, -63.1790, array['Dr. Montaño', 'Dra. Salvatierra'], 'C. Santiago Vaca Guzmán', false, false),
    ('Centro de Salud San Carlos',        'Red Centro', rc, 'primer_nivel', 'SCA', 420, -17.8045, -63.1712, array['Dra. Aguilar', 'Dr. Cuéllar'], 'Radial 27, entre 3er y 4to anillo', false, false),
    ('Centro de Salud Santa Rosita',      'Red Centro', rc, 'primer_nivel', 'SRO', 520, -17.8112, -63.1905, array['Dra. Chávez', 'Dra. Terrazas', 'Dr. Añez'], 'C. Mataral, UV-30', false, false),
    ('Centro de Salud Virgen de Cotoca',  'Red Centro', rc, 'primer_nivel', 'VCO', 400, -17.7832, -63.1640, array['Dra. Gutiérrez', 'Dr. Arteaga'], 'C. San Pedro', false, false),
    ('Centro de Salud Virgen de Fátima',  'Red Centro', rc, 'primer_nivel', 'VFA', 460, -17.8010, -63.2140, array['Dra. Soliz', 'Dra. Pedraza'], 'Villa Fátima, Av. Pilcomayo', false, false),
    ('Centro de Salud Willy Lemaitre',    'Red Centro', rc, 'primer_nivel', 'WLE', 380, -17.7650, -63.2010, array['Dr. Rivero', 'Dra. Hurtado'], 'C. 7 Oeste', false, false),
    ('Hospital Municipal Francés',        'Red Centro', rc, 'segundo_nivel', 'HMF', 300, -17.7745, -63.1675, array['Dra. Camacho', 'Dr. Ortiz'], 'Zona centro', true, false),
    ('Centro de Salud Los Lotes',         'Red Norte',  rn, 'primer_nivel', 'LLO', 520, -17.7355, -63.1560, array['Dra. Zeballos', 'Dr. Méndez'], 'Barrio Los Lotes', false, false),
    ('Centro de Salud El Palmar',         'Red Norte',  rn, 'primer_nivel', 'EPA', 430, -17.7280, -63.1745, array['Dra. Rocha', 'Dra. Parada'], 'Barrio El Palmar', false, false),
    ('Centro de Salud Villa Primavera',   'Red Norte',  rn, 'primer_nivel', 'VPR', 390, -17.7410, -63.1880, array['Dr. Céspedes', 'Dra. Antelo'], 'Villa Primavera', false, false),
    ('Hospital de 2º Nivel Norte',        'Red Norte',  rn, 'segundo_nivel', 'H2N', 250, -17.7205, -63.1620, array['Dra. Bruno'], 'Av. Banzer, 7mo anillo', true, false),
    ('Hospital San Juan de Dios',         null,         null, 'tercer_nivel', 'HSJ', null, -17.7858, -63.1772, array['Dr. Ibáñez'], 'Zona centro', true, false),
    ('Instituto Oncológico del Oriente Boliviano', null, null, 'oncologico', 'ONC', null, -17.763879, -63.194321, array['Dra. Lima'], 'Av. Noel Kempff Mercado #890', true, true)
  ) v(nombre, red, red_id, tipo, codigo, meta, lat, lng, prof, dir, colpo, lab)
  where not exists (select 1 from centros_salud c where c.nombre = v.nombre);
end $$;

-- Pacientes ficticias: 18 meses de tomas en los centros de 1er y 2º nivel de las dos redes
do $$
declare
  nombres text[] := array['María','Ana','Rosa','Carmen','Juana','Lucía','Patricia','Silvia','Elena','Martha','Gladys','Sonia','Norma','Carla','Paola','Daniela','Mónica','Verónica','Claudia','Roxana','Ximena','Wendy','Jhenny','Lidia','Teresa','Isabel','Beatriz','Julia','Sandra','Miriam','Noelia','Fabiola','Karina','Mariela','Yolanda','Susana','Luz','Pamela','Estela','Ruth'];
  apellidos text[] := array['Vaca','Rojas','Suárez','Justiniano','Flores','Mamani','Quispe','Choque','Gutiérrez','Vargas','Pérez','Arteaga','Roca','Chávez','Salvatierra','Aguilera','Montaño','Cuéllar','Méndez','Terrazas','Ribera','Paz','Soliz','Añez','Hurtado','Zeballos','Parada','Rivero','Antelo','Céspedes','Moreno','Callaú','Égüez','Peña','Camacho','Durán','Limpias','Saucedo','Coímbra','Ortiz'];
  calles text[] := array['Los Tajibos','Mataral','Tarija','Sucre','Bolívar','Florida','Aroma','Cochabamba','Charcas','Warnes','Irala','Buenos Aires','Libertad','Junín','Ayacucho','Campero','Beni','Chuquisaca'];
  barrios text[] := array['Bibosi','Los Chinos','Mac Donald','Santa Rosita','Villa Fátima','San Carlos','Cotoca','El Trompillo','Los Lotes','El Palmar','Villa Primavera','Las Pampitas','Guapurú','Los Mangales'];
  metodos text[] := array['Preservativo','Píldora','Inyectable','DIU','Implante subdérmico','Ninguno'];
  c record; onco uuid; hf uuid; h2n uuid; lab_nom text := 'Lic. Andrea Céspedes (citotecnóloga)';
  m int; n int; i int; d date; dias int; v_id uuid; v_lote uuid; v_cod text; lote_n int := 0; mues_n int := 0;
  r float; bet text; est text; vph text; gen text; v_tipo text; hizo boolean; env date; inf timestamptz; con_res boolean;
  entreg boolean; f_ent date; v_nom text; v_ci text; v_nac date; dest uuid; der_est text; biop text; trat text;
begin
  perform setseed(0.2026);
  onco := (select id from centros_salud where tipo = 'oncologico' limit 1);
  hf := (select id from centros_salud where codigo = 'HMF'); h2n := (select id from centros_salud where codigo = 'H2N');
  for c in select * from centros_salud where tipo in ('primer_nivel', 'segundo_nivel') and red_id is not null order by nombre loop
    for m in 0..17 loop
      n := greatest(4, round(coalesce(c.meta_pap_anual, 300) / 12.0 * (0.62 + random() * 0.5) * (case when m < 1 then 0.8 else 1 end)))::int;
      -- un lote por mes y por centro
      lote_n := lote_n + 1;
      d := (date_trunc('month', current_date) - make_interval(months => m))::date;
      env := least(current_date, d + 20);
      v_cod := 'L-' || to_char(env, 'YYYY') || '-' || lpad(lote_n::text, 4, '0');
      insert into lotes (codigo, centro_id, destino_id, fecha_envio, transporte, entregado_por, n_muestras, estado, recibido_por, fecha_recepcion, created_at)
        values (v_cod, c.id, onco, env, 'Ambulancia de la red', 'Lic. enfermería', n, case when current_date - env > 2 then 'recibido' else 'enviado' end,
                case when current_date - env > 2 then lab_nom end, case when current_date - env > 2 then (env + 2)::timestamptz end, env::timestamptz)
        returning id into v_lote;
      for i in 1..n loop
        mues_n := mues_n + 1;
        v_nom := nombres[1 + floor(random() * array_length(nombres, 1))::int] || ' ' || apellidos[1 + floor(random() * 40)::int] || ' ' || apellidos[1 + floor(random() * 40)::int];
        v_ci := (4000000 + floor(random() * 5999999))::int::text;
        v_nac := current_date - ((25 + floor(random() * 40)) * 365 + floor(random() * 365))::int;
        d := least(current_date, (date_trunc('month', current_date) - make_interval(months => m))::date + floor(random() * 20)::int);
        dias := current_date - d;
        v_tipo := case when random() < 0.14 then 'VPH' else 'Papanicolau' end;
        hizo := v_tipo = 'VPH' or random() < 0.18;
        con_res := case when dias > 75 then random() < 0.96 when dias > 45 then random() < 0.7 when dias > 25 then random() < 0.3 else false end;
        r := random();
        bet := null; est := null; vph := null; gen := null;
        if con_res and v_tipo <> 'VPH' then
          bet := case when r < 0.925 then 'NILM' when r < 0.95 then 'ASC-US' when r < 0.968 then 'LSIL' when r < 0.976 then 'ASC-H' when r < 0.986 then 'HSIL' when r < 0.988 then 'AGC' else 'Insatisfactoria' end;
          est := case when bet = 'NILM' then 'Negativo' when bet = 'Insatisfactoria' then null else 'Positivo' end;
        end if;
        if con_res and hizo then
          vph := case when random() < 0.13 then 'Positiva' else 'Negativa' end;
          if vph = 'Positiva' then r := random(); gen := case when r < 0.32 then '16' when r < 0.45 then '18' else 'Otros de alto riesgo' end; end if;
        end if;
        inf := case when con_res then (env + 6 + floor(random() * 14)::int)::timestamptz end;
        if inf > now() then inf := now() - interval '1 day'; end if;
        entreg := con_res and random() < (case when dias > 90 then 0.88 else 0.45 end);
        f_ent := case when entreg then least(current_date, inf::date + 2 + floor(random() * 18)::int) end;
        insert into pacientes (nombre, carnet, fecha_nacimiento, celular, direccion, doctora, fecha_toma, tipo_examen, hizo_prueba_vph, resultado_pap, estado_pap,
            resultado_vph, vph_genotipo, recibio_resultado, fecha_recibio_resultado, fecha_estimada, centro_id, lat, lng, geo_manual, cobertura, monto_pago, recibo_caja,
            anticonceptivo_metodo, numero_folio_pap, fecha_envio, lote_envio, lote_id, codigo_muestra, muestra_estado, fecha_recepcion_muestra, fecha_informe, informado_por,
            informe_lab, resultado_visto_at, seg_etapa, created_at)
        values (v_nom, v_ci, v_nac, '7' || lpad(floor(random() * 9999999)::int::text, 7, '0'),
            'B. ' || barrios[1 + floor(random() * array_length(barrios, 1))::int] || ', C. ' || calles[1 + floor(random() * array_length(calles, 1))::int] || ' #' || (10 + floor(random() * 900))::int,
            c.profesionales[1 + floor(random() * greatest(1, array_length(c.profesionales, 1)))::int], d, v_tipo, hizo, bet, coalesce(est, case when v_tipo <> 'VPH' then 'Pendiente' end),
            vph, gen, entreg, f_ent, d + 90, c.id, c.lat + (random() - 0.5) * 0.024, c.lng + (random() - 0.5) * 0.024, false,
            case when random() < 0.86 then 'SUS' when random() < 0.8 then 'Sin SUS' end, null, null,
            case when random() < 0.45 then metodos[1 + floor(random() * 6)::int] end, lpad((50000 + mues_n)::text, 7, '0'),
            case when dias > 3 then env end, case when dias > 3 then v_cod end, case when dias > 3 then v_lote end,
            c.codigo || '-' || to_char(d, 'YY') || '-' || lpad(mues_n::text, 5, '0'),
            case when not (dias > 3 and current_date - env > 2) then null when bet = 'Insatisfactoria' then 'insatisfactoria' when con_res then 'informada' else 'recibida' end,
            case when dias > 3 and current_date - env > 2 then (env + 2)::timestamptz end, inf, case when con_res then lab_nom end,
            case when con_res then jsonb_build_object('bethesda', bet, 'vph', vph, 'genotipo', gen, 'firmado', lab_nom) end,
            case when con_res and dias > 40 then inf + interval '1 day' end,
            case when entreg then 'notificada' when con_res then 'resultado' end, d::timestamptz)
        returning id into v_id;
        update pacientes set monto_pago = 30, recibo_caja = 'R-' || (1000 + floor(random() * 9000))::int where id = v_id and cobertura = 'Sin SUS';
        -- Positivas: derivación a colposcopia (la mayoría); algunas quedan "sin tratar" para la búsqueda activa
        if (est = 'Positivo' or vph = 'Positiva') and random() < 0.9 then
          dest := case when bet in ('HSIL', 'ASC-H', 'AGC') then onco when c.red_id = (select red_id from centros_salud where id = h2n) then h2n else hf end;
          r := random();
          der_est := case when dias < 60 then (case when r < 0.5 then 'enviada' else 'citada' end)
                          when r < 0.08 then 'no_asistio' when r < 0.22 then 'atendida' else 'contrarreferida' end;
          biop := null; trat := null;
          if der_est in ('atendida', 'contrarreferida') then
            biop := case when bet = 'HSIL' then (array['CIN 2', 'CIN 3', 'CIN 3', 'Carcinoma in situ'])[1 + floor(random() * 4)::int]
                         when random() < 0.5 then (array['Negativo (cervicitis)', 'CIN 1', 'CIN 1'])[1 + floor(random() * 3)::int] end;
            trat := case when biop in ('CIN 2', 'CIN 3', 'Carcinoma in situ') then (array['LEEP / cono', 'LEEP / cono', 'Ablación térmica'])[1 + floor(random() * 3)::int] else 'Ninguno (control)' end;
          end if;
          insert into derivaciones (paciente_id, centro_origen, destino_id, motivo, indicacion, prioridad, derivado_por, fecha_derivacion, estado, fecha_cita, fecha_atencion,
              atendido_por, colposcopia, biopsia_tomada, biopsia_resultado, fecha_biopsia_resultado, tratamiento, contrarreferencia, proximo_control, fecha_contrarreferencia,
              visto_origen_at, cobertura)
          values (v_id, c.id, dest, coalesce('PAP ' || bet, 'VPH positivo' || coalesce(' genotipo ' || gen, '')), 'Colposcopia y biopsia si corresponde',
              case when bet in ('HSIL', 'ASC-H', 'AGC') or gen in ('16', '18') then 'urgente' else 'normal' end,
              c.profesionales[1], least(current_date, inf::date + 5), der_est,
              case when der_est <> 'enviada' then least(current_date + 7, inf::date + 20) end,
              case when der_est in ('atendida', 'contrarreferida') then least(current_date, inf::date + 25) end,
              case when der_est in ('atendida', 'contrarreferida') then 'Dra. Camacho' end,
              case when der_est in ('atendida', 'contrarreferida') then jsonb_build_object('adecuada', true, 'zt', 'Tipo 1', 'hallazgos', case when biop is null then '["Normal"]'::jsonb else '["Acetoblanco denso"]'::jsonb end, 'impresion', case when biop in ('CIN 2', 'CIN 3', 'Carcinoma in situ') then 'Alto grado' when biop is null then 'Normal' else 'Bajo grado' end) end,
              biop is not null, biop, case when biop is not null then least(current_date, inf::date + 45) end, trat,
              case when der_est = 'contrarreferida' then 'Control con PAP según indicación. Vuelve a su centro.' end,
              case when der_est = 'contrarreferida' then (array['6 meses', '1 año'])[1 + floor(random() * 2)::int] end,
              case when der_est = 'contrarreferida' then least(now(), (inf::date + 50)::timestamptz) end,
              case when der_est = 'contrarreferida' and dias > 100 then now() end,
              (select cobertura from pacientes where id = v_id));
          update pacientes set derivacion_pap = (select nombre from centros_salud where id = dest),
                 seg_etapa = case der_est when 'citada' then 'colpo_agendada' when 'atendida' then 'colpo_realizada' when 'contrarreferida' then case when trat <> 'Ninguno (control)' then 'tratamiento' else 'alta' end else 'notificada' end
           where id = v_id;
        end if;
      end loop;
    end loop;
  end loop;

  -- La misma mujer en dos centros (para mostrar la línea de tiempo entre centros)
  insert into pacientes (nombre, carnet, fecha_nacimiento, celular, direccion, doctora, fecha_toma, tipo_examen, resultado_pap, estado_pap, recibio_resultado,
      fecha_recibio_resultado, centro_id, lat, lng, cobertura, muestra_estado, informado_por, fecha_informe, created_at)
  select p.nombre, p.carnet, p.fecha_nacimiento, p.celular, p.direccion, o.profesionales[1], p.fecha_toma - 400, 'Papanicolau', 'NILM', 'Negativo', true,
         p.fecha_toma - 370, o.id, o.lat + (random() - 0.5) * 0.02, o.lng + (random() - 0.5) * 0.02, 'SUS', 'informada', lab_nom, (p.fecha_toma - 385)::timestamptz, (p.fecha_toma - 400)::timestamptz
    from (select * from pacientes where fecha_toma < current_date - 120 order by random() limit 60) p
    join lateral (select * from centros_salud x where x.tipo = 'primer_nivel' and x.id <> p.centro_id and x.red_id is not null order by random() limit 1) o on true;
end $$;

-- Cuentas de demostración (contraseña para todas: Demo-2026)
do $$
declare
  u record; v_uid uuid;
begin
  for u in select * from (values
      ('admin@demo.sivec.bo',        'Administración SIVEC',          'admin',  null,  null),
      ('gestor.centro@demo.sivec.bo','Gestora · Red Centro',          'gestor', null,  'Red Centro'),
      ('gestor.norte@demo.sivec.bo', 'Gestor · Red Norte',            'gestor', null,  'Red Norte'),
      ('sanluis@demo.sivec.bo',      'Dra. Vargas · C.S. San Luis',   'centro', 'SLU', null),
      ('santarosita@demo.sivec.bo',  'Dra. Chávez · C.S. Santa Rosita','centro', 'SRO', null),
      ('frances@demo.sivec.bo',      'Dra. Camacho · Hospital Francés','centro','HMF', null),
      ('laboratorio@demo.sivec.bo',  'Lic. Céspedes · Laboratorio',   'centro', 'ONC', null)) t(correo, nombre, rol, cod, red)
  loop
    select id into v_uid from auth.users where lower(email) = u.correo;
    if v_uid is null then
      v_uid := gen_random_uuid();
      insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change, email_change_token_new, recovery_token)
      values ('00000000-0000-0000-0000-000000000000', v_uid, 'authenticated', 'authenticated', u.correo, extensions.crypt('Demo-2026', extensions.gen_salt('bf')), now(),
        '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');
      insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
      values (gen_random_uuid(), v_uid, v_uid::text, jsonb_build_object('sub', v_uid::text, 'email', u.correo, 'email_verified', true), 'email', now(), now(), now());
    end if;
    insert into perfiles_usuario (id, correo, nombre_completo, rol, activo) select v_uid, u.correo, u.nombre, u.rol, true
      where not exists (select 1 from perfiles_usuario where id = v_uid);
    update perfiles_usuario set rol = u.rol, nombre_completo = u.nombre, activo = true, es_admin = u.rol = 'admin',
           centro_id = (select id from centros_salud where codigo = u.cod), red_id = (select id from redes where nombre = u.red),
           puede_laboratorio = coalesce(u.cod = 'ONC', false), puede_colposcopia = coalesce(u.cod in ('ONC', 'HMF'), false)
     where id = v_uid;
  end loop;
end $$;

notify pgrst, 'reload schema';

-- Resultado
select 'Redes' as que, count(*)::text as cuantos from redes
union all select 'Establecimientos', count(*)::text from centros_salud
union all select 'Tomas (ficticias)', count(*)::text from pacientes
union all select 'Positivas', count(*)::text from pacientes where estado_pap = 'Positivo' or resultado_vph = 'Positiva'
union all select 'Derivaciones', count(*)::text from derivaciones
union all select 'Lotes', count(*)::text from lotes
union all select 'Cuentas demo', string_agg(correo, ', ') from perfiles_usuario;
