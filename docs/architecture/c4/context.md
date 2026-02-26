# C4 Level 1 — System Context

> Fill in during bootstrap (see docs/README.md step 4)

> The system in its environment. Which actors and external systems interact with it?

## System

**AIpoweredMakers** — Platform that supports makers with AI-powered tools and workflows.

## Actors

| Actor | Role | Interaction |
|---|---|---|
| Maker | End user who uses AI tools | Uses the web application to create and collaborate |
| Admin | Manages the platform | Configures system, manages users and content |

## External Systems

| System | Purpose | Protocol | Direction |
|---|---|---|---|
| [Auth provider] | Authentication | OAuth2/OIDC | Outbound |
| [Payment provider] | Payments | REST API | Outbound |
| [Email service] | Notifications | SMTP/API | Outbound |

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

## Related ADRs

- ADR-0001: Frontend tech stack choice
