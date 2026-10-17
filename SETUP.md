# Bhasker ❤️ Vinita — Love Letter with Live Acknowledgement

## Included
- `index.html` — responsive Hindi love letter with acknowledgement button.
- `supabase_setup.sql` — creates the status table and initial status row.
- `SETUP.md` — this guide.

## 1) Set up the live status (Supabase)
1. Create a free project at https://supabase.com/.
2. In your project, open **SQL Editor → New query**.
3. Paste the complete contents of `supabase_setup.sql` and click **Run**.
4. Open **Project Settings → API** (or **Connect**) and copy the Project URL and anon/publishable key.
5. `index.html` is already configured for the Vinita Proposal Supabase project and the WhatsApp number supplied for this page. If you switch projects or numbers, update `SUPABASE_URL`, `SUPABASE_ANON_KEY`, or `WHATSAPP_NUMBER` there.
6. Do not put a `service_role` or secret key in the HTML. Only use the public anon/publishable key.

## 2) Publish the page
The live status works only after the page is hosted online. Easiest options:
- **Netlify Drop:** https://app.netlify.com/drop — drag the folder containing `index.html` (or a ZIP with `index.html`) into the deploy area.
- **GitHub Pages:** upload `index.html` to a repository and enable Pages in repository settings.

Use the public URL Netlify/GitHub gives you as the link to send Vinita.

## 3) Open the dashboard
If your published page is `https://your-site.example/`, open:
`https://your-site.example/?view=dashboard`

Bookmark this dashboard URL. It refreshes the acknowledgement status about every 10 seconds.

## 4) What happens when Vinita acknowledges
- She taps **“मैंने तुम्हारा ख़त पढ़ लिया ❤️”**.
- The page saves the acknowledgement timestamp to Supabase.
- It opens WhatsApp with a ready-to-send message to your number. She must tap **Send** in WhatsApp; websites cannot silently send a WhatsApp message on her behalf.
- Your dashboard shows the saved acknowledgement and time.

## Important privacy / reliability note
This starter uses a public acknowledgement table policy to keep setup simple. It is appropriate only for a low-sensitivity personal status, and it is **not tamper-proof**: someone with the public page could alter the status. The dashboard URL is not an authentication system. For stronger privacy and verified acknowledgements, use a server-side endpoint with authentication and restricted database permissions.
