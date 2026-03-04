# SplitFlow Development Progress

## Project Summary
SplitFlow — collaborative platform for music producers. Core wedge: split agreements.
Full spec: `splitflow_mvp_spec_v2.docx` in project root.

## Tech Stack
- **Backend:** Ruby on Rails 8.1.2 (Hotwire: Turbo + Stimulus)
- **Frontend:** Tailwind CSS v4.2 + DaisyUI 5.5 + Stimulus
- **Database:** PostgreSQL 16 (databases: splitflow_development, splitflow_test)
- **Storage:** Cloudflare R2 via ActiveStorage (to be configured)
- **Auth:** Devise + JWT (to be added Sprint 1)
- **Background Jobs:** Solid Queue (Rails 8 default; Sidekiq+Redis for production later)
- **Ruby:** 3.4.8 via rbenv
- **Node:** 24.x (for DaisyUI npm package)
- **Deployment:** Docker Compose (Sprint 8)

## Sprint Plan (from spec)
| Sprint | Focus | Status |
|--------|-------|--------|
| 1 (2 wks) | Foundation: Devise auth, profiles, DB schema, R2 config | IN PROGRESS |
| 2 (2 wks) | Projects: CRUD, invitations, collaborator management, access control | NOT STARTED |
| 3 (2 wks) | Files: ActiveStorage uploads to R2, versioning, labeling, ZIP download | NOT STARTED |
| 4 (2 wks) | Splits (Core): proposal, approval flow, locking, PDF export | NOT STARTED |
| 5 (1 wk)  | Verification: public verification links, shareable agreement pages | NOT STARTED |
| 6 (1 wk)  | Communication: project threads, file comments, activity feed | NOT STARTED |
| 7 (1 wk)  | Polish: UI, error handling, email notifications, testing | NOT STARTED |
| 8 (1 wk)  | Launch Prep: Docker Compose prod, Nginx+SSL, CI/CD, monitoring | NOT STARTED |

## Key Data Models
- User: email, name, role, skills[], bio, avatar, portfolio_urls
- Project: title, description, genre, bpm, visibility, status → belongs_to owner
- Collaboration: user_id, project_id, role, status (pending/accepted/declined)
- ProjectFile: name, label, version, upload_timestamp → has_one_attached :file
- SplitAgreement: project_id, status (draft/pending/locked), locked_at
- SplitEntry: agreement_id, user_id, percentage, approved_at
- Comment: body, commentable_type/id (polymorphic: project or file)

## Completed Steps
1. Created CLAUDE.md with project instructions (no co-authored-by in commits)
2. Initialized fresh git repo (separate from parent asf-frontend repo)
3. Created .gitignore (Rails, env files, IDE, Claude local settings, docx)
4. Created this progress document
5. Installed rbenv + Ruby 3.4.8
6. Installed Rails 8.1.2 and generated the app (PostgreSQL, Tailwind CSS, Hotwire)
7. Created PostgreSQL databases (splitflow_development, splitflow_test)
8. Added DaisyUI 5.5 via npm — confirmed working with `@plugin "daisyui"` in Tailwind
9. Verified Rails boots and Tailwind builds with DaisyUI loaded

## Current Step
Sprint 1 foundation continues — next: Devise auth setup, User model, profiles

## Important Decisions
- Claude Code must NOT add "Co-Authored-By" to commits
- .claude/settings.local.json is gitignored
- .docx spec file is gitignored (not source code)
- Using Node.js approach for DaisyUI (npm install, @plugin directive)
- Rails 8 defaults: Solid Queue/Cache/Cable instead of Sidekiq for dev (Sidekiq for prod later)
- Propshaft for asset pipeline (Rails 8 default)
- importmap-rails for JS dependencies (no Webpack/esbuild)
