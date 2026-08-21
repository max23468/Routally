#!/usr/bin/env node
// Genera gli asset dell'icona di Routally in docs/DESIGN/icon.
//
//   node scripts/build-icon-assets.mjs [cartella]     rigenera gli SVG
//   node scripts/check-icon-assets.mjs                verifica che i file versionati
//                                                     coincidano con questa sorgente
//
// Il segno non va modificato ritoccando gli SVG a mano: le misure qui sotto tengono
// insieme tangenze, contrasto di spessore, compensazione ottica e centraggio, e una
// correzione manuale su un file solo li disallinea fra i due trattamenti cromatici, i
// livelli separati e la derivata Dev. Le regole di costruzione e la loro motivazione
// stanno nella sezione 4.8 del Master Plan.
//
// Scelte che non si leggono dai numeri:
//
// - il contorno esterno del ciclo e' un'ellisse mentre il contatore resta un cerchio
//   esatto, cosi' il ciclo pesa piu' sui fianchi che sulle curve orizzontali, come
//   nell'asse verticale tipografico. Un anello monolineare, a parita' di massa, appare
//   piu' pesante in alto;
// - il segno su fondo indaco e' disegnato al 97 per cento dello spessore, perche' un
//   segno chiaro su fondo scuro appare piu' grosso per irradiazione;
// - il secondo ciclo delle varianti a incastro non e' collocato ma ricavato: e' tangente
//   a gamba, linea di base e ciclo principale, e il raggio e' l'unico che soddisfa le tre
//   condizioni. Viene risolto per bisezione;
// - il punto portato al centro della tela non e' il centro dell'ingombro ma sta a tre
//   quarti verso il centro della sola lettera, quando l'accento e' un accessorio come
//   l'arco: l'arco e' sottile e allunga il rettangolo verso l'alto, e centrare quello
//   lascerebbe la lettera sotto il centro;
// - i livelli in layers/ hanno le coordinate gia' trasformate, con precisione a quattro
//   decimali: a due, il raggio scalato di un arco si sposta quanto basta a muovere il
//   bordo di mezzo pixel rispetto al file unico.
import { mkdirSync, writeFileSync, rmSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

export const DEFAULT_OUTPUT = "docs/DESIGN/icon";

const n = (v) => Math.round(v * 100) / 100;
const rad = (d) => (d * Math.PI) / 180;
const BASE = 848, OVER = 6, STRESS = 288 / 274;

// ink: fattore di compensazione ottica. Assottiglia il segno mantenendo fermo il contatore.
function makeShapes(ink) {
  const bounds = [];
  const add = (x0, y0, x1, y1) => bounds.push([x0, y0, x1, y1]);
  const mk = (cx, cy, rx, ri) => {
    const rxi = ri + (rx - ri) * ink;                 // il contorno si avvicina al contatore
    return { cx, cy, rx: rxi, ry: ri + (rx / STRESS - ri) * ink, ri };
  };

  function onE(c, deg, d = 0) {
    const co = Math.cos(rad(deg)), s = Math.sin(rad(deg));
    const r = 1 / Math.sqrt((co / c.rx) ** 2 + (s / c.ry) ** 2) + d;
    return [c.cx + r * co, c.cy + r * s];
  }
  const onC = (c, r, deg) => [c.cx + r * Math.cos(rad(deg)), c.cy + r * Math.sin(rad(deg))];

  const cycle = (c) => (
    add(c.cx - c.rx, c.cy - c.ry, c.cx + c.rx, c.cy + c.ry),
    `<path fill-rule="evenodd" d="M ${n(c.cx + c.rx)} ${n(c.cy)} A ${n(c.rx)} ${n(c.ry)} 0 1 1 ${n(c.cx - c.rx)} ${n(c.cy)} A ${n(c.rx)} ${n(c.ry)} 0 1 1 ${n(c.cx + c.rx)} ${n(c.cy)} Z M ${n(c.cx + c.ri)} ${n(c.cy)} A ${n(c.ri)} ${n(c.ri)} 0 1 1 ${n(c.cx - c.ri)} ${n(c.cy)} A ${n(c.ri)} ${n(c.ri)} 0 1 1 ${n(c.cx + c.ri)} ${n(c.cy)} Z"/>`);

  function cycleOpen(c, a0, a1) {
    add(c.cx - c.rx, c.cy - c.ry, c.cx + c.rx, c.cy + c.ry);
    const span = (((a1 - a0) % 360) + 360) % 360, large = span > 180 ? 1 : 0;
    const [ox0, oy0] = onE(c, a0), [ox1, oy1] = onE(c, a1);
    const [ix0, iy0] = onC(c, c.ri, a0), [ix1, iy1] = onC(c, c.ri, a1);
    return `<path d="M ${n(ox0)} ${n(oy0)} A ${n(c.rx)} ${n(c.ry)} 0 ${large} 1 ${n(ox1)} ${n(oy1)} L ${n(ix1)} ${n(iy1)} A ${n(c.ri)} ${n(c.ri)} 0 ${large} 0 ${n(ix0)} ${n(iy0)} Z"/>`;
  }

  const flank = (c) => (
    add(c.cx - c.rx, c.cy, c.cx - c.ri, BASE),
    `<rect x="${n(c.cx - c.rx)}" y="${n(c.cy)}" width="${n(c.rx - c.ri)}" height="${n(BASE - c.cy)}"/>`);

  // Vertici della gamba: servono sia a disegnarla sia a risolvere la tangenza del
  // secondo ciclo, che deve appoggiarsi al suo bordo destro.
  function legPolygon(jx, jy, footX, t0 = 104, t1 = 118) {
    const a = t0 * ink, b = t1 * ink;
    const dx = footX - jx, dy = BASE - jy, len = Math.hypot(dx, dy);
    const nx = -dy / len, ny = dx / len;
    const edge = (sg) => {
      const p0 = [jx + sg * nx * (a / 2), jy + sg * ny * (a / 2)];
      const p1 = [footX + sg * nx * (b / 2), BASE + sg * ny * (b / 2)];
      const k = (BASE - p0[1]) / (p1[1] - p0[1]);
      return [[p0[0], p0[1]], [p0[0] + k * (p1[0] - p0[0]), BASE]];
    };
    const [pTop, pFoot] = edge(1), [qTop, qFoot] = edge(-1);
    return [pTop, pFoot, qFoot, qTop];
  }

  function leg(jx, jy, footX, t0 = 104, t1 = 118) {
    const pts = legPolygon(jx, jy, footX, t0, t1);
    add(Math.min(...pts.map((q) => q[0])), Math.min(...pts.map((q) => q[1])),
        Math.max(...pts.map((q) => q[0])), Math.max(...pts.map((q) => q[1])));
    return `<path d="M ${pts.map(([x, y]) => `${n(x)} ${n(y)}`).join(" L ")} Z"/>`;
  }

  function echoTaper(c, a0, a1, d, w0, w1, steps = 96) {
    const out = [], inn = [];
    for (let i = 0; i <= steps; i += 1) {
      const t = i / steps, a = a0 + (a1 - a0) * t, w = (w0 + (w1 - w0) * t) * ink;
      out.push(onE(c, a, d + w / 2));
      inn.push(onE(c, a, d - w / 2));
    }
    const pts = [...out, ...inn.reverse()];
    add(Math.min(...pts.map((p) => p[0])), Math.min(...pts.map((p) => p[1])),
        Math.max(...pts.map((p) => p[0])), Math.max(...pts.map((p) => p[1])));
    return `<path d="M ${pts.map(([x, y]) => `${n(x)} ${n(y)}`).join(" L ")} Z"/>`;
  }

  function echoArc(c, a0, a1, d, w) {
    const span = (((a1 - a0) % 360) + 360) % 360;
    const [x0, y0] = onE(c, a0, d), [x1, y1] = onE(c, a1, d);
    // Registra l'ingombro campionando l'arco: senza questo l'inquadratura non lo vedrebbe.
    for (let i = 0; i <= 64; i += 1) {
      const a = a0 + (span * i) / 64;
      const [px, py] = onE(c, a, d);
      const r = (w * ink) / 2;
      add(px - r, py - r, px + r, py + r);
    }
    return `<path d="M ${n(x0)} ${n(y0)} A ${n(c.rx + d)} ${n(c.ry + d)} 0 ${span > 180 ? 1 : 0} 1 ${n(x1)} ${n(y1)}" fill="none" stroke="currentColor" stroke-width="${n(w * ink)}" stroke-linecap="butt"/>`;
  }

  // Testa centrata esattamente sulla fine dell'arco: nessun collo, nessun taglio.
  const head = (c, deg, d, r) => {
    const [x, y] = onE(c, deg, d);
    add(x - r * ink, y - r * ink, x + r * ink, y + r * ink);
    return `<circle cx="${n(x)}" cy="${n(y)}" r="${n(r * ink)}" fill="currentColor"/>`;
  };

  // Composizione a due cicli: il secondo ricavato per tripla tangenza.
  const M = mk(420, 400, 240, 120);
  const LEG = { jx: 300, jy: 560, foot: 500 };

  // Il secondo ciclo non viene collocato ma ricavato: tangente alla linea di base, al
  // bordo destro della gamba e al ciclo principale. Le tre condizioni vanno risolte
  // sull'ellisse nella sua posizione finale. Risolvere su un cerchio e poi schiacciarlo
  // in ellisse e riappoggiarlo alla base distrugge entrambe le tangenze: e' l'errore
  // corretto qui, che lasciava sedici unita' di luce dal ciclo e faceva compenetrare
  // la gamba.
  function solveSecondCycle() {
    const pts = legPolygon(LEG.jx, LEG.jy, LEG.foot);
    const edges = [[pts[0], pts[1]], [pts[3], pts[2]]];
    const [a, b] = edges.reduce((best, e) => (e[0][0] + e[1][0] > best[0][0] + best[1][0] ? e : best));
    const ex = b[0] - a[0], ey = b[1] - a[1], elen = Math.hypot(ex, ey);
    let nx = ey / elen, ny = -ex / elen;
    if (nx < 0) { nx = -nx; ny = -ny; }

    // Campioni del contorno. La tangenza risulta risolta entro un decimo di unita' su una
    // tela di 1024, cioe' sotto la precisione di qualunque resa: alzarli a 2880 sposta il
    // residuo fra i due trattamenti invece di ridurlo, e porta la generazione a venti secondi.
    const SAMPLES = 720;
    // La forma provata dal solutore deve essere quella che finisce nel file, cioe' gia'
    // assottigliata dalla compensazione ottica: risolvere sull'ellisse piena e comprimerla
    // dopo lascia la tangenza solo al trattamento chiaro e la perde su quello indaco.
    const shape = (rx, cx) => {
      const ri = rx - 54;
      const ry = ri + (rx / STRESS - ri) * ink;
      return { cx, cy: BASE + OVER - ry, rx: ri + (rx - ri) * ink, ry };
    };
    const contour = (e) =>
      Array.from({ length: SAMPLES }, (_, i) => {
        const t = (i * 2 * Math.PI) / SAMPLES;
        return [e.cx + e.rx * Math.cos(t), e.cy + e.ry * Math.sin(t)];
      });
    // Distanza con segno dal bordo della gamba: negativa se l'ellisse lo attraversa.
    const legClearance = (rx, cx) =>
      Math.min(...contour(shape(rx, cx)).map(([x, y]) => (x - a[0]) * nx + (y - a[1]) * ny));
    // Posizione rispetto al ciclo principale: negativa se lo compenetra.
    const mainClearance = (rx, cx) =>
      Math.min(
        ...contour(shape(rx, cx)).map(
          ([x, y]) => ((x - M.cx) / M.rx) ** 2 + ((y - M.cy) / M.ry) ** 2 - 1,
        ),
      );

    // Per un raggio dato, l'unica posizione orizzontale che tocca la gamba senza entrarci.
    const cxTangent = (rx) => {
      let lo = LEG.foot - 400, hi = LEG.foot + 900;
      for (let i = 0; i < 90; i += 1) {
        const mid = (lo + hi) / 2;
        if (legClearance(rx, mid) < 0) lo = mid;
        else hi = mid;
      }
      return (lo + hi) / 2;
    };
    // Il raggio cresce finche' l'ellisse, gia' tangente a gamba e base, tocca il ciclo.
    let lo = 40, hi = 320;
    for (let i = 0; i < 90; i += 1) {
      const rx = (lo + hi) / 2;
      if (mainClearance(rx, cxTangent(rx)) > 0) lo = rx;
      else hi = rx;
    }
    const rx = (lo + hi) / 2;
    return { rx, cx: cxTangent(rx) };
  }

  const SOL = solveSecondCycle();
  const S = mk(SOL.cx, 0, SOL.rx, SOL.rx - 54);
  S.cy = BASE + OVER - S.ry;

  const E = mk(540, 440, 288, 168);
  // Inquadratura automatica: il segno viene scalato e centrato nel riquadro utile,
  // cosi' aumentare l'aria attorno alla R non richiede di ricentrare a mano.
  const snapshot = () => bounds.map((b) => b.slice());
  const centerOf = (bs) => [
    (Math.min(...bs.map((b) => b[0])) + Math.max(...bs.map((b) => b[2]))) / 2,
    (Math.min(...bs.map((b) => b[1])) + Math.max(...bs.map((b) => b[3]))) / 2,
  ];
  // focus: punto del segno da portare al centro della tela. Se assente si usa il centro
  // del rettangolo d'ingombro, che pero' non coincide con il soggetto quando un elemento
  // sottile allunga l'ingombro da un lato.
  const fit = (boxW = 762, boxH = 700, cy = 500, focus = null) => {
    const x0 = Math.min(...bounds.map((b) => b[0])), y0 = Math.min(...bounds.map((b) => b[1]));
    const x1 = Math.max(...bounds.map((b) => b[2])), y1 = Math.max(...bounds.map((b) => b[3]));
    let sc = Math.min(boxW / (x1 - x0), boxH / (y1 - y0));
    const [fx, fy] = focus ?? [(x0 + x1) / 2, (y0 + y1) / 2];
    if (focus) sc = Math.min(sc, 392 / Math.max(fx - x0, x1 - fx), 380 / (fy - y0), 404 / (y1 - fy));
    const shift = [512 - fx, (cy - 512) / sc + 512 - fy];
    // Verifica: applica la stessa formula del livello e controlla dove cade il punto scelto.
    const T = (i) => 512 * (1 - sc) + sc * shift[i];
    const got = [fx * sc + T(0), fy * sc + T(1)];
    if (Math.abs(got[0] - 512) > 0.5 || Math.abs(got[1] - cy) > 0.5) {
      throw new Error(`centraggio errato: atteso 512/${cy}, ottenuto ${got.map((v) => v.toFixed(1)).join("/")}`);
    }
    return { scale: sc, shift };
  };
  return { cycle, cycleOpen, flank, leg, echoTaper, echoArc, head, M, S, E, LEG, fit, bounds, snapshot, centerOf };
}

// Il punto da centrare sta a tre quarti fra il centro dell'ingombro e quello del soggetto:
// azzera lo scarto verticale della lettera senza sbilanciare l'insieme.
const SUBJECT_PULL = 0.75;
function subjectFocus(s, symBounds) {
  const cS = s.centerOf(symBounds), cA = s.centerOf(s.bounds);
  return [cA[0] + (cS[0] - cA[0]) * SUBJECT_PULL, cA[1] + (cS[1] - cA[1]) * SUBJECT_PULL];
}

const ECHO = { d: 56, a0: 180, a1: 330 };

const AIR = [
  { slug: "a1-air-medium", title: "Aria misurata", d: 92, w0: 30, w1: 74, head: 54,
    concept: "L'eco si stacca dalla R di novantadue unita' invece di cinquantasei e ingrossa fino a settantaquattro. La R rimpicciolisce quel tanto che serve a fare posto: nella tela fissa dell'icona, o si allontana l'arco o si tiene grande la lettera, non entrambe." },
  { slug: "a2-air-wide", title: "Aria decisa", d: 128, w0: 36, w1: 86, head: 62,
    concept: "Il distacco sale a centoventotto e l'arco arriva a ottantasei: l'eco diventa un elemento autonomo che accompagna la lettera invece di appoggiarvisi. E' la lettura piu' netta e quella che regge meglio alle misure minime, dove un arco sottile e vicino si confonde con il ciclo." },
  { slug: "a3-air-wide-short", title: "Aria decisa, arco corto", d: 128, w0: 40, w1: 88, head: 64, a0: 205,
    concept: "Stesso distacco della precedente ma l'arco parte piu' in alto, a duecentocinque gradi invece che a centottanta: copre meno lettera, pesa di piu' e lascia respirare il fianco. L'eco smette di scavalcare il segno e diventa un gesto breve." },
];

// Fascia diagonale sull'angolo in basso a sinistra: marca la build di sviluppo della
// sezione 30.1 senza testo, che nell'icona richiederebbe un font di sistema.
const DEV_BAND = '<path d="M 0 604 L 420 1024 L 270 1024 L 0 754 Z"/>';

function buildConcepts(ink) {
  const air = AIR.map((v) => {
    const s = makeShapes(ink);
    const symbol = [s.cycle(s.E), s.flank(s.E), s.leg(372, 600, 740)];
    const symBounds = s.snapshot();
    const accent = [s.echoTaper(s.E, v.a0 ?? 180, 330, v.d, v.w0, v.w1), s.head(s.E, 330, v.d, v.head)];
    const box = s.fit(762, 700, 500, subjectFocus(s, symBounds));
    return { slug: v.slug, title: v.title, concept: v.concept, symbol, accent, shift: box.shift, scale: box.scale };
  });

  const s = makeShapes(ink);
  const legacy = [];
  // Ogni variante viene inquadrata sul proprio ingombro reale: nessuno scostamento a mano.
  // Limiti del solo segno, ricostruiti su un'istanza di scarto: contarli per differenza
  // sarebbe sbagliato, perche' un arco registra un ingombro per ogni punto campionato.
  const markBounds = () => {
    const t = makeShapes(ink);
    t.cycle(t.E); t.flank(t.E); t.leg(372, 600, 740);
    return t.snapshot();
  };
  const push = (slug, title, concept, make, onSubject = false) => {
    s.bounds.length = 0;
    const { symbol, accent } = make();
    const box = s.fit(762, 700, 500, onSubject ? subjectFocus(s, markBounds()) : null);
    legacy.push({ slug, title, concept, symbol, accent, shift: box.shift, scale: box.scale });
  };

  push(
    "t1-cycle-consequence",
    "Il segno ridotto",
    "Il ciclo, il fianco che scende, la gamba. E' il segno essenziale e insieme la versione ridotta di tutte le altre: quando l'eco o il secondo ciclo si chiudono otticamente alle misure minime, e' su questo che il marchio degrada. Per questo resta agli atti anche se le varianti scelte sono altre.",
    () => ({ symbol: [s.cycle(s.E), s.flank(s.E), s.leg(372, 600, 740)], accent: [] }),
  );
  push(
    "t2-cycle-threshold",
    "Il ciclo aperto alla soglia",
    "Il segno ridotto con un varco radiale di ventisei gradi centrato sulla diagonale: il ciclo che ha raggiunto la soglia ed e' pronto a ripartire. Il varco sta nel punto meno strutturale del segno e lascia intatti fianco e gamba.",
    () => ({ symbol: [s.cycleOpen(s.E, 329, 303), s.flank(s.E), s.leg(372, 600, 740)], accent: [] }),
  );
  push(
    "v1-nested-cycle",
    "Il ciclo che si incastra",
    "Il secondo ciclo non sta accanto al segno ma dentro la sua struttura: si incastra nell'angolo fra gamba e linea di base ed e' tangente a tutte e tre, gamba, base e ciclo principale. Il raggio non e' scelto, e' l'unico che soddisfa le tre tangenze.",
    () => ({ symbol: [s.cycle(s.M), s.flank(s.M), s.leg(s.LEG.jx, s.LEG.jy, s.LEG.foot)], accent: [s.cycle(s.S)] }),
  );
  push(
    "v2-nested-cycle-threshold",
    "L'incastro e la soglia",
    "La stessa costruzione con il varco radiale nel ciclo principale: la soglia raggiunta e il ciclo che ne consegue, incastrato nella struttura invece che appoggiato di fianco.",
    () => ({ symbol: [s.cycleOpen(s.M, 329, 303), s.flank(s.M), s.leg(s.LEG.jx, s.LEG.jy, s.LEG.foot)], accent: [s.cycle(s.S)] }),
  );
  push(
    "v3-nested-cycle-opening",
    "L'incastro appena aperto",
    "Il ciclo principale e' compiuto, il secondo si apre verso la gamba che lo raggiunge. La conseguenza non e' un oggetto consegnato ma un ciclo che comincia, e il varco impedisce al cerchio di leggersi come una lettera.",
    () => ({ symbol: [s.cycle(s.M), s.flank(s.M), s.leg(s.LEG.jx, s.LEG.jy, s.LEG.foot)], accent: [s.cycleOpen(s.S, 235, 205)] }),
  );

  const dev = (() => {
    const d = makeShapes(ink);
    const v = AIR[0];
    const symbol = [d.cycle(d.E), d.flank(d.E), d.leg(372, 600, 740)];
    const symBounds = d.snapshot();
    const accent = [d.echoTaper(d.E, 180, 330, v.d, v.w0, v.w1), d.head(d.E, 330, v.d, v.head)];
    const box = d.fit(762, 700, 500, subjectFocus(d, symBounds));
    return {
      slug: "dev-app-icon",
      title: "Icona della build di sviluppo",
      concept:
        "Il segno approvato con una fascia diagonale sull'angolo in basso a sinistra: distingue a colpo d'occhio la build Dev della sezione 30.1 da quella pubblica, senza ricorrere a testo, che in un'icona richiederebbe un font di sistema e sparirebbe alle misure minime. La fascia corre sotto il piede del fianco e non tocca nessun tratto del segno, che resta identico a quello pubblico.",
      shift: box.shift,
      scale: box.scale,
      symbol,
      accent,
      overlay: DEV_BAND,
    };
  })();

  return [...legacy, ...air, dev];
}

const THEMES = {
  indigo: { bg: "#4C46D8", symbol: "#FFFFFF", accent: "#CAC7FF", ink: 0.97, label: "fondo indaco brand, segno chiaro, accento nella variante a contrasto aumentato, spessori compensati al 97 per cento per l'irradiazione" },
  light: { bg: "#FFFFFF", symbol: "#4C46D8", accent: "#3429BD", ink: 1, label: "fondo chiaro, segno indaco brand, spessori pieni" },
};

const layer = (id, color, items, shift, scale = 1) =>
  !items.length ? "" : [
    `  <g id="${id}" fill="${color}" color="${color}" transform="translate(${n(512 * (1 - scale) + scale * shift[0])} ${n(512 * (1 - scale) + scale * shift[1])}) scale(${scale})">`,
    ...items.map((i) => `    ${i}`),
    "  </g>",
  ].join("\n");

function svg(c, themeName) {
  const t = THEMES[themeName];
  const desc = `${c.concept} Sistema condiviso: contorno esterno ellittico in rapporto 288 a 274 con contatore circolare esatto, per cui il ciclo pesa piu' sui fianchi che sulle curve orizzontali secondo l'asse verticale tipografico; il fianco continua la tangente verticale del ciclo fino alla linea di base 848; gamba rastremata con taglio orizzontale sul piede; terminali degli archi tagliati sui raggi; overshoot ottico di 6 per le forme circolari che appoggiano alla base; varco, arresto dell'eco e apertura del secondo ciclo cadono tutti sulla stessa diagonale a quarantacinque gradi. Trattamento cromatico: ${t.label}. Livelli per Icon Composer: background, symbol${c.accent.length ? ", accent" : ""}. Esplorazione per il Decision Gate DG-ICON: nessuna scelta definitiva.`;
  return [
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024" role="img" aria-labelledby="title desc">`,
    `  <title id="title">Routally — ${c.title}</title>`,
    `  <desc id="desc">${desc}</desc>`,
    `  <g id="background">`,
    `    <rect x="0" y="0" width="1024" height="1024" fill="${t.bg}"/>`,
    `  </g>`,
    layer("symbol", t.symbol, c.symbol, c.shift, c.scale ?? 1),
    layer("accent", t.accent, c.accent, c.shift, c.scale ?? 1),
    c.overlay ? `  <g id="overlay" fill="${t.accent}">\n    ${c.overlay}\n  </g>` : "",
    `</svg>`,
    "",
  ].filter((l) => l !== "").join("\n");
}


// Applica traslazione e scala alle coordinate, per esportare livelli senza transform.
// I path vengono percorsi comando per comando: una sola espressione regolare non basta,
// perche' M e L consumano due numeri mentre A ne consuma sette.
const n4 = (v) => Math.round(v * 10000) / 10000;

// Applica traslazione e scala alle coordinate, per esportare livelli autonomi senza
// transform. I path vengono percorsi comando per comando: una sola espressione regolare
// non basta, perche' M e L consumano due numeri mentre A ne consuma sette. La precisione
// e' a quattro decimali: a due, il raggio scalato di un arco si sposta quanto basta a
// muovere il bordo di mezzo pixel rispetto al file unico.
function flattenPath(d, tx, ty, sc) {
  const tok = d.match(/[MLAZ]|-?[\d.]+/g) ?? [];
  const out = [];
  const P = (x, y) => [n4(x * sc + tx), n4(y * sc + ty)];
  let i = 0;
  while (i < tok.length) {
    const cmd = tok[i];
    i += 1;
    if (cmd === "Z") {
      out.push("Z");
    } else if (cmd === "M" || cmd === "L") {
      const [x, y] = P(+tok[i], +tok[i + 1]);
      i += 2;
      out.push(`${cmd} ${x} ${y}`);
    } else if (cmd === "A") {
      const rx = +tok[i], ry = +tok[i + 1], rot = tok[i + 2], laf = tok[i + 3], sf = tok[i + 4];
      const [x, y] = P(+tok[i + 5], +tok[i + 6]);
      i += 7;
      out.push(`A ${n4(rx * sc)} ${n4(ry * sc)} ${rot} ${laf} ${sf} ${x} ${y}`);
    } else {
      throw new Error(`comando di path non gestito: ${cmd}`);
    }
  }
  return out.join(" ");
}

function flatten(body, tx, ty, sc) {
  const P = (x, y) => [n4(x * sc + tx), n4(y * sc + ty)];
  return body
    .replace(/<rect x="([-\d.]+)" y="([-\d.]+)" width="([\d.]+)" height="([\d.]+)"/g,
      (_, x, y, w, h) => {
        const [X, Y] = P(+x, +y);
        return `<rect x="${X}" y="${Y}" width="${n4(+w * sc)}" height="${n4(+h * sc)}"`;
      })
    .replace(/<circle cx="([-\d.]+)" cy="([-\d.]+)" r="([\d.]+)"/g,
      (_, cx, cy, r) => {
        const [X, Y] = P(+cx, +cy);
        return `<circle cx="${X}" cy="${Y}" r="${n4(+r * sc)}"`;
      })
    .replace(/<ellipse cx="([-\d.]+)" cy="([-\d.]+)" rx="([\d.]+)" ry="([\d.]+)"/g,
      (_, cx, cy, rx, ry) => {
        const [X, Y] = P(+cx, +cy);
        return `<ellipse cx="${X}" cy="${Y}" rx="${n4(+rx * sc)}" ry="${n4(+ry * sc)}"`;
      })
    .replace(/stroke-width="([\d.]+)"/g, (_, w) => `stroke-width="${n4(+w * sc)}"`)
    .replace(/ d="([^"]+)"/g, (_, d) => ` d="${flattenPath(d, tx, ty, sc)}"`);
}

// Esporta i livelli come file separati, per l'import in Icon Composer.
const LAYERED = new Set(["a1-air-medium", "dev-app-icon"]);
function layerFiles(c, themeName) {
  const t = THEMES[themeName];
  const sc = c.scale ?? 1;
  const tx = 512 * (1 - sc) + sc * c.shift[0], ty = 512 * (1 - sc) + sc * c.shift[1];
  const wrap = (inner) =>
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">\n${inner}\n</svg>\n`;
  const group = (id, color, items) =>
    `  <g id="${id}" fill="${color}" color="${color}">\n${items.map((i) => "    " + flatten(i, tx, ty, sc)).join("\n")}\n  </g>`;
  const out = {
    background: wrap(`  <rect x="0" y="0" width="1024" height="1024" fill="${t.bg}"/>`),
    symbol: wrap(group("symbol", t.symbol, c.symbol)),
  };
  if (c.accent.length) out.accent = wrap(group("accent", t.accent, c.accent));
  if (c.overlay) out.overlay = wrap(`  <g id="overlay" fill="${t.accent}">\n    ${c.overlay}\n  </g>`);
  return out;
}

// Produce i file dell'icona. Restituisce nome e contenuto, cosi' che il controllo possa
// confrontarli con i file versionati senza scrivere nulla su disco.
export function iconAssets() {
  const files = new Map();
  for (const [themeName, t] of Object.entries(THEMES)) {
    for (const c of buildConcepts(t.ink)) {
      files.set(`${c.slug}-${themeName}.svg`, svg(c, themeName));
      if (LAYERED.has(c.slug)) {
        for (const [name, body] of Object.entries(layerFiles(c, themeName))) {
          files.set(join("layers", `${c.slug}-${themeName}-${name}.svg`), body);
        }
      }
    }
  }
  return files;
}

// Scrive gli asset. Rimuove soltanto gli SVG generati: cancellare l'intera cartella
// porterebbe via anche i file scritti a mano, come il README.
export function build(outDir = DEFAULT_OUTPUT) {
  const files = iconAssets();
  mkdirSync(join(outDir, "layers"), { recursive: true });
  for (const dir of [outDir, join(outDir, "layers")]) {
    for (const f of readdirSync(dir)) if (f.endsWith(".svg")) rmSync(join(dir, f));
  }
  for (const [name, body] of files) writeFileSync(join(outDir, name), body, "utf8");
  return files.size;
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? "").href) {
  const outDir = resolve(process.argv[2] ?? DEFAULT_OUTPUT);
  console.log(`${build(outDir)} file scritti in ${outDir}`);
}
