# C4 Level 1 — System Context

> Het systeem in zijn omgeving. Welke actoren en externe systemen interacteren ermee?

## Systeem

**AIpoweredMakers** — Platform dat makers ondersteunt met AI-gestuurde tools en workflows.

## Actoren

| Actor | Rol | Interactie |
|---|---|---|
| Maker | Eindgebruiker die AI-tools gebruikt | Gebruikt de web applicatie om te creëren en samenwerken |
| Admin | Beheert het platform | Configureert systeem, beheert gebruikers en content |

## Externe systemen

| Systeem | Doel | Protocol | Richting |
|---|---|---|---|
| [Auth provider] | Authenticatie | OAuth2/OIDC | Outbound |
| [Payment provider] | Betalingen | REST API | Outbound |
| [Email service] | Notificaties | SMTP/API | Outbound |

## Context Diagram

```
                    ┌─────────┐
                    │  Maker  │
                    └────┬────┘
                         │
                    ┌────▼────┐
                    │         │
  [Extern A] ◄────►│  AIPow  │◄────► [Extern B]
                    │  ered   │
                    │ Makers  │
                    └────┬────┘
                         │
                    ┌────▼────┐
                    │  Admin  │
                    └─────────┘
```

## Gerelateerde ADRs

- ADR-0001: Frontend tech stack keuze
