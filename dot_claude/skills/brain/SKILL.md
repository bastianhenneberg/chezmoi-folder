# AI Brain — Session-Workflow

Du MUSST diesen Workflow vollständig einhalten. Keine Ausnahmen.

Den Projekt-Slug findest du in der CLAUDE.md des aktuellen Projekts unter `## AI Brain`.

---

## Phase 1: Kontext & Planung

BEVOR du Code anfasst oder Änderungen machst:

1. **Kontext laden:**
   `mcp__ai-brain__get-context-tool(project: "<slug>")`

2. **Wissen prüfen** — Wurde das Problem schon gelöst?
   `mcp__ai-brain__search-memories-tool(query: "...", project: "all")`
   `mcp__ai-brain__search-wiki-tool(query: "...")`

3. **Aufgabe analysieren** — Verstehe was der User will. Stelle Rückfragen falls unklar.

4. **Tasks anlegen** — Zerlege die Aufgabe in Arbeitsschritte:
   `mcp__ai-brain__create-task-tool(project: "<slug>", title: "...", priority: "high|medium|low")`

5. **Plan vorstellen** — Präsentiere die Tasks und warte auf Bestätigung.
   **STOPP: Erst nach expliziter Freigabe weiterarbeiten!**

---

## Phase 2: Umsetzung (pro Task wiederholen)

6. **Timer starten** — BEVOR du am Task arbeitest:
   `mcp__ai-brain__start-timer-tool(project: "<slug>", description: "Task-Beschreibung")`

7. **Task umsetzen** — Code schreiben, Tests schreiben, Änderungen vornehmen.

8. **Timer stoppen, SOBALD die Arbeit fertig ist** — und zwar **bevor** du das Ergebnis
   vorstellst und auf Feedback wartest. Die Warte-/Feedback-Zeit ist keine Arbeitszeit und
   darf nicht mitlaufen (sonst blähen sich Einträge auf mehrere Stunden auf).

   Schließe **gezielt deinen eigenen** Timer — verlass dich **nicht** darauf, dass
   `complete-task` ihn automatisch stoppt:
   1. `mcp__ai-brain__list-time-entries-tool(project: "<slug>")` → deinen noch laufenden
      Eintrag per ID finden (der ohne `stopped_at`, den **du** gestartet hast).
   2. `mcp__ai-brain__update-time-entry-tool(id: <id>, stopped_at: "<jetzt>", notes: "Was erreicht wurde")`
      — trifft **nur** deinen Timer.

9. **Ergebnis vorstellen** — Zeige was du gemacht hast.
   **STOPP: Warte auf Feedback. Gehe NICHT eigenständig zum nächsten Task!**

10. **Feedback einarbeiten** — Sind Änderungen nötig: **neuen** Timer starten (Schritt 6),
    umsetzen, wieder gezielt stoppen (Schritt 8).

11. **Task abschließen:**
    `mcp__ai-brain__complete-task-tool(id: <task-id>)`

⛔ **Nie einen neuen Timer starten, solange dein eigener noch offen ist.** Erst deinen
schließen (Schritt 8), dann den nächsten starten — offener Timer + neuer Start = die
Überlappungen/Doppelzählungen, die ganze Tage auf 25 h+ aufblähen.

**Multi-User-Sicherheit** — AI Brain ist Multi-User, mehrere gleichzeitig laufende Timer
sind Normalzustand, KEIN Aufräum-Anlass:
- **NIE** `stop-timer-tool(project: "all")`; **kein** blinder `stop-timer` ohne klare eigene
  ID — träfe sonst den global zuletzt gestarteten (evtl. fremden) Timer.
- Meldet ein Tool „noch X Timer aktiv", sind das **fremde** Timer → in Ruhe lassen.
- Deshalb der gezielte Weg über `list-time-entries` + `update-time-entry(id, stopped_at)`
  in Schritt 8: er trifft **ausschließlich** deinen eigenen Eintrag.

Siehe Memory `feedback_timers_multiuser`.

Zurück zu Schritt 6 für den nächsten Task.

---

## Phase 3: Session-Abschluss

Nachdem alle Tasks erledigt sind:

12. **Session dokumentieren:**
    `mcp__ai-brain__add-memory-tool(project: "<slug>", type: "note", title: "Session YYYY-MM-DD — Kurztitel", content: "Zusammenfassung")`

---

## Dokumentation (laufend, bei Bedarf)

| Situation | Tool |
|-----------|------|
| Etwas Neues gelernt | `mcp__ai-brain__add-memory-tool(type: "learning", ...)` |
| Architektur-Entscheidung | `mcp__ai-brain__add-memory-tool(type: "decision", ...)` |
| Bug entdeckt | `mcp__ai-brain__create-bug-tool(...)` |
| Bug behoben | `mcp__ai-brain__update-bug-tool(id, status: "fixed", solution: "...")` |
| Projektübergreifend nützlich | `mcp__ai-brain__add-wiki-tool(...)` |
