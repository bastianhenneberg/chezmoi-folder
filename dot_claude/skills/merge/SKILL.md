---
name: merge
description: Feature-Branch mergen, dokumentieren und aufräumen
---

# /merge - Branch Merge Routine

Wenn dieser Skill aufgerufen wird, führe folgende Schritte aus:

## 1. Session dokumentieren

Die Session-Dokumentation läuft ausschließlich über **AI Brain** (siehe `/dokumentation`).
Lege **keine** lokalen Session-Memory-Dateien an (`.claude/session-memory/` wird nicht mehr genutzt).

## 2. Aufgaben checken

- Offene Aufgaben (AI-Brain-Tasks) durchgehen
- Erledigte Tasks als erledigt markieren (`complete-task-tool`)
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
