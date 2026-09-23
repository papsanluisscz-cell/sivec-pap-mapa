-- SIVEC PAP/VPH: Pasos 1 y 2 (sin riesgo). Pegar TODO en Supabase > SQL Editor y apretar Run.

alter table pacientes add column if not exists lat double precision;
alter table pacientes add column if not exists lng double precision;
alter table pacientes add column if not exists geo_manual boolean default false;
alter table pacientes add column if not exists vph_genotipo text;
