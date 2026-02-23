# ADR-NNNN: [Titel]

- **Status**: proposed | accepted | superseded | deprecated
- **C4 Level**: L1-Context | L2-Container | L3-Component | L4-Code
- **Scope**: [welke container/component dit raakt]
- **Date**: YYYY-MM-DD

## Context

[Welk probleem lossen we op? Welke krachten spelen mee?]

## Decision

[De gekozen aanpak. Committed.]

## Reasoning Chain

[Multi-step redenering, minimaal 2 stappen]
- [Premisse] → [Implicatie] → [Conclusie]

## Alternatives Considered

| Alternatief | Waarom afgewezen |
|---|---|
| [aanpak A] | [concrete reden] |
| [aanpak B] | [concrete reden] |

## Consequences

- [Wat wordt makkelijker]
- [Wat wordt moeilijker]
- [Welke constraints dit creëert voor toekomstige beslissingen]

---

## Wanneer een ADR aanmaken

- Beslissing raakt meer dan één directory (cross-cutting of system-wide)
- Beslissing beperkt toekomstige architectuurkeuzes
- Beslissing was niet-obvious en de redenering moet bewaard worden

Lokale beslissingen (single module) kunnen in de `CLAUDE.md` van die directory.

## Naamgeving

```
docs/adr/NNNN-korte-kebab-titel.md
```

Nummering begint bij `0001`, oplopend.

## C4-koppeling

Het **C4 Level** veld koppelt elke ADR aan het juiste architectuurniveau:

| C4 Level | Voorbeeld beslissing |
|---|---|
| L1-Context | "Systeem X communiceert via REST met externe partij Y" |
| L2-Container | "Frontend draait op Next.js, backend op FastAPI" |
| L3-Component | "Auth module gebruikt bcrypt voor password hashing" |
| L4-Code | "Alle API clients gebruiken een shared base class" |

## Lifecycle

```
Proposed → Accepted → [leeft als referentie] → Deprecated/Superseded
```

Een ADR wordt nooit verwijderd — markeer als deprecated/superseded om redeneerhistorie te bewaren.
