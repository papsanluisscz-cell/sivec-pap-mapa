-- SIVEC PAP/VPH: Paso 4 (sin riesgo). Pegar TODO en Supabase > SQL Editor y apretar Run.
-- (Desactivar la traducción automática del navegador antes de copiar.)

alter table pacientes add column if not exists seg_etapa text;
alter table pacientes add column if not exists seg_fechas jsonb;
alter table pacientes add column if not exists fecha_envio date;
alter table pacientes add column if not exists lote_envio text;
