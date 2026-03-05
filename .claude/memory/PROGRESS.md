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

## Sprint Plan
| Sprint | Focus | Status |
|--------|-------|--------|
| 1 (2 wks) | Foundation: Devise auth, profiles, DB schema | COMPLETE |
| 2 (2 wks) | Projects: CRUD, invitations, collaborator management, access control | COMPLETE |
| 3 (2 wks) | Files: ActiveStorage uploads to R2, versioning, labeling, ZIP download | NOT STARTED |
| 4 (2 wks) | Splits (Core): proposal, approval flow, locking, PDF export | NOT STARTED |
| 5 (1 wk)  | Verification: public verification links, shareable agreement pages | NOT STARTED |
| 6 (1 wk)  | Communication: project threads, file comments, activity feed | NOT STARTED |
| 7 (1 wk)  | Polish: UI, error handling, email notifications, testing | NOT STARTED |
| 8 (1 wk)  | Launch Prep: Docker Compose prod, Nginx+SSL, CI/CD, monitoring | NOT STARTED |

## Sprint 2 Deliverables
- **Project model:** title, description, genre, bpm, visibility (private/public enum), status (draft/active/completed/archived enum), owner_id FK
- **Collaboration model:** user_id, project_id, role (free-text), status (pending/accepted/declined enum), unique composite index
- **User associations:** has_many :owned_projects, :collaborations, :collaborated_projects
- **Authorization:** ProjectAuthorization concern with `authorize_project_access!` and `authorize_project_owner!`
- **Access control:** private projects only visible to owner + accepted collaborators; public projects visible to all
- **Project scope:** `visible_to(user)` handles public/owner/collaborator access in single query
- **ProjectsController:** full CRUD, index shows owned + collaborating separately, show accessible without auth for public projects
- **CollaborationsController:** create (invite by email), destroy, accept, decline, invitations listing
- **Turbo Streams:** inline updates for invite/accept/decline/remove actions
- **Views:** projects index/show/new/edit, collaboration partials, invitations page — all DaisyUI styled
- **Navigation:** Projects + Invitations (with pending count badge) links in navbar
- **Dashboard:** stats cards (projects count, collaborations count, pending invitations) + quick actions

## Key Data Models (implemented)
- **User:** email, display_name, bio, role (enum), skills (PG array), portfolio_urls (JSONB), avatar (ActiveStorage) + owned_projects, collaborations, collaborated_projects
- **Project:** title, description, genre, bpm, visibility, status → belongs_to :owner (User), has_many :collaborations, :collaborators
- **Collaboration:** user_id, project_id, role, status → belongs_to :user, :project

## Key Data Models (not yet implemented)
- ProjectFile: name, label, version, upload_timestamp → has_one_attached :file
- SplitAgreement: project_id, status (draft/pending/locked), locked_at
- SplitEntry: agreement_id, user_id, percentage, approved_at
- Comment: body, commentable_type/id (polymorphic: project or file)

## Current Step
Sprint 2 complete — next: Sprint 3 (File uploads, versioning, labeling, ZIP download)

## Important Decisions
- Claude Code must NOT add "Co-Authored-By" to commits
- Devise session-based auth (no JWT for MVP)
- Enum naming: `private_project`/`public_project` to avoid Ruby keyword clash
- Collaboration role is free-text string (not enum) since roles vary per project
- Only existing users can be invited (no email-to-non-user invitations for MVP)
- Authorization via simple concern (no Pundit) — `ProjectAuthorization`
- Singular `resource :profile` — uses current_user, no ID in URL
- Remote uses SSH alias `github-personal` (personal GitHub account)
