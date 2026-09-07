import { createTypstCompiler, createTypstRenderer, loadFonts } from '@myriaddreamin/typst.ts';
import compilerWasm from '@myriaddreamin/typst-ts-web-compiler/pkg/typst_ts_web_compiler_bg.wasm?url';
import rendererWasm from '@myriaddreamin/typst-ts-renderer/pkg/typst_ts_renderer_bg.wasm?url';
import vorlage from './vorlage.typ?raw';

const MAIN = '/main.typ';
const BASE = import.meta.env.BASE_URL;

const KONFESSION: Record<string, string> = {
  reformiert: 'evangelisch-reformierten Kirche',
  katholisch: 'römisch-katholischen Kirche',
};

const form = document.getElementById('formular') as HTMLFormElement;
const status = document.getElementById('status') as HTMLParagraphElement;
const download = document.getElementById('download') as HTMLButtonElement;
const vorschau = document.getElementById('vorschau') as HTMLDivElement;

function setStatus(text: string, fehler = false) {
  status.textContent = text;
  status.classList.toggle('fehler', fehler);
}

function heute(): string {
  const d = new Date();
  const p = (n: number) => String(n).padStart(2, '0');
  return `${p(d.getDate())}.${p(d.getMonth() + 1)}.${d.getFullYear()}`;
}

/** Liest das Formular aus und liefert die Daten für `sys.inputs.data`. */
function daten() {
  const fd = new FormData(form);
  const s = (k: string) => String(fd.get(k) ?? '').trim();
  return {
    vorname: s('vorname'),
    name: s('name'),
    geburtsdatum: s('geburtsdatum'),
    strasse: s('strasse'),
    plz: s('plz'),
    ort: s('ort'),
    kg_name: s('kg_name'),
    kg_strasse: s('kg_strasse'),
    kg_plz_ort: s('kg_plz_ort'),
    ort_datum: s('ort_datum'),
    konfession: KONFESSION[s('konfession')] ?? KONFESSION.reformiert,
    keine_kontaktaufnahme: fd.get('keine_kontaktaufnahme') === 'on',
  };
}

// „Ort, Datum“ automatisch aus dem Wohnort vorschlagen, solange der Nutzer
// das Feld nicht selbst angefasst hat.
const ortDatum = form.elements.namedItem('ort_datum') as HTMLInputElement;
const wohnort = form.elements.namedItem('ort') as HTMLInputElement;
let ortDatumManuell = false;
ortDatum.addEventListener('input', () => (ortDatumManuell = true));
function ortDatumVorschlagen() {
  if (ortDatumManuell) return;
  const o = wohnort.value.trim();
  ortDatum.value = o ? `${o}, ${heute()}` : heute();
}
ortDatumVorschlagen();

type Diag = { severity: string; message: string; range?: string };

async function start() {
  const fontUrls = ['Arimo-Regular.ttf', 'Arimo-Bold.ttf'].map(f =>
    new URL(`${BASE}fonts/${f}`, location.href).toString(),
  );

  const compiler = createTypstCompiler();
  const renderer = createTypstRenderer();
  await Promise.all([
    compiler.init({
      getModule: () => compilerWasm,
      beforeBuild: [loadFonts(fontUrls, { assets: false })],
    }),
    renderer.init({ getModule: () => rendererWasm }),
  ]);
  compiler.addSource(MAIN, vorlage);

  async function kompilieren(format: 'vector' | 'pdf'): Promise<Uint8Array> {
    const inputs = { data: JSON.stringify(daten()) };
    const res = await compiler.compile({
      mainFilePath: MAIN,
      inputs,
      format: format === 'pdf' ? 1 : 0,
      diagnostics: 'full',
    });
    const fehler = (res.diagnostics as Diag[] | undefined)?.filter(d => d.severity === 'error');
    if (!res.result || fehler?.length) {
      throw new Error(fehler?.map(d => d.message).join('\n') || 'Kompilierung fehlgeschlagen');
    }
    return res.result;
  }

  let laufend = false;
  let erneut = false;
  async function vorschauAktualisieren() {
    if (laufend) {
      erneut = true;
      return;
    }
    laufend = true;
    try {
      const artefakt = await kompilieren('vector');
      vorschau.innerHTML = await renderer.renderSvg({ artifactContent: artefakt, format: 'vector' });
      setStatus('');
    } catch (e) {
      setStatus(String(e instanceof Error ? e.message : e), true);
    } finally {
      laufend = false;
      if (erneut) {
        erneut = false;
        void vorschauAktualisieren();
      }
    }
  }

  let timer: number | undefined;
  form.addEventListener('input', () => {
    ortDatumVorschlagen();
    window.clearTimeout(timer);
    timer = window.setTimeout(() => void vorschauAktualisieren(), 200);
  });

  form.addEventListener('submit', async ev => {
    ev.preventDefault();
    if (!form.reportValidity()) return;
    download.disabled = true;
    setStatus('PDF wird erstellt …');
    try {
      const pdf = await kompilieren('pdf');
      const blob = new Blob([pdf as BlobPart], { type: 'application/pdf' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      const d = daten();
      const name = [d.name, d.vorname].filter(Boolean).join('-') || 'Formular';
      a.href = url;
      a.download = `Kirchenaustritt-${name.replace(/[^\p{L}\p{N}-]+/gu, '_')}.pdf`;
      a.click();
      setTimeout(() => URL.revokeObjectURL(url), 10_000);
      setStatus('PDF heruntergeladen. Jetzt ausdrucken und unterschreiben.');
    } catch (e) {
      setStatus(String(e instanceof Error ? e.message : e), true);
    } finally {
      download.disabled = false;
    }
  });

  download.disabled = false;
  await vorschauAktualisieren();
}

start().catch(e => {
  console.error(e);
  setStatus(`Typst konnte nicht geladen werden: ${e instanceof Error ? e.message : e}`, true);
});
