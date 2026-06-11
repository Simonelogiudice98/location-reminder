# SPECIFICA TECNICA — GeoReminder App

---

## 🧠 Contesto progetto

App mobile cross-platform (Android + iOS) che permette agli utenti di creare promemoria basati sulla posizione geografica.

**Esempio d'uso:**
- L'utente seleziona un punto sulla mappa (es. supermercato)
- Inserisce un promemoria (es. "compra latte")
- Quando l'utente entra nelle vicinanze del punto → riceve una notifica

---

## 🎯 Obiettivo MVP

Creare una versione funzionante dell'app con:
- Mappa interattiva
- Creazione promemoria geolocalizzati
- Storage locale
- Notifiche base
- *(Fase 2)* Geofencing in background

---

## 🏗️ Stack tecnologico

| Area | Scelta |
|---|---|
| Framework | Flutter 3.x (latest stable) |
| Mappe | `google_maps_flutter` |
| State management | **Riverpod** |
| Storage locale | **Hive** |
| Notifiche | `flutter_local_notifications` |
| Geofencing (Fase 2) | `flutter_background_geofencing` |
| Backend (opzionale) | Firebase (Auth + Firestore + FCM) |

---

## 📱 Funzionalità app

### 1. Mappa principale
- Mostrare Google Maps centrata sulla posizione utente
- Long press sulla mappa per creare un pin
- Ogni pin rappresenta un promemoria salvato

### 2. Creazione promemoria
Quando si crea un pin, l'utente inserisce:
- Titolo (string, obbligatorio)
- Descrizione (string, opzionale)
- Raggio (default 200m, modificabile)
- Posizione (lat/lng — auto dal pin)
- Timestamp creazione (auto)

### 3. Lista promemoria
- Lista di tutti i reminder salvati
- Azioni disponibili: modifica, elimina, attiva/disattiva

### 4. Notifiche — MVP (Versione 1)
**Trigger:** solo quando l'utente apre l'app

**Logica:** se la posizione attuale è entro il raggio di un reminder attivo → mostra notifica locale

> Serve per testare la UX senza la complessità del background

### 5. Geofencing — Fase 2
**Requisiti:**
- Monitoraggio enter/exit geofence
- Notifiche automatiche anche con app chiusa

**Vincoli iOS:**
- Usare region monitoring (non polling GPS continuo)
- Massimo ~20 geofence attivi contemporaneamente
- Richiesta permesso "Always location"

**Vincoli Android:**
- Usare `GeofencingClient`
- Foreground service solo se necessario

### 6. Gestione limiti geofence
- Salvare tutti i reminder localmente
- Attivare solo i geofence più vicini (max 20)
- Aggiornare dinamicamente i geofence attivi quando l'utente si muove

### 7. Permessi
- Location When In Use (MVP)
- Location Always (Fase 2 — richiedere solo dopo onboarding)
- Notifiche locali

---

## 🧩 Architettura

### Struttura cartelle

```
/geo reminder                          ← root progetto
  /lib
    /core
      location_service.dart
      notification_service.dart
      geofence_service.dart
    /features
      /map
      /reminders
      /settings
    /data
      reminder_model.dart
      reminder_repository.dart
    main.dart
  /design_handoff_georeminder          ← asset di design (screenshot, README design)
  pubspec.yaml
  .gitignore
  README.md
```

### Modello dati

```dart
class Reminder {
  String id;
  String title;
  String? description;
  double latitude;
  double longitude;
  double radius;       // in metri, default 200
  DateTime createdAt;
  bool isActive;
}
```

---

## 🎨 Design system

### Palette colori
| Ruolo | Colore | Hex |
|---|---|---|
| Primary | Teal/Azzurro petrolio | `#00897B` |
| Primary dark | Teal scuro | `#00695C` |
| Accent | Teal chiaro | `#4DB6AC` |
| Background | Bianco | `#FFFFFF` |
| Surface | Grigio chiarissimo | `#F5F5F5` |
| Text primary | Quasi nero | `#212121` |
| Text secondary | Grigio | `#757575` |

### Tipografia
- Font: **Roboto** (default Material)
- Titoli: `FontWeight.w600`
- Body: `FontWeight.w400`

### Stile generale
- Material Design 3
- Bottom navigation bar (2 voci: Mappa | Promemoria)
- FAB teal in basso a destra per aggiungere reminder
- Mappa fullscreen con elementi UI sovrapposti
- Card arrotondate (`borderRadius: 12`) nella lista
- Icone Material outline

---

## 🖼️ Wireframe schermate principali

### Schermata 1 — Mappa principale (fullscreen)

```
┌─────────────────────────────┐
│                             │  ← nessuna AppBar
│       [ GOOGLE MAP ]        │
│         FULLSCREEN          │
│   📌         📌             │  ← Pin dei reminder
│                             │
│         📌                  │
│                      [  +  ]│  ← FAB teal in basso a destra
│                             │
├──────────────┬──────────────┤
│   🗺️  Mappa  │ 📋 Promemoria│  ← Bottom navigation bar
└──────────────┴──────────────┘
```

### Schermata 2 — Creazione reminder (bottom sheet)

```
┌─────────────────────────────┐
│  Nuovo Reminder          ✕  │
├─────────────────────────────┤
│  Titolo *                   │
│  ┌───────────────────────┐  │
│  │ es. Compra latte      │  │
│  └───────────────────────┘  │
│                             │
│  Descrizione                │
│  ┌───────────────────────┐  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  Raggio: 200m  [────●────]  │  ← Slider colore teal
│                             │
│  Posizione: 43.8°N, 7.5°E   │  ← Auto dal pin
│                             │
│  ┌─────────────────────┐    │
│  │      SALVA          │    │  ← Bottone teal
│  └─────────────────────┘    │
└─────────────────────────────┘
```

### Schermata 3 — Lista promemoria

```
┌─────────────────────────────┐
│  I miei Promemoria          │  ← AppBar teal
├─────────────────────────────┤
│  ┌───────────────────────┐  │
│  │ 📌 Compra latte   🟢  │  │  ← toggle attivo/inattivo
│  │ Supermercato · 200m   │  │
│  │                  ✏️ 🗑️ │  │
│  └───────────────────────┘  │  ← Card bordi arrotondati
│  ┌───────────────────────┐  │
│  │ 📌 Farmacia       ⚪  │  │
│  │ Via Roma · 100m       │  │
│  │                  ✏️ 🗑️ │  │
│  └───────────────────────┘  │
│                             │
├──────────────┬──────────────┤
│   🗺️  Mappa  │ 📋 Promemoria│  ← Bottom navigation bar
└──────────────┴──────────────┘
```

### Onboarding — Coach mark (3 step, solo primo avvio)

```
Step 1:
┌─────────────────────────────┐
│   [overlay scuro]           │
│                             │
│         📌                  │  ← elemento evidenziato
│   ┌─────────────────────┐   │
│   │ Tieni premuto sulla │   │
│   │ mappa per aggiungere│   │
│   │ un promemoria       │   │
│   └─────────────────────┘   │
│              [ Avanti →  ]  │
│                    [ Salta ]│
└─────────────────────────────┘

Step 2: evidenzia FAB "+"
→ "Oppure usa il + per aggiungere rapidamente"

Step 3: evidenzia bottom bar "Promemoria"
→ "Qui trovi e gestisci tutti i tuoi promemoria"
```

---

## 🔄 Flow utente

```
Apre app → Mappa → Long press → Form reminder → Salva
                                                  ↓
                                         Geofence registrato
                                                  ↓
                                    Entra nell'area → Notifica
```

---

## 🔐 Note di sicurezza

### API Key Google Maps ⚠️ priorità alta
- **Non committare mai la key in chiaro** su Git
- Usare variabili d'ambiente o un file `.env` escluso da `.gitignore`
- Restringere la key su Google Cloud Console:
  - Solo Maps SDK for Android / iOS
  - Solo il tuo bundle ID / package name

### Dati di posizione
- I reminder salvati rivelano abitudini e luoghi frequentati
- Con Hive i dati sono in chiaro sul device — accettabile per MVP
- Non inviare mai lat/lng in chiaro in log o analytics
- Se aggiungi Firebase sync, considera la cifratura dei campi sensibili

### Permesso "Always On" (Fase 2)
- È il permesso più invasivo — Apple e Google lo scrutinano nelle review
- **Non richiederlo all'avvio a freddo**
- Richiederlo solo dopo che l'utente ha capito il valore dell'app
- Spiegare esplicitamente il motivo nell'alert di richiesta

### Firebase Security Rules (Fase 2)
- Le regole Firestore di default sono **aperte** — configurarle prima del rilascio
- Ogni utente deve poter accedere solo ai propri reminder

---

## ⚠️ Regole importanti

**iOS:**
- Non usare polling GPS continuo
- Usare region monitoring
- Sempre battery-aware

**Android:**
- Evitare location loop continuo
- Usare foreground service solo se necessario

**Performance:**
- Massimo 20 geofence attivi per device
- Usare dynamic geofencing

**Codice:**
- Separare logic layer da UI
- Mantenere codice modulare e testabile
- Evitare dipendenze inutili
- Preferire soluzioni native OS

---

## 💎 Roadmap

| Fase | Contenuto | Timing stimato |
|---|---|---|
| Fase 1 (MVP) | Mappa, pin, salva reminder, lista, notifica all'apertura | 1 settimana |
| Fase 2 | Geofencing background, notifiche automatiche | 2–4 settimane |
| Fase 3 | Firebase sync, login, premium limits, multilingua (`flutter_localizations`) | TBD |

---

## ✅ Task Fase 1 — Dettaglio

La Fase 1 è suddivisa in task sequenziali. Ogni task va implementato, spiegato e compreso prima di passare al successivo.

> **Istruzione per Claude Code:** implementa un task alla volta. Dopo ogni task, spiega cosa hai fatto, quali scelte hai preso e perché, e cosa fa ogni file creato o modificato.

---

### ~~T1 — Setup progetto~~ ✅ COMPLETATO
- ~~Esegui `flutter create .` con package name `com.tuonome.georeminder`~~
- ~~Aggiungi le dipendenze nel `pubspec.yaml`~~
- ~~Crea la struttura cartelle definita in `/lib`~~
- ~~Verifica che il progetto compili senza errori~~

---

### ~~T2 — Modello dati + Hive~~ ✅ COMPLETATO
- ~~Crea la classe `Reminder` con tutti i campi definiti~~
- ~~Configura Hive: adapter, box, init in `main.dart`~~
- ~~Crea `ReminderRepository` con metodi CRUD base~~

---

### ~~T3 — Mappa~~ ✅ COMPLETATO
- ~~Integra Google Maps nella schermata principale~~
- ~~Centra la mappa sulla posizione attuale dell'utente~~
- ~~Gestisci il permesso `Location When In Use`~~
- ~~Mostra i pin dei reminder salvati sulla mappa~~

---

### T-GIT — Setup repository GitHub ✅ DA FARE PRIMA DI T4

> **Questo task va eseguito manualmente da te, non da Claude Code.**

1. Vai su [github.com](https://github.com) e crea una nuova repository chiamata **location-reminder**
   - Visibilità: Public o Private a tua scelta
   - NON inizializzare con README (il progetto esiste già)

2. Nella root del progetto, verifica che `.gitignore` contenga:
   ```
   # API keys
   .env
   **/local.properties
   **/google-services.json
   **/GoogleService-Info.plist

   # Design assets (opzionale, se non vuoi pushare i file di design)
   # /design_handoff_georeminder
   ```

3. Inizializza Git e fai il primo push:
   ```bash
   git init
   git add .
   git commit -m "feat: initial project setup - T1/T2/T3 complete"
   git branch -M main
   git remote add origin https://github.com/TUO_USERNAME/location-reminder.git
   git push -u origin main
   ```

4. Verifica su GitHub che tutti i file siano presenti e che `.env` / `google-services.json` NON siano stati pushati

---

### T4 — Creazione reminder
- Prima di implementare, consulta gli screenshot in `/design_handoff_georeminder` come riferimento visivo
- Implementa long press sulla mappa per posizionare un pin temporaneo
- Apri un bottom sheet con il form di creazione (vedi schermata 2 nel design handoff)
- Campi: titolo (obbligatorio), descrizione (opzionale), slider raggio (default 200m, colore teal `#00897B`)
- Posizione pre-compilata dal punto del long press
- Bottone "Salva" full-width colore teal, handle in cima al bottom sheet

---

### T5 — Storage reminder
- Collega il form di T4 al repository di T2
- Al salvataggio: persisti su Hive e aggiungi il pin sulla mappa
- Carica i reminder salvati all'avvio dell'app
- Gestisci lo state con Riverpod (`RemindersNotifier`)

---

### T6 — Lista reminder
- Crea la schermata lista con tutti i reminder salvati
- Per ogni reminder: mostra titolo, indirizzo/coordinate, raggio
- Implementa toggle attivo/inattivo
- Implementa elimina con conferma
- Implementa navigazione verso schermata modifica

---

### T7 — Notifiche MVP
- Configura `flutter_local_notifications`
- All'apertura dell'app: recupera posizione attuale
- Per ogni reminder attivo: calcola distanza dalla posizione attuale
- Se distanza ≤ raggio → mostra notifica locale
- Gestisci correttamente i permessi notifica su iOS e Android

---

## 🚀 Istruzioni per Claude Code

Prima di iniziare:
1. Leggi tutta questa specifica
2. Consulta gli screenshot in `/design_handoff_georeminder` come riferimento visivo per l'UI
3. Chiedi conferma prima di procedere con ogni task
4. Implementa un task alla volta — non anticipare il successivo
5. Dopo ogni task: spiega cosa hai fatto e perché
6. Rispetta il design system: colore primary `#00897B`, Material Design 3, Roboto
7. Segnala subito se una scelta tecnica ti sembra problematica
