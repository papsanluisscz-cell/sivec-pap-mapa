// SIVEC · service worker: guarda las pantallas para abrir rápido. Los datos NUNCA se guardan acá:
// siempre vienen del banco (Supabase) con el inicio de sesión de cada persona.
const CACHE = 'sivec-20260927184609';
const PANTALLAS = ['./', 'index.html', 'config.js', 'manifest.webmanifest', 'terminos.html', 'privacidad.html', 'icons/icon-192.png', 'icons/icon-512.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(PANTALLAS)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET') return;
  if (u.origin !== location.origin) {
    // Librerías (unpkg/jsdelivr): se guardan para que el sistema abra sin internet. Supabase y mapas: siempre directo.
    if (['unpkg.com', 'cdn.jsdelivr.net'].includes(u.hostname))
      e.respondWith(caches.open(CACHE).then(c => c.match(e.request).then(r => r || fetch(e.request).then(res => { if (res.ok) c.put(e.request, res.clone()); return res; }))));
    return;
  }
  // Primero internet (siempre la versión más nueva); sin conexión, la copia guardada
  e.respondWith(fetch(e.request).then(r => { const c = r.clone(); caches.open(CACHE).then(k => k.put(e.request, c)); return r; })
    .catch(() => caches.match(e.request).then(r => r || caches.match('index.html'))));
});
