# SplitFlow Development Progress

## Project Summary
SplitFlow — collaborative platform for music producers. Core wedge: split agreements.
Full spec: `splitflow_mvp_spec_v2.docx` in project root.

## Tech Stack
- **Backend:** Ruby on Rails 8.1.2 (Hotwire: Turbo + Stimulus)
- **Frontend:** Tailwind CSS v4.2 + DaisyUI 5.5 + Stimulus
- **Database:** PostgreSQL 16 (databases: splitflow_development, splitflow_test)
- **Storage:** ActiveStorage with local disk (development), Cloudflare R2 (production)
- **Auth:** Devise 5.0.2 (session-based, no JWT for MVP)
- **Background Jobs:** Solid Queue (Rails 8 default; Sidekiq+Redis for production later)
- **Ruby:** 3.4.8 via rbenv
- **Node:** 24.x (for DaisyUI npm package)
- **File Processing:** rubyzip ~> 2.3 for ZIP bundle generation
- **Deployment:** Docker Compose (Sprint 8)

## Sprint Plan
| Sprint | Focus | Status |
|--------|-------|--------|
| 1 (2 wks) | Foundation: Devise auth, profiles, DB schema | COMPLETE |
| 2 (2 wks) | Projects: CRUD, invitations, collaborator management, access control | COMPLETE |
| 3 (2 wks) | Files: ActiveStorage uploads to R2, versioning, labeling, ZIP download | COMPLETE |
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

## Sprint 3 Deliverables
- **ProjectFile model:** name, label, version, project_id, uploader_id with unique composite index on (project_id, label, version)
- **ActiveStorage integration:** has_one_attached :file with automatic file attachment handling
- **File validation:** 200MB max size, whitelisted content types (WAV, MP3, FLAC, AIFF, OGG, M4A, ZIP)
- **Auto-versioning:** automatic version increment per label within each project (Drums v1, v2, v3, etc.)
- **Storage config:** local disk for development, Cloudflare R2 (S3-compatible) for production
- **ProjectFilesController:** create (upload), destroy, download_all (ZIP bundle)
- **Access control:** only project collaborators can upload/download files; uploader or owner can delete
- **Upload UI:** collapsible form with file picker, label dropdown (Drums, Bass, Lead Melody, etc.), optional name field
- **File list:** displays file cards with name, label, version badge, uploader, size, upload date, audio preview player
- **Audio preview:** HTML5 audio player for uploaded audio files (inline playback)
- **ZIP download:** "Download All" button generates organized ZIP with files grouped by label folders
- **Turbo Streams:** instant UI updates on upload/delete without full page reload
- **Routes:** nested under projects as `/projects/:id/files` with collection route for download_all
- **Dependencies:** rubyzip gem for ZIP generation

## Key Data Models (implemented)
- **User:** email, display_name, bio, role (enum), skills (PG array), portfolio_urls (JSONB), avatar (ActiveStorage) + owned_projects, collaborations, collaborated_projects, uploaded_files
- **Project:** title, description, genre, bpm, visibility, status → belongs_to :owner (User), has_many :collaborations, :collaborators, :project_files
- **Collaboration:** user_id, project_id, role, status → belongs_to :user, :project
- **ProjectFile:** name, label, version, project_id, uploader_id + has_one_attached :file → belongs_to :project, :uploader (User)

## Key Data Models (not yet implemented)
- SplitAgreement: project_id, status (draft/pending/locked), locked_at
- SplitEntry: agreement_id, user_id, percentage, approved_at
- Comment: body, commentable_type/id (polymorphic: project or file)

## Current Step
Sprint 3 complete — next: Sprint 4 (Split agreements: proposal, approval flow, locking, PDF export)

## Important Decisions
- Claude Code must NOT add "Co-Authored-By" to commits (via `.claude/settings.local.json`)
- Devise session-based auth (no JWT for MVP)
- Enum naming: `private_project`/`public_project` to avoid Ruby keyword clash
- Collaboration role is free-text string (not enum) since roles vary per project
- Only existing users can be invited (no email-to-non-user invitations for MVP)
- Authorization via simple concern (no Pundit) — `ProjectAuthorization`
- Singular `resource :profile` — uses current_user, no ID in URL
- Remote uses SSH alias `github-personal` (personal GitHub account)
- File versioning auto-increments per label (not per project) — allows multiple files with same label
- File label is required field with predefined options (Drums, Bass, Lead Melody, etc.)
- 200MB file size limit enforced at model level
- Local disk storage for development, Cloudflare R2 for production (S3-compatible)
- Only uploader or project owner can delete files (enforced in controller)
