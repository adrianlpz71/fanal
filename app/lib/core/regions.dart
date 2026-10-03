/// Regiones fiscales (código ISO 3166-2). Los parámetros fiscales se guardan por región en el
/// backend (`tax_parameters.region`); en la fase 5 se cargan los de Canarias y el resto se
/// pueden añadir sin tocar código. Navarra y País Vasco tienen régimen foral propio.
const taxRegions = <String, String>{
  'ES-AN': 'Andalucía',
  'ES-AR': 'Aragón',
  'ES-AS': 'Asturias',
  'ES-IB': 'Illes Balears',
  'ES-CN': 'Canarias',
  'ES-CB': 'Cantabria',
  'ES-CL': 'Castilla y León',
  'ES-CM': 'Castilla-La Mancha',
  'ES-CT': 'Cataluña',
  'ES-EX': 'Extremadura',
  'ES-GA': 'Galicia',
  'ES-MD': 'Comunidad de Madrid',
  'ES-MC': 'Región de Murcia',
  'ES-RI': 'La Rioja',
  'ES-VC': 'Comunitat Valenciana',
  'ES-NC': 'Navarra (foral)',
  'ES-PV': 'País Vasco (foral)',
  'ES-CE': 'Ceuta',
  'ES-ML': 'Melilla',
};
