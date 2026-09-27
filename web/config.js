// Conexión del sitio con el banco de datos (Supabase → Project Settings → API).
// La clave "anon public" es pública por diseño: sin usuario y contraseña no se ve ningún dato
// (las reglas de la base, Paso 22, deciden qué lee cada persona). NUNCA poner acá la clave "service_role".
window.SIVEC_CONFIG = {
  url: 'https://cvvqwwijnygqnhouqgkx.supabase.co',
  key: 'PEGAR_AQUI_LA_CLAVE_ANON_PUBLIC',
  // Soporte: botón 💬 abajo a la derecha y ⚙ Configuración. WhatsApp con código de país, sin +; teléfono para llamar (ej. +59170000000)
  // FICTICIO hasta comprar el celular de soporte: cambiar antes de usar con pacientes reales
  soporte: { whatsapp: '59170000000', telefono: '+59170000000', correo: 'soporte@sivec.bo', horario: 'Lunes a sábado, de 8:00 a 20:00' }
};
