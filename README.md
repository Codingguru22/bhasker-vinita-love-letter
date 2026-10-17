# Bhasker & Vinita Love Letter

A static Hindi love letter with a Supabase acknowledgement button. The page is `index.html`; the database setup is documented in `supabase_setup.sql` and `SETUP.md`.

## GitHub Pages

1. Create a GitHub repository and add the project files to its root.
2. In the repository, open **Settings → Pages**.
3. Set the source to **Deploy from a branch**, choose `main` and `/(root)`, then save.
4. Wait for GitHub Pages to provide the site URL.

The Supabase project URL and publishable key, plus the WhatsApp number, are already configured in `index.html`.

## Public access

GitHub Pages publishes a public website. This page contains personal letter text and a WhatsApp number. The Supabase publishable key is intended for browser use. The included SQL allows anonymous visitors to read and change the acknowledgement status, so it is not tamper-proof.
