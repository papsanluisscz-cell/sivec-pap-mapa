# Publicar el SIVEC como sitio (sivec.bo)

La carpeta `web/` es el sitio: `index.html` (el sistema), `config.js` (conexión con Supabase), `manifest.webmanifest` y `sw.js` (instalar como aplicación), `icons/` y `_headers` (seguridad).
Cada vez que cambia `SIVEC-PAP-sistema.html`, Vercel/Cloudflare ejecutan `bash scripts/build-web.sh` y publican la versión nueva solos.

## 1. La clave pública de Supabase (una sola vez)
1. Supabase → Project Settings → API → copiar **anon public** (NO la service_role).
2. Pegarla en `web/config.js`, en lugar de `PEGAR_AQUI_LA_CLAVE_ANON_PUBLIC`.

## 2. Cloudflare Pages (recomendado: gratis y permite uso comercial)
> Vercel en el plan gratis (Hobby) es solo para uso personal/no comercial; como el SIVEC se vende, conviene Cloudflare Pages (gratis, sin límite de visitas, uso comercial permitido) o Vercel Pro (US$ 20/mes).
1. dash.cloudflare.com → crear cuenta → **Workers & Pages → Create → Pages → Connect to Git** → autorizar GitHub → elegir `sivec-pap-mapa`.
2. Production branch: `main` (la versión aprobada). Framework preset: **None**.
3. Build command: `bash scripts/build-web.sh` · Build output directory: `web`.
4. **Save and Deploy** → queda en `https://sivec.pages.dev` (o el nombre que elijas). El archivo `web/_headers` pone solas las protecciones de seguridad.
5. Cada cambio que entra en `main` se publica solo en 1–2 minutos. Las otras ramas generan una dirección de prueba aparte (sirve para mostrar una versión nueva antes de aprobarla).

(Vercel sigue funcionando igual con `vercel.json`, si más adelante se contrata el plan Pro.)

## 3. Supabase: permitir el sitio
Authentication → URL Configuration → **Site URL** = la dirección del sitio (para los correos de recuperar contraseña).

## 4. Dominio propio
1. **nic.bo** (NIC Bolivia, ADSIB) → buscar `sivec.bo` → registrar a nombre de la persona o de la empresa y pagar (los precios y requisitos de cada terminación —.bo, .com.bo— están en nic.bo).
2. En NIC Bolivia, cambiar los **servidores DNS** del dominio por los dos que indica Cloudflare (Cloudflare → Add a domain → plan Free). La propagación tarda de unas horas a 1–2 días.
3. Cloudflare Pages → el proyecto → **Custom domains** → agregar `sivec.bo` y `www.sivec.bo`. El certificado HTTPS (candado) se crea solo.
4. Supabase → Authentication → URL Configuration → Site URL = `https://sivec.bo`.
5. Correo `soporte@sivec.bo`: Cloudflare → Email Routing (gratis) reenvía a tu Gmail.

## 5. En cada computadora
Abrir la dirección en Chrome → botón **⬇ Instalar SIVEC** (abajo a la derecha) → queda el ícono en el escritorio.
