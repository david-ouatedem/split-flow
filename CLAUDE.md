# SplitFlow - Claude Code Instructions

## Git Commit Rules
- Do NOT add "Co-Authored-By" lines to commits
- Commit messages should be concise and reflect the change purpose
- Only commit when explicitly asked

## Project Overview
SplitFlow is a collaborative platform for music producers.
See `splitflow_mvp_spec_v2.docx` for the full product spec.
See `.claude/memory/PROGRESS.md` for development progress and context.

## Tech Stack
- **Backend:** Ruby on Rails 8.1.2 (fullstack with Hotwire)
- **Frontend:** Tailwind CSS v4 + DaisyUI 5 + Stimulus (via Hotwire)
- **Database:** PostgreSQL 16
- **Storage:** Cloudflare R2 via ActiveStorage (planned)
- **Auth:** Devise + JWT (planned)
- **Background Jobs:** Sidekiq + Redis (planned — using Solid Queue for now)
- **Deployment:** Docker Compose
- **Ruby:** 3.4.8 (rbenv)

## Key Commands
```bash
bin/rails server            # start dev server
bin/dev                     # start dev server with Tailwind watcher
bin/rails db:migrate        # run migrations
bin/rails db:create         # create databases
bin/rails tailwindcss:build # build Tailwind CSS
bin/rails test              # run tests
bundle exec rubocop         # lint
```

## Frontend Guidelines
- Use DaisyUI component classes (btn, card, modal, etc.) for UI elements
- Use Stimulus controllers for JavaScript behavior
- Use Turbo Frames and Turbo Streams for dynamic updates
- Keep custom CSS minimal — prefer utility classes
