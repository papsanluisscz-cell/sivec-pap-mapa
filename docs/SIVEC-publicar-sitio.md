# Publicar el SIVEC como sitio (sivec.bo)

La carpeta `web/` es el sitio: `index.html` (el sistema), `config.js` (conexión con Supabase), `manifest.webmanifest` y `sw.js` (instalar como aplicación), `icons/` y `_headers` (seguridad).
Cada vez que cambia `SIVEC-PAP-sistema.html`, Vercel/Cloudflare ejecutan `bash scripts/build-web.sh` y publican la versión nueva solos.

## 1. La clave pública de Supabase (una sola vez)
1. Supabase → Project Settings → API → copiar **anon public** (NO la service_role).
2. Pegarla en `web/config.js`, en lugar de `PEGAR_AQUI_LA_CLAVE_ANON_PUBLIC`.

## 2. Vercel (gratis para empezar)
1. vercel.com → entrar con GitHub → **Add New → Project** → elegir `sivec-pap-mapa`.
2. Framework: **Other**. Vercel lee `vercel.json` (comando `bash scripts/build-web.sh`, carpeta `web`).
3. Production Branch: la rama donde está la versión aprobada (`main` después del merge).
4. **Deploy** → queda en `https://<nombre>.vercel.app`.

(Cloudflare Pages es igual: comando de build `bash scripts/build-web.sh`, carpeta de salida `web`.)

## 3. Supabase: permitir el sitio
Authentication → URL Configuration → **Site URL** = la dirección del sitio (para los correos de recuperar contraseña).

## 4. Dominio propio
Comprar **sivec.bo** en NIC Bolivia (nic.bo) → en Vercel: Settings → Domains → agregar → copiar los registros DNS que indica.

## 5. En cada computadora
Abrir la dirección en Chrome → botón **⬇ Instalar SIVEC** (abajo a la derecha) → queda el ícono en el escritorio.
