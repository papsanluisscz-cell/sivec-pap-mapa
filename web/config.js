// Conexión del sitio con el banco de datos (Supabase → Project Settings → API).
// La clave "anon public" es pública por diseño: sin usuario y contraseña no se ve ningún dato
// (las reglas de la base, Paso 22, deciden qué lee cada persona). NUNCA poner acá la clave "service_role".
window.SIVEC_CONFIG = {
  url: 'https://cvvqwwijnygqnhouqgkx.supabase.co',
  key: 'PEGAR_AQUI_LA_CLAVE_ANON_PUBLIC'
};
