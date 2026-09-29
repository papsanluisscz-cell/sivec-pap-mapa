-- =====================================================================================
--  SIVEC PAP/VPH · BASE DE DEMOSTRACIÓN · Pasos 23 a 35 (todo en un solo archivo)
--  Correr DESPUÉS de SIVEC-DEMO.sql, en el proyecto DEMO (nunca en la base real).
--  Supabase → SQL Editor → pegar TODO → Run. Al final debe decir "listo" (paso_35).
--  En el sistema, en cualquier puerta: usuario  demo   ·   contraseña  demo
-- =====================================================================================

-- ===================== Paso 23 =====================
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

-- ===================== Paso 24 =====================
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

-- ===================== Paso 25 =====================
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

-- ===================== Paso 26 =====================
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

-- ===================== Paso 27 =====================
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

-- ===================== Paso 28 =====================
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

-- ===================== Paso 29 =====================
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

-- ===================== Paso 30 =====================
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

-- ===================== Paso 31 =====================
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

-- ===================== Paso 32 =====================
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

-- ===================== Paso 33 =====================
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

-- ===================== Paso 34 =====================
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

-- ===================== Paso 35 =====================
-- PASO 35 · Modo Campaña (requiere el Paso 32)
create table if not exists sivec_campanas (
  id uuid primary key default gen_random_uuid(),
  centro_id uuid not null,
  nombre text not null,
  fecha date not null,
  lugar text,
  meta int,
  servicios text[] not null default array['pap', 'vph', 'colposcopia'],
  estado text not null default 'abierta' check (estado in ('abierta', 'cerrada')),
  creado_por uuid default auth.uid(),
  creado timestamptz not null default now(),
  cerrada_at timestamptz
);
alter table sivec_campanas enable row level security;
drop policy if exists "campañas del establecimiento" on sivec_campanas;
create policy "campañas del establecimiento" on sivec_campanas for all to authenticated
  using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));
grant select, insert, update on sivec_campanas to authenticated;

alter table pacientes add column if not exists campana_id uuid;
alter table pacientes add column if not exists centro_seguimiento uuid;
alter table sivec_turnos add column if not exists campana_id uuid;
alter table colposcopias add column if not exists ivaa text;
alter table colposcopias add column if not exists union_ec text;
alter table colposcopias add column if not exists campana_id uuid;

-- Cerrar la campaña: cada mujer pasa a la ficha de su centro de salud
create or replace function sivec_campana_cerrar(p_campana uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare c sivec_campanas; n int;
begin
  select * into c from sivec_campanas where id = p_campana;
  if not found or not sivec_edita_centro(c.centro_id) then raise exception 'Sin permiso para cerrar esta campaña.'; end if;
  update pacientes set centro_id = centro_seguimiento
   where campana_id = p_campana and centro_seguimiento is not null and centro_seguimiento <> centro_id and deleted_at is null;
  get diagnostics n = row_count;
  update sivec_campanas set estado = 'cerrada', cerrada_at = now() where id = p_campana;
  return jsonb_build_object('ok', true, 'enviadas', n);
end $$;
revoke all on function sivec_campana_cerrar(uuid) from public;
grant execute on function sivec_campana_cerrar(uuid) to authenticated;

notify pgrst, 'reload schema';

-- Resultado: debe decir "listo"
select case when to_regclass('public.sivec_campanas') is not null
             and to_regprocedure('sivec_campana_cerrar(uuid)') is not null
             and exists (select 1 from information_schema.columns where table_name = 'pacientes' and column_name = 'centro_seguimiento')
            then 'listo' else 'revisar' end as paso_35;



-- PASO 36 · Tratamientos y procedimientos propios de cada establecimiento (colposcopia)
create table if not exists sivec_tratamientos_centro (
  id uuid primary key default gen_random_uuid(),
  centro_id uuid not null,
  grupo text not null default 'proc' check (grupo in ('proc', 'med', 'ind')),
  icono text,
  nombre text not null check (length(trim(nombre)) between 2 and 120),
  indicacion text check (indicacion is null or length(indicacion) <= 240),
  activo boolean not null default true,
  creado_por uuid default auth.uid(),
  creado timestamptz not null default now()
);
create unique index if not exists sivec_trat_centro_nombre on sivec_tratamientos_centro (centro_id, lower(trim(nombre))) where activo;
alter table sivec_tratamientos_centro enable row level security;
drop policy if exists "tratamientos: ver los del establecimiento" on sivec_tratamientos_centro;
create policy "tratamientos: ver los del establecimiento" on sivec_tratamientos_centro for select to authenticated
  using (sivec_ve_centro(centro_id));
drop policy if exists "tratamientos: agregar en el establecimiento" on sivec_tratamientos_centro;
create policy "tratamientos: agregar en el establecimiento" on sivec_tratamientos_centro for insert to authenticated
  with check (sivec_edita_centro(centro_id));
drop policy if exists "tratamientos: quitar en el establecimiento" on sivec_tratamientos_centro;
create policy "tratamientos: quitar en el establecimiento" on sivec_tratamientos_centro for update to authenticated
  using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));
grant select, insert, update on sivec_tratamientos_centro to authenticated;
select 'Paso 36 listo' as resultado;


-- PASO 37 · Métricas SNIS y CAI: revisión de cada establecimiento (el gestor ve quién ya revisó)
create table if not exists sivec_metricas_revision (
  id uuid primary key default gen_random_uuid(),
  centro_id uuid not null,
  tipo text not null check (tipo in ('snis', 'cai')),
  periodo text not null check (periodo ~ '^[0-9]{4}(-[0-9]{2}|-T[1-4]|-S[12])?$'),
  revisado_por uuid default auth.uid(),
  revisado_nombre text,
  revisado_at timestamptz not null default now(),
  datos jsonb,
  notas text,
  unique (centro_id, tipo, periodo)
);
alter table sivec_metricas_revision enable row level security;
drop policy if exists "métricas: ver las de sus centros" on sivec_metricas_revision;
create policy "métricas: ver las de sus centros" on sivec_metricas_revision for select to authenticated
  using (sivec_ve_centro(centro_id));
drop policy if exists "métricas: revisar en el establecimiento" on sivec_metricas_revision;
create policy "métricas: revisar en el establecimiento" on sivec_metricas_revision for insert to authenticated
  with check (sivec_edita_centro(centro_id));
drop policy if exists "métricas: volver a revisar" on sivec_metricas_revision;
create policy "métricas: volver a revisar" on sivec_metricas_revision for update to authenticated
  using (sivec_edita_centro(centro_id)) with check (sivec_edita_centro(centro_id));
grant select, insert, update on sivec_metricas_revision to authenticated;
select 'Paso 37 listo' as resultado;
