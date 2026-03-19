---
name: merge
description: Feature-Branch mergen, dokumentieren und aufräumen
---

# /merge - Branch Merge Routine

Wenn dieser Skill aufgerufen wird, führe folgende Schritte aus:

## 1. Session Memory dokumentieren

Falls `.claude/session-memory/` existiert:
- Datei für heute erstellen/aktualisieren: `.claude/session-memory/YYYY-MM-DD.md`
- Alle Änderungen der Session dokumentieren
- Format siehe bestehende Session-Memory-Dateien

Falls kein Session Memory existiert, erstelle es nach diesem Format:

```markdown
# Session YYYY-MM-DD

## Zusammenfassung

Kurze Beschreibung was in dieser Session gemacht wurde.

## Änderungen

### Bereich 1
- Änderung 1
- Änderung 2

## Wichtige Erkenntnisse

- Erkenntnis 1
- Erkenntnis 2
```

## 2. Aufgaben checken

- Offene Aufgaben in Session Memory oder TODO-Dateien durchgehen
- Erledigte Aufgaben als erledigt markieren (`[x]`)
- Verifizieren dass alle geplanten Änderungen umgesetzt wurden

## 3. Uncommitted Changes committen

Falls uncommitted Changes vorhanden:
- `git add -A`
- Commit mit aussagekräftiger Message erstellen
- Am Ende hinzufügen: `Co-Authored-By: Claude <noreply@anthropic.com>`

## 4. Branch mergen

- Aktuellen Branch Namen ermitteln
- Auf main/master wechseln: `git checkout main` oder `git checkout master`
- Pull um aktuell zu sein: `git pull`
- Feature-Branch mergen: `git merge <feature-branch>`
- Bei Konflikten: User informieren und abbrechen

## 5. Feature-Branch löschen

- Lokalen Feature-Branch löschen: `git branch -d <feature-branch>`
- Remote Feature-Branch löschen: `git push origin --delete <feature-branch>`

---

**Hinweis:** Dieser Skill pusht NICHT. Nach dem Merge kannst du mit `/fertig` commiten und pushen falls nötig.
