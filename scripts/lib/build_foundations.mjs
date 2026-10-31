// Função pura: tokens -> dados dos Fundamentos (cores, tipografia, raio, sombras, foco).
// Alimenta `FrappeUIPhx.Foundations` e o mostruário; sai de `priv/foundations.json`.

const SEMANTIC = ['surface', 'surface-alpha', 'ink', 'outline', 'outline-alpha']

export function buildFoundations({
  semanticColors,
  colors,
  radius,
  shadows,
  fontSize,
  fontWeight,
  fontFamily,
  focusRing,
  tracking,
}) {
  const semantic = Object.fromEntries(
    SEMANTIC.map((category) => [
      category,
      Object.keys(semanticColors.light[category]).map((name) => ({
        name,
        light: semanticColors.light[category][name],
        dark: semanticColors.dark[category]?.[name] ?? semanticColors.light[category][name],
      })),
    ]),
  )

  const ramps = Object.fromEntries(
    Object.entries(colors.light).map(([family, shades]) => [
      family,
      Object.entries(shades).map(([shade, value]) => ({ shade, value })),
    ]),
  )

  const type = Object.entries(fontSize).map(([name, meta]) => ({
    name,
    size: meta.fontSize,
    lineHeight: String(meta.lineHeight ?? ''),
    letterSpacing: meta.letterSpacing ?? '',
    weight: meta.fontWeight ?? fontWeight.regular,
    paragraph: name.startsWith('p-'),
  }))

  return {
    colors: semantic,
    ramps,
    radius: Object.entries(radius).map(([name, value]) => ({ name, value })),
    shadows: Object.entries(shadows)
      .filter(([name]) => name !== 'DEFAULT')
      .map(([name, value]) => ({ name, value })),
    typography: {
      family: fontFamily.text,
      weights: Object.entries(fontWeight).map(([name, value]) => ({ name, value })),
      scale: type,
      trackingText: tracking?.text ?? {},
    },
    focusRing: Object.entries(focusRing.light).map(([name, value]) => ({ name, value })),
  }
}
