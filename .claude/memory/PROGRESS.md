# SplitFlow Development Progress

## Project Summary
SplitFlow — collaborative platform for music producers. Core wedge: split agreements.
Full spec: `splitflow_mvp_spec_v2.docx` in project root.

## Tech Stack
- **Backend:** Ruby on Rails 8.1.2 (Hotwire: Turbo + Stimulus)
- **Frontend:** Tailwind CSS v4.2 + DaisyUI 5.5 + Stimulus
- **Database:** PostgreSQL 16 (databases: splitflow_development, splitflow_test)
- **Storage:** Cloudflare R2 via ActiveStorage (to be configured)
- **Auth:** Devise 5.0.2 (session-based, no JWT for MVP)
- **Background Jobs:** Solid Queue (Rails 8 default; Sidekiq+Redis for production later)
- **Ruby:** 3.4.8 via rbenv
- **Node:** 24.x (for DaisyUI npm package)
- **Deployment:** Docker Compose (Sprint 8)

## Sprint Plan (from spec)
| Sprint | Focus | Status |
|--------|-------|--------|
| 1 (2 wks) | Foundation: Devise auth, profiles, DB schema | COMPLETE |
| 2 (2 wks) | Projects: CRUD, invitations, collaborator management, access control | NOT STARTED |
| 3 (2 wks) | Files: ActiveStorage uploads to R2, versioning, labeling, ZIP download | NOT STARTED |
| 4 (2 wks) | Splits (Core): proposal, approval flow, locking, PDF export | NOT STARTED |
| 5 (1 wk)  | Verification: public verification links, shareable agreement pages | NOT STARTED |
| 6 (1 wk)  | Communication: project threads, file comments, activity feed | NOT STARTED |
| 7 (1 wk)  | Polish: UI, error handling, email notifications, testing | NOT STARTED |
| 8 (1 wk)  | Launch Prep: Docker Compose prod, Nginx+SSL, CI/CD, monitoring | NOT STARTED |

## Sprint 1 Deliverables
- **Devise auth:** sign up, log in, log out, forgot/reset password (session-based)
- **User model:** email, encrypted_password, display_name, bio, role (enum), skills (PG array), portfolio_urls (JSONB), avatar (ActiveStorage)
- **Validations:** display_name max 50, bio max 500, skills whitelist, portfolio URL format
- **Constants:** ALLOWED_SKILLS (11 skills), ALLOWED_PLATFORMS (5 platforms)
- **Routes:** devise_for :users, root (pages#home), dashboard, singular profile resource
- **Controllers:** PagesController, DashboardController, ProfilesController (+ ApplicationController with Devise param sanitizer)
- **Views:** DaisyUI-styled landing page (hero), sign up, log in, forgot password, reset password, dashboard, profile show/edit
- **Stimulus:** skills_input_controller (tag-based skill selector), flash_controller (auto-dismiss)
- **Post-auth redirects:** sign in → dashboard, sign up → edit profile

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
10. Pushed initial commit to GitHub (git@github-personal:david-ouatedem/split-flow.git)
11. Sprint 1: Added Devise 5.0.2 + bcrypt gems
12. Sprint 1: Generated User model with Devise + custom profile fields migration
13. Sprint 1: Installed ActiveStorage, ran all migrations
14. Sprint 1: Set up routes (devise, root, dashboard, profile)
15. Sprint 1: Created all controllers (pages, dashboard, profiles, application)
16. Sprint 1: Created all views with DaisyUI styling (layout, landing, auth, dashboard, profile)
17. Sprint 1: Created Stimulus controllers (skills_input, flash)
18. Sprint 1: Verified — all classes load, Tailwind builds, User model validates correctly

## Current Step
Sprint 1 complete — next: Sprint 2 (Project workspace CRUD, invitations, access control)

## Important Decisions
- Claude Code must NOT add "Co-Authored-By" to commits
- .claude/settings.local.json is gitignored
- .docx spec file is gitignored (not source code)
- Using Node.js approach for DaisyUI (npm install, @plugin directive)
- Devise session-based auth (no JWT for MVP — add later for mobile/API)
- Skills stored as PostgreSQL text array (not join table) for simplicity
- Portfolio URLs stored as JSONB (not separate model) for simplicity
- Singular `resource :profile` — uses current_user, no ID in URL
- Rails 8 defaults: Solid Queue/Cache/Cable instead of Sidekiq for dev
- Propshaft for asset pipeline (Rails 8 default)
- importmap-rails for JS dependencies (no Webpack/esbuild)
- Remote uses SSH alias `github-personal` (personal GitHub account)
