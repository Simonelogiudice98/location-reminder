# Handoff: GeoReminder — App promemoria basati sulla posizione

## Overview
GeoReminder è un'app mobile che permette di creare promemoria geolocalizzati: l'utente piazza un pin sulla mappa, imposta un raggio di attivazione, e riceve una notifica quando entra in quell'area. Questo pacchetto contiene il design completo di 4 schermate principali più stati e varianti, realizzato secondo Material Design 3.

Target device: **iPhone 14 / standard mobile, 390 × 844 px**. Stack di riferimento indicato dal brief originale: **Flutter** (Material Design 3). I design sono comunque framework-agnostici.

## Screenshots
Anteprime renderizzate a dimensione reale (390 × 844) nella cartella `screenshots/`:

| # | Schermata | File |
|---|---|---|
| 01 | Mappa principale | `screenshots/01_mappa_principale.png` |
| 02 | Creazione reminder (bottom sheet) | `screenshots/02_creazione_reminder.png` |
| 03 | Lista promemoria | `screenshots/03_lista_promemoria.png` |
| 04 | Onboarding · coach mark (step 1) | `screenshots/04_onboarding_coachmark.png` |
| 05 | Lista · stato vuoto | `screenshots/05_lista_stato_vuoto.png` |
| 06 | Variante FAB esteso “Aggiungi” | `screenshots/06_fab_esteso.png` |

> Le immagini sono riferimenti visivi statici. Per il comportamento e le animazioni, apri i file `.dc.html` (in particolare `Flow.dc.html` e `GeoReminder.dc.html`) in un browser.

## About the Design Files
I file `.dc.html` in questo bundle sono **riferimenti di design creati in HTML** — prototipi che mostrano look e comportamento desiderati, **non codice di produzione da copiare direttamente**. Il compito è **ricreare questi design nell'ambiente del codebase di destinazione** (Flutter/Dart con Material 3, oppure React Native, SwiftUI, ecc.) usando i pattern e le librerie consolidate di quel progetto. Se non esiste ancora un ambiente, lo stack consigliato dal brief è **Flutter con Material 3**.

I file usano un piccolo runtime interno (`support.js`) per il rendering dei componenti: serve solo a far girare i prototipi nel browser, **non va portato nel codebase**. Apri `GeoReminder.dc.html` in un browser per vedere tutte le schermate insieme e il prototipo interattivo.

## Fidelity
**High-fidelity (hifi)**. Colori, tipografia, spaziature, raggi e interazioni sono definitivi. Ricreare la UI fedelmente usando le librerie/pattern del codebase. Le icone sono **Material Symbols Outlined** (equivalenti alle `Icons.*` di Flutter / `material-symbols`).

> Nota: la mappa è una **illustrazione stilizzata originale** (vie, parchi, acqua), non Google Maps. In produzione va sostituita con il vero widget mappa (es. `google_maps_flutter`), mantenendo i pin teal, il marker posizione utente e il FAB sovrapposti.

---

## Design Tokens

### Colori
| Token | Hex | Uso |
|---|---|---|
| Primary | `#00897B` | FAB, switch attivi, bottoni, elementi interattivi, AppBar lista |
| Primary dark | `#00695C` | pin/stati premuti, accenti scuri |
| Accent | `#4DB6AC` | illustrazioni, icone secondarie, conferme toast |
| Primary container | `#E0F2F1` | sfondi soft (icona pin nelle card, box coordinate, cerchio empty state) |
| Background | `#FFFFFF` | superfici card, bottom sheet |
| Surface | `#F5F5F5` | sfondo schermata lista |
| Text primary | `#212121` | titoli, testo principale |
| Text secondary | `#757575` | sottotitoli, label |
| Text tertiary / hint | `#9AA0A6` | placeholder, testo disabilitato |
| Divider / border | `#D5D8D6` / `#E2E5E4` | bordi, handle, separatori |
| Map land | `#E9ECEA` | sfondo terra mappa |
| Map water | `#AEDCE6` | acqua mappa |
| Map park | `#C6E7C9` | parchi mappa |
| Map road fill | `#FFFFFF` su casing `#D5D8D6` | strade |
| User location | `#1A73E8` | marker posizione (blu, non teal — convenzione mappe) |
| Toast bg | `#2C322F` | snackbar scura |
| Disabled button | `#BFC7C4` | bottone Salva disattivato |
| Delete swipe | `#E5484D` | sfondo azione elimina |

### Tipografia
- Famiglia: **Roboto** (titoli w600, body w400, label w500). Monospace per dati tecnici/coordinate: Roboto Mono.
- Scala:
  - AppBar title: 22px / w600
  - Sheet title: 20px / w600
  - Card title: 16px / w600
  - Body / input: 16px / w400
  - Sottotitolo card / descrizioni: 13–14px / w400, colore `#757575`
  - Label campi: 12px / w500
  - Bottom nav label: 12px / w600
  - Status bar: 15px / w600

### Spaziatura, raggi, ombre
- Border radius: **card = 12px**, bottom sheet = 20px (top), FAB tondo = 50% / FAB esteso = 18px, bottoni pill = 22–26px, box coordinate/input = 8–10px.
- Padding card: 16px. Gap lista: 12px. Padding schermo: 16–20px.
- Ombra card: `0 1px 3px rgba(0,0,0,.10), 0 1px 2px rgba(0,0,0,.06)`.
- Ombra FAB: `0 4px 10px rgba(0,137,123,.4), 0 2px 4px rgba(0,0,0,.2)`.
- Ombra AppBar: `0 2px 6px rgba(0,0,0,.18)`.
- Ombra bottom sheet: `0 -6px 24px rgba(0,0,0,.18)`.
- Bottom nav height: 64px. FAB: 56px. Hit target minimo: 44px.

---

## Screens / Views

### 1. Mappa principale (home) — `MapHome.dc.html`
- **Purpose**: schermata di partenza; l'utente vede i propri promemoria sulla mappa e ne crea di nuovi.
- **Layout**: mappa **fullscreen senza AppBar**. Overlay sovrapposti: status bar (top, 48px), search pill (top 60px, full-width meno 16px margini), bottone "ricentra" (in basso a destra, sopra il FAB), FAB (basso destra), bottom navigation (bottom, 64px).
- **Componenti**:
  - **Search pill**: bianca, h48, radius 26, ombra `0 2px 8px rgba(0,0,0,.16)`. Icona `search` grigia, testo placeholder "Cerca un luogo" `#9AA0A6`, avatar tondo 30px (`person`) a destra con sfondo `#E0F2F1`.
  - **Pin reminder**: icona `location_on` filled, 42px, colore `#00897B` (attivi) o `#00695C`, con `drop-shadow(0 3px 3px rgba(0,0,0,.3))`. Animazione di "drop" all'ingresso (cadono dall'alto con stagger 0.4–0.7s).
  - **Marker posizione utente**: punto blu `#1A73E8` 18px con bordo bianco 3px + alone pulsante (`@keyframes` scale 0.6→2.4, opacity 0.55→0, loop 2.4s).
  - **FAB**: tondo 56px, `#00897B`, icona `add` bianca 26px. *Variante estesa* (vedi sotto): radius 18, padding `0 20px 0 18px`, icona + label "Aggiungi" w600 bianca.
  - **Recenter button**: bianco tondo 44px, icona `my_location` teal.
  - **Bottom navigation**: 2 voci — "Mappa" (`map`) e "Promemoria" (`format_list_bulleted`). Sfondo **semi-trasparente con blur**: `rgba(255,255,255,0.82)` + `backdrop-filter: blur(16px)`, bordo top `rgba(0,0,0,0.06)`. Voce attiva teal con icona FILL 1; inattiva `#757575` FILL 0. Label 12px w600.
- **Interazione chiave**: **long-press sulla mappa (~480ms)** apre il bottom sheet di creazione. Anche il FAB lo apre.

### 2. Bottom sheet — Creazione reminder — `CreateSheet.dc.html`
- **Purpose**: creare/modificare un promemoria.
- **Layout**: scrim scuro `rgba(0,0,0,0.42)` (tap per chiudere) + sheet che sale dal basso, `border-radius: 20px 20px 0 0`, sfondo bianco. Animazione: `transform: translateY(102%→0)`, transition `.34s cubic-bezier(.2,.85,.25,1)`; scrim fade `.3s`.
- **Componenti (dall'alto)**:
  - **Handle**: barra grigia 36×4, radius 2, `#D5D8D6`, centrata.
  - **Header**: titolo "Nuovo promemoria" 20px w600 + bottone **X** tondo 36px (sfondo `#F0F2F1`, icona `close`).
  - **Box coordinate (read-only)**: sfondo `#E0F2F1`, radius 10, icona `place` teal filled, label "POSIZIONE DAL PIN" 11px teal + coordinate 14px w500, icona `lock` grigia a destra. Le coordinate arrivano automaticamente dal pin.
  - **Campo Titolo** (obbligatorio): stile Material filled — sfondo `#F0F2F1`, radius `8px 8px 0 0`, **underline teal 2px** (`#00897B`), label "Titolo *" teal, input 16px placeholder "Es. Comprare il latte".
  - **Campo Descrizione** (opzionale): stesso stile, underline `#C4C9C7`, textarea 2 righe, label grigia.
  - **Slider raggio**: header con icona `adjust` + "Raggio di attivazione" e valore corrente teal a destra (es. "200 m" / "1 km"). `input range` min 50, max 1000, step 50, default **200**, `accent-color:#00897B`. Sotto: estremi "50 m" / "1 km".
  - **Bottone Salva**: full-width, teal, radius 12, icona `check` + "Salva promemoria", w600 bianco, ombra teal. **Disabilitato** (`#BFC7C4`, cursor not-allowed) finché il titolo è vuoto.

### 3. Lista promemoria — `ReminderList.dc.html` + `ReminderCard.dc.html`
- **Purpose**: vedere e gestire tutti i promemoria.
- **Layout**: **AppBar teal** (`#00897B`) con status bar integrata, titolo "I miei Promemoria" 22px w600 bianco + sottotitolo conteggio ("3 luoghi salvati") + icona `tune` a destra. Sotto: lista scrollabile con padding 16px, gap 12px, label sezione "ATTIVI". Bottom navigation identica alla schermata 1 (voce "Promemoria" attiva).
- **Card promemoria** (`ReminderCard`): bianca, radius 12, ombra leggera, padding 16, gap 14. Contiene:
  - Icona pin in cerchio 44px sfondo `#E0F2F1`, `location_on` filled teal.
  - Titolo 16px w600 `#212121` (ellipsis) + sottotitolo "Raggio {n} m" 13px `#757575`.
  - **Switch Material** a destra: track 52×32 radius 16. Attivo: teal pieno, thumb bianco 22px a destra. Inattivo: track `#E0E4E2` bordo `#9AA3A0`, thumb grigio 16px a sinistra. Transizioni `.2s`.
  - **Gesture swipe**: drag orizzontale (pointer events), clamp ±96px.
    - Swipe **left** oltre −54px → rivela azione **Elimina** (sfondo rosso `#E5484D`, icona `delete` + "Elimina"). In produzione: mostrare conferma prima di eliminare.
    - Swipe **right** oltre +54px → rivela azione **Modifica** (sfondo teal, icona `edit` + "Modifica") → apre il sheet in modalità modifica.
    - Rilascio sotto soglia → torna a 0 (transition `.28s cubic-bezier(.2,.8,.2,1)`).
- **Stato vuoto**: centrato — cerchio 120px `#E0F2F1` con icona `wrong_location` 60px `#4DB6AC`; titolo "Nessun promemoria ancora" 17px w600; testo "Torna sulla mappa e tieni premuto per aggiungerne uno!" 14px `#757575`; bottone teal pill "Vai alla mappa" (icona `map`).

### 4. Onboarding — Coach mark (3 step) — `Onboarding.dc.html`
- **Purpose**: tutorial al primo avvio, sovrapposto alla mappa.
- **Layout**: overlay scuro a tutto schermo ottenuto con `box-shadow: 0 0 0 9999px rgba(0,0,0,0.66)` su un elemento trasparente posizionato = **spotlight** sull'area evidenziata. Bordo/alone teal pulsante attorno (`@keyframes` ring, 1.8s) — colore `#4DB6AC`. Card bianca (radius 16, ombra `0 8px 28px rgba(0,0,0,0.32)`, padding 18) posizionata vicino all'elemento, con animazione di entrata `translateY(10px→0)` `.28s`.
- **Contenuto card**: icona tonda + "Suggerimento N di 3" teal; testo sintetico (max 2 righe) 16px w500; in basso: **dots indicatore** (attivo = pill 20px teal, inattivo = 8px `#D5D8D6`), link "Salta" grigio, bottone teal pill "Avanti →" (icona `arrow_forward`) / "Inizia ✓" all'ultimo step.
- **Step**:
  1. Evidenzia **area mappa** → "Tieni premuto sulla mappa per aggiungere un promemoria". Card in basso al centro.
  2. Evidenzia **FAB +** → "Oppure usa il + per aggiungere rapidamente". Card sopra il FAB.
  3. Evidenzia voce **Promemoria** nella bottom bar → "Qui trovi e gestisci tutti i tuoi promemoria". Card sopra la bottom bar.

---

## Interactions & Behavior
- **Navigazione tab**: bottom nav passa tra schermata Mappa e Lista (stato `screen: 'map' | 'list'`).
- **Creazione**: long-press mappa o FAB → sheet aperto con coordinate auto + raggio default 200. Salva → aggiunge alla lista (attivo di default), chiude lo sheet, naviga alla lista, mostra **toast** di conferma ("Promemoria salvato"). Snackbar scura, in basso, icona `check_circle` accent, auto-dismiss ~2.2s.
- **Modifica**: swipe-right o azione Modifica → sheet pre-compilato con i dati del reminder; Salva aggiorna in place.
- **Elimina**: swipe-left → azione Elimina → rimuove + toast "Promemoria eliminato". *In produzione aggiungere dialog di conferma.*
- **Toggle attivo/inattivo**: tap sullo switch della card cambia lo stato `active` senza navigare.
- **Onboarding**: "Avanti" avanza lo step; al 3° "Inizia" chiude l'overlay; "Salta" chiude subito.
- **Animazioni**: drop dei pin (stagger), pulse del marker utente (loop), slide-up dello sheet, ring pulsante dell'onboarding, slide-up del toast.

## State Management
Stato a livello app (vedi `Flow.dc.html` per la macchina a stati di riferimento):
- `screen`: 'map' | 'list'
- `reminders`: array di `{ id, title, desc, radius, active, coords }`
- `sheetOpen`: boolean; `editingId`: id in modifica o null
- `draft`: `{ title, desc, radius, coords }` (campi del sheet)
- `onboarding`: `{ active, step (0–2) }`
- `fabExtended`: boolean (variante FAB)
- `toast`: messaggio corrente o null
- Persistenza: in produzione salvare `reminders` + flag "onboarding visto" (es. SharedPreferences/local storage); registrare le geofence con l'API di sistema (Flutter: `geofence_service` o equivalente).

## Variante richiesta
**FAB esteso con etichetta "Aggiungi"** — vedi schermata "Stati e varianti" in `GeoReminder.dc.html` e prop `fabExtended` in `MapHome.dc.html`. Stessa logica del FAB tondo ma con label testuale; utile come scoperta dell'azione primaria, specie post-onboarding.

## Assets
- **Icone**: Material Symbols Outlined (`location_on`, `add`, `map`, `format_list_bulleted`, `search`, `person`, `my_location`, `place`, `lock`, `adjust`, `check`, `close`, `edit`, `delete`, `tune`, `wrong_location`, `swipe`, `pin_drop`, `touch_app`, `add_circle`, `arrow_forward`, `restart_alt`, `check_circle`, batteria/wifi/segnale per la status bar). In Flutter usare `Icons.*` o il pacchetto `material_symbols_icons`.
- **Mappa**: illustrazione SVG stilizzata di placeholder (`MapCanvas.dc.html`) → sostituire con il widget mappa reale in produzione.
- **Font**: Roboto (di sistema su Android; includere su iOS). Roboto Mono per i dati tecnici.
- Nessuna immagine bitmap richiesta.

## Files
- `GeoReminder.dc.html` — pagina riepilogo: design tokens, prototipo interattivo, 4 schermate affiancate, stati e varianti. **Inizia da qui.**
- `Flow.dc.html` — prototipo navigabile completo con la macchina a stati di riferimento.
- `MapHome.dc.html` — schermata 1 (mappa + FAB + bottom nav). Prop: `fabExtended`, `activeTab`.
- `CreateSheet.dc.html` — schermata 2 (bottom sheet creazione).
- `ReminderList.dc.html` — schermata 3 (lista + stato vuoto).
- `ReminderCard.dc.html` — card swipeabile con switch (usata dalla lista).
- `Onboarding.dc.html` — schermata 4 (coach mark 3 step). Prop: `step`.
- `MapCanvas.dc.html` — mappa stilizzata di placeholder.
- `support.js` — runtime dei prototipi (non portare in produzione).
