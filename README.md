# Gratis Kirchenaustritt-Formular

Einfache Website, die eine Kirchenaustrittserklärung für die reformierte oder
römisch-katholische Kirche in der Schweiz als PDF erzeugt. Das Dokument wird
mit [typst.ts](https://github.com/Myriad-Dreamin/typst.ts) vollständig im
Browser gesetzt. Es gibt keinen Server, es werden keine Daten übertragen.

## Entwicklung

```sh
npm install
npm run dev
```

`npm run build` erzeugt die statische Seite in `dist/`.

## Deployment

Der Workflow in `.github/workflows/deploy.yml` baut die Seite bei jedem Push
auf `main` und veröffentlicht sie auf GitHub Pages. In den Repository-Settings
muss unter *Pages* die Quelle auf *GitHub Actions* gestellt sein.

## Vorlage

Die Briefvorlage liegt in `src/vorlage.typ`. Die Werte aus dem Formular werden
als JSON über `sys.inputs.data` übergeben. Als Schrift wird Arial verwendet,
gebündelt ist die metrisch identische, frei lizenzierte Schrift Arimo
(`public/fonts/`). Wer echte Arial-Dateien besitzt, kann sie dort ablegen und
in `src/main.ts` in die Font-Liste aufnehmen.
