# Acme (day job)

> Loaded only inside `~/work/acme`. Nothing from this file goes into `MAP.md` or another group.

## Role
Backend engineer on the payments platform team. Java 21, Spring Boot, Kafka, PostgreSQL.

## Rules
- Acme code, tickets and names stay in Acme systems and in this file.
- Every change goes through a reviewed pull request. `main` is protected.
- On call one week in six. Runbooks live in the Acme wiki, not here.

## Now
- Moving settlement jobs from cron to Kafka consumers. Every consumer gets an idempotency key before it goes live.
- Payment status API v2: the old endpoint stays until the mobile apps stop calling it.
