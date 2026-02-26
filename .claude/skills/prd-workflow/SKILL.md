---
name: prd-workflow
description: Complete PRD creation workflow. Conversational interview (7 questions) → draft PRD → parallel 3-agent review (product, technical, risk) → approval. For product requirements at project start.
---

# PRD Workflow Skill

Bouw Product Requirements Documents (PRDs) door een conversationeel interview en 3-agent review process. Perfect voor projectstart of grote features.

## Wanneer deze skill gebruiken

**Triggers:**
- `/prd` — Start compleet PRD workflow
- "Laten we een PRD opzetten"
- "Welk probleem lossen we op?" (zeker weten dat we dit goed begrijpen)
- Een feature/project waarbij clarity op requirements ontbreekt

**NIET gebruiken voor:**
- Kleine features (direct epic of plan)
- Technische tasks (direct naar design doc of plan)
- Features die al duidelijk zijn

## Workflow Overzicht

```
Phase 1: Interview (7 vragen)
   ↓
Phase 2: Draft PRD (template vullen)
   ↓
Phase 3: Review Loop (3 agents parallel, max 3 iteraties)
   ↓
Phase 4: Finalize (approval + next steps)
```

## Phase 1: Interview (7 Vragen)

Claude stelt **één vraag per keer** via AskUserQuestion. Challenge regel: vage antwoorden doorprikken voordat volgende vraag.

| # | Vraag | Doel |
|---|-------|------|
| 1 | Welk probleem lossen we op? Voor wie? Waarom nu? | Probleem specifiek maken |
| 2 | Wat is succes? (2-3 concrete, meetbare doelen) | Doelen SMART maken |
| 3 | Wie zijn de gebruikers? (1-3 personas) | Personas helder definiëren |
| 4 | Welke features MVP? (Must/Should/Could/Won't) | Scope afbakenen |
| 5 | Wat valt NIET in scope? Waarom? | Out-of-scope soliditeit checken |
| 6 | Welke data, APIs, services? | Dependencies helderen |
| 7 | Wat weet je niet? Risico's? | Open issues & aannames |

**Challenge-regel bij vaagheid:**
- Probleem vaag? → "Welk specifiek pijnpunt?"
- Doelen niet-SMART? → "Hoe meet je succes?"
- Personas generiek? → "Welk concrete pijnpunt has [persona]?"
- Te veel Must-features? → "Wat is absolute minimum?"

## Phase 2: Draft PRD

Na interview:

1. **PRD-nummer bepalen** (NNNN): Tel bestaande bestanden in `docs/planning/prd/`
2. **Template vullen** met interview-antwoorden
3. **Schrijven naar** `docs/planning/prd/NNNN-korte-naam.md`
4. **Tonen** aan gebruiker → Goedkeuring vóór review

**PRD Structuur** (uit template):
- Probleem
- Doelen & Success Metrics
- Doelgroep (personas tabel)
- Features & Requirements (Must/Should/Could/Won't)
- User Stories (min 1 per Must/Should)
- Scope (In/Out)
- Open Issues
- Beslissingen (optioneel)

## Phase 3: Review Loop (Max 3 Iteraties)

3 agents reviewen **parallel** (niet sequentieel):

| Agent | Perspectief | Focus |
|-------|-------------|-------|
| **PRD Product Reviewer** | PM | Klantwaarde, MVP, metrics SMART, persona-feature fit |
| **PRD Technical Reviewer** | Architect | Haalbaarheid, data/APIs, complexity, AI-risico's |
| **PRD Risk Analyst** | Stakeholder | Aannames, blindspots, scope creep, dependencies |

**Verdictlogica:**

| Verdicts | Actie |
|----------|-------|
| Alle 3: APPROVED | → Phase 4 |
| 1+: APPROVED WITH CHANGES | → Fix kritieke issues → Review opnieuw |
| 1+: NEEDS REVISION | → Herschrijf PRD → Review opnieuw |
| Na 3 iteraties: geen APPROVED | → Vraag gebruiker richting |

**Feedback-afhandeling:**
- Toon verdicts
- Highlight kritieke issues
- Vraag: "Gaan we dit adresseren?"
- Update PRD
- Loop herhalen

## Phase 4: Finalize

Nadat all 3 agents APPROVED:

1. **Update PRD**:
   - Status: `draft` → `approved`
   - Eigenaar: Invoeren
   - Iteraties noteren

2. **Toon samenvatting** (titel, bestand, key verbeteringen)

3. **Next steps aanbieden**:
   - Epic (roadmap) aanmaken?
   - Design Doc (technisch)?
   - Implementatieplan?

## Kenmerkende Voordelen

✅ **Structured Interview**: 7 vragen zorgen dat niets gemist wordt
✅ **Challenge Mechanic**: Vage antwoorden worden niet geaccepteerd
✅ **Parallel Review**: 3 perspectiefen gelijktijdig = sneller
✅ **Transparent**: Draft is altijd zichtbaar
✅ **Iteratief**: Max 3 loops voordat gebruiker beslist
✅ **Dutch-native**: Alles in Nederlands

## Voorbeeld Output

```
# PRD: Gebruikersregistratie

- Status: approved
- Eigenaar: Product Owner
- Date: 2026-02-21

## Probleem
Nieuwe gebruikers kunnen zich niet registreren...

[Volledige PRD content]

---
Review Iteraties: 1
Key verbeteringen:
- Email verificatie moet hetzelfde dia als registration (was separate)
- 3 in plaats van 4 onboarding stappen (scope herleid)
- Out-of-scope: SSO → future epic
```

## Relatie tot Andere Documenten

| Doc | Doel | Na PRD? |
|-----|------|---------|
| **Epic** | Roadmap: wat & wanneer | Ja (optioneel) |
| **Design Doc** | Technisch ontwerp: hoe | Ja (als complex) |
| **Plan** | Implementatie stappen | Ja (developers) |

Een PRD kan meerdere epics/design docs voeden. Start altijd met PRD als clarity nodig is.

---

**Usage**: `/prd` in terminal of "start PRD workflow" in Claude Code.
