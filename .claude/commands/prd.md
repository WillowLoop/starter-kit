---
description: Complete PRD workflow — interview, draft, review, finalize. Builds a requirements document through conversational interview, 3-agent review loop, and approval process.
---

# PRD Workflow — Conversational Interview → Draft → Review → Approve

Use the slash command `/prd` to start the complete workflow. This command orchestrates a 4-phase process:

1. **Interview (7 gerichte vragen)** — Verzamel context via AskUserQuestion
2. **Draft PRD** — Vul template in op basis van antwoorden
3. **Review Loop (max 3 iteraties)** — 3 agents reviewen parallel (product, technical, risk)
4. **Finalize** — Approve en opslaan

---

## Phase 1: PRD Interview (7 Vragen)

Start de interview met AskUserQuestion. **Elke vraag apart, één per keer.**

### Vraag 1: Probleem & Context
**Text**: "Welk probleem lossen we op? Voor wie? Waarom nu?"

**Challenge regel**: Als het antwoord vaag is ("een AI tool", "verbeteren user experience"), vraag expliciet door:
- "Welk specifiek probleem ervaren [persona] nu?"
- "Wat is het impact op [persona] als dit niet opgelost wordt?"
- "Waarom is dit nu urgent?"

### Vraag 2: Visie & Doelen
**Text**: "Wat is succes voor dit project? Geef 2-3 concrete, meetbare doelen."

**Challenge**: Als doelen niet SMART zijn:
- "Hoe meet je 'betere user experience'?"
- "Wat is de target waarde en timeframe?"

### Vraag 3: Doelgroep
**Text**: "Wie zijn de gebruikers? Definieer 1-3 personas: rol, doel, pijnpunt."

**Challenge**: Als te vaag:
- "Welk specifiek pijnpunt heeft [persona]?"
- "Hoe zou je weten dat dit pijnpunt opgelost is?"

### Vraag 4: Features (MVP)
**Text**: "Welke features moeten in deze MVP? Markeer prioriteit per feature: Must/Should/Could/Won't."

**Challenge**: Te veel Must-features (meer dan 5-6):
- "Wat is het absolute minimale om [kernprobleem] op te lossen?"
- "Kun je 1-2 features naar Should of Could verplaatsen?"

### Vraag 5: Scope Grenzen
**Text**: "Wat valt NIET in scope voor deze MVP? Waarom?"

**Challenge**: Als out-of-scope items crucaal voelen:
- "Kun je deze feature echt uitstellen, of is het fundamenteel nodig?"

### Vraag 6: Data & Integraties
**Text**: "Welke data, APIs, of externe services zijn nodig? Waar komt data vandaan?"

**Challenge**: Als onduidelijk:
- "Welke API/tool hebt je in gedachten?"
- "Hoe ziet de data flow eruit?"

### Vraag 7: Risico's & Open Issues
**Text**: "Wat weet je nog niet? Welke aannames maak je? Welke externe afhankelijkheden?"

**Challenge**: Als te vaag:
- "Welke specifieke open vragen hebben prioriteit?"
- "Welke aannames zouden kritiek kunnen zijn?"

---

## Phase 2: Draft PRD

Nadat alle 7 vragen zijn beantwoord:

1. **Bepaal het PRD-nummer** (NNNN): Tel bestaande bestanden in `docs/planning/prd/` om het volgende nummer te bepalen.

2. **Vul het template** (`docs/planning/prd/_template.md`) in:
   - Probleem: Samenvatting van vraag 1
   - Doelen & Success Metrics: Uit vraag 2 (zorg voor SMART metrics)
   - Doelgroep: Uit vraag 3 (tabla format: Persona | Doel | Pijnpunt)
   - Features & Requirements: Uit vraag 4 (tabla format: Feature | Prioriteit | Beschrijving)
   - User Stories: Maak 1-2 per Must/Should feature (Happy path + error scenario voor Must)
   - Scope (In/Out): Uit vraag 5
   - Open Issues: Uit vraag 7
   - Beslissingen: Voeg toe als relevant

3. **Schrijf naar bestand**: `docs/planning/prd/NNNN-korte-naam.md`
   - Status: `draft`
   - Eigenaar: `(nog te bepalen)`
   - Date: Vandaag

4. **Toon de draft** aan gebruiker. Vraag: "Klopt dit? Wijzigingen voordat we reviewers activeren?"

---

## Phase 3: Review Loop (Max 3 Iteraties)

Nadat gebruiker de draft goedkeurt (of geen wijzigingen wil):

### Spawn 3 Agents in Parallel

Gebruik Task tool om 3 agents parallel te spawnen (elk subagent_type: "general-purpose"):

| Agent | Prompt | Model |
|-------|--------|-------|
| **PRD Product Reviewer** | Bestand: `.claude/agents/prd-product-reviewer.md` system prompt + PRD tekst | sonnet |
| **PRD Technical Reviewer** | Bestand: `.claude/agents/prd-technical-reviewer.md` system prompt + PRD tekst | sonnet |
| **PRD Risk Analyst** | Bestand: `.claude/agents/prd-risk-analyst.md` system prompt + PRD tekst | sonnet |

**Agent prompt template**:
```
[System prompt uit agent YAML]

## PRD ter Review

[PRD tekst]

[Agent zal antwoorden in het gedefinieerde format met verdict]
```

### Verdictlogica

Na alle 3 agents:

| Scenario | Actie |
|----------|-------|
| Alle 3 = APPROVED | → Phase 4 (Finalize) |
| 1+ = APPROVED WITH CHANGES | → Adresseer kritieke issues → Herhaal review loop (iteratie +1) |
| 1+ = NEEDS REVISION | → Herschrijf PRD op basis van feedback → Herhaal review loop (iteratie +1) |
| Na 3 iteraties geen full APPROVED | → Vraag gebruiker: "Wat willen we doen? Doorgaan, sealen op current state, of herbeginnen?" |

### Afhandeling per Iteratie

1. **Toon verdicts** aan gebruiker
2. **Highlight kritieke issues** (MOET OPLOSSEN)
3. **Vraag**: "Zullen we dit adresseren?" → Gebruiker geeft feedback
4. **Update PRD** op basis van feedback
5. **Loop terug** naar agent spawning (als niet approved)

---

## Phase 4: Finalize

Nadat alle 3 agents APPROVED geven:

1. **Update PRD bestand**:
   - Status: `draft` → `approved`
   - Eigenaar: Invoeren (gebruiker bepalen)
   - Voeg toe: kort notatje van review iteraties

2. **Toon samenvatting**:
   ```
   ✅ PRD Approved!

   - Titel: [PRD name]
   - Bestand: docs/planning/prd/NNNN-naam.md
   - Iteraties: [N]
   - Key verbeteringen: [bullet points]

   Review verdicts:
   - Product: ✅ APPROVED
   - Technical: ✅ APPROVED
   - Risk: ✅ APPROVED
   ```

3. **Vraag next step**: "Wat willen we nu maken?
   - Epic (roadmap) voor deze PRD?
   - Design Doc (technisch ontwerp)?
   - Implementatieplan (developers planning)?
   - Niets, klaar voor nu?"

---

## Implementatiedetails

### Interview-logica (Challenge Rule)

Pseudo-code voor vraag-handler:

```
while (isVague(answer)) {
  showChallenge(context)
  answer = askFollowUp()
}
recordAnswer(question, answer)
```

Vage antwoorden zijn: generiek ("beter", "sneller"), niet-specifiek ("tool", "feature"), onmeetbaar ("users gaan houden van").

### PRD-nummering

```python
existing_prds = glob("docs/planning/prd/NNNN-*.md")
next_number = max(extract_number(prd) for prd in existing_prds) + 1
filename = f"docs/planning/prd/{next_number:04d}-{slug(title)}.md"
```

### Agent Spawning

```python
# Parallel spawn
product_review = Task(
  subagent_type="general-purpose",
  model="sonnet",
  prompt=combine(prd_product_reviewer_system, prd_content)
)
technical_review = Task(...)
risk_review = Task(...)

# Collect results
results = [product_review.result, technical_review.result, risk_review.result]
verdicts = [extract_verdict(r) for r in results]
```

### Verdict Determination

```python
if all(v == "APPROVED" for v in verdicts):
  return "APPROVED"
elif any(v == "NEEDS REVISION" for v in verdicts):
  return "NEEDS_REVISION"  # → Herschrijf
elif any(v == "APPROVED WITH CHANGES" for v in verdicts):
  return "APPROVED_WITH_CHANGES"  # → Fix, dan recheck
```

---

## Toetsstappen

Na implementatie:

1. In een project: `/prd` typen
2. Interview starten → vraag 1 verschijnt
3. 7 vragen doorlopen → antwoorden opslaan
4. Draft PRD verschijnt → preview tonen → goedkeuring
5. Review starten → 3 agents spawn parallel
6. Verdicts verschijnen → iteratie logic
7. APPROVED status checken → PRD bestand updateren
8. Samenvatting tonen → next steps aanbieden

---

## Notes

- **Taal**: Alle interview-vragen, agent prompts, en output zijn Nederlands
- **Non-blocking**: Gebruiker mag interview afbreken en later hervatten (opslaan van progress)
- **Transparantie**: PRD-bestand is altijd zichtbaar; geen "achter de schermen" decisions
- **Max 3 iteraties**: Na 3 review-loops zonder full approval, vraag gebruiker voor richting
