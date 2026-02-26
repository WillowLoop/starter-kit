<!-- EXAMPLE: Remove this file when cloning the starter-kit -->

# PRD: User Registration & Onboarding

- **Status**: approved
- **Owner**: Product Owner
- **Date**: 2026-01-15
- **Epics**: [Epic 001 — Registration](../roadmap/0001-gebruikersregistratie.md)

## Problem

New users cannot register and have no guided first experience. Without onboarding, users drop off before experiencing the core value of the product.

## Goals & Success Metrics

| Goal | Metric | Target |
|---|---|---|
| Users can create an account | Registration completion rate | > 80% |
| Users complete onboarding | Onboarding completion rate | > 60% |
| Reduce support tickets for setup | Support tickets "how do I start?" | -50% in Q2 |

## Target Audience

| Persona | Goal | Pain point |
|---|---|---|
| New user | Get started with the product quickly | Doesn't know where to begin |
| Returning user | Recover account after inactivity | Forgotten password, no reset flow |

## Features & Requirements

| Feature | Priority | Description |
|---|---|---|
| Email registration | Must | Create account with email and password |
| Email verification | Must | Confirmation link to validate email address |
| Onboarding wizard | Should | 3-step wizard: profile, preferences, first action |
| Social login (Google) | Could | OAuth2 login as alternative to email |
| Password reset | Must | Self-service password recovery via email |

## User Stories

| # | Persona | User Story | Feature |
|---|---|---|---|
| US-01 | New user | As a new user I want to create an account with my email address so that I get access to the product | Email registration |
| US-02 | New user | As a new user I want to receive a confirmation email so that my email address gets verified | Email verification |
| US-03 | New user | As a new user I want to see a clear error message for an invalid email address so that I know what to correct | Email registration |
| US-04 | New user | As a new user I want to go through an onboarding wizard so that I quickly experience the core value of the product | Onboarding wizard |
| US-05 | New user | As a new user I want to be able to skip the onboarding so that I can get started right away if I already know how it works | Onboarding wizard |
| US-06 | Returning user | As a returning user I want to reset my password via email so that I regain access to my account | Password reset |
| US-07 | Returning user | As a returning user I want to see a message when my reset link has expired so that I can request a new one | Password reset |
| US-08 | New user | As a new user I want to register with my Google account so that I don't have to remember a separate password | Social login (Google) |

## Scope

### In scope
- Registration via email/password
- Email verification flow
- Onboarding wizard (3 steps)
- Password reset flow

### Out of scope
- SSO / enterprise auth
- Multi-factor authentication
- User profile management (separate PRD)

## Open Issues

- Which email provider do we use? (SendGrid vs Resend)
- Should we apply rate limiting on the registration endpoint?

## Decisions

| Decision | Rationale | Date |
|---|---|---|
| Email verification required | Prevents spam accounts and validates reachability | 2026-01-10 |
| Onboarding max 3 steps | More steps significantly lowers completion rate | 2026-01-12 |
