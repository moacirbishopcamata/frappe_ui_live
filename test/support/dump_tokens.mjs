// Despeja os tokens semânticos da FONTE vendorizada, sem passar pelo gerador de CSS.
import { semanticColors } from '../../vendor/frappe-ui-tokens/tokens.js'

const flat = (layer) =>
  Object.fromEntries(
    Object.entries(layer).flatMap(([category, entries]) =>
      Object.entries(entries).map(([name, value]) => [`--${category}-${name}`, value]),
    ),
  )

process.stdout.write(
  JSON.stringify({ light: flat(semanticColors.light), dark: flat(semanticColors.dark) }),
)
