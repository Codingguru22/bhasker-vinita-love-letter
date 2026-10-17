# Bhasker ❤️ Vinita — Love Letter with Live Acknowledgement

## Included
- `index.html` — responsive Hindi love letter with acknowledgement button.
- `supabase_setup.sql` — creates the status table and initial status row.
- `SETUP.md` — this guide.

## 1) Set up the live status (Supabase)
1. Create a free project at https://supabase.com/.
2. In your project, open **SQL Editor → New query**.
3. Paste the complete contents of `supabase_setup.sql` and click **Run**. The script is safe to rerun; it adds the visit log and its restricted write functions.
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
- The dashboard records that the acknowledgement button was tapped. The site cannot verify whether WhatsApp actually sent the message.

## 5) Letter opening log and location
- Each tap on **“तुम्हारे लिए एक ख़त खोलूँ?”** creates one row in `public.love_letter_open_events`.
- `opened_at` is stored as a timezone-aware instant (Postgres `timestamptz`), which Supabase normalizes and may display in UTC. For an explicit IST display in Table Editor, run the complete `supabase_setup.sql` again to create the owner-only `public.love_letter_open_events_ist` view, then open that view. Its `opened_at_ist`, `created_at_ist`, and `whatsapp_opened_at_ist` columns include the `IST` suffix.
- The page discloses location collection before the letter opens. The browser asks for location permission; coordinates are saved only after permission is granted. If permission is denied or unavailable, the event is still recorded with a location status and no coordinates.
- Public visitors can add events but cannot read the event table. Read it in Supabase **Table Editor → love_letter_open_events** or run this query in SQL Editor:

```sql
select
  id,
  opened_at at time zone 'Asia/Kolkata' as opened_at_ist,
  location_status,
  latitude,
  longitude,
  location_accuracy_m,
  case when whatsapp_opened_at is null
       then 'not opened from this visit'
       else 'WhatsApp opened; send not verified' end as whatsapp_status,
  whatsapp_opened_at at time zone 'Asia/Kolkata' as whatsapp_opened_at_ist
from public.love_letter_open_events
order by opened_at desc;
```

## Privacy / reliability
Visit rows can be submitted from the public page, so they are not proof of a unique human visitor and timestamps can be modified by a technically capable visitor. The event table has no public read policy; its rows should be viewed from the Supabase project owner account. Location is optional and depends on browser permission. WhatsApp link opening is tracked, but sending the message requires the visitor to press **Send** and cannot be confirmed by this static website. The dashboard URL itself is not an authentication system.


### Why the base table shows UTC

The base table uses timestamptz so each event represents one unambiguous instant. Supabase may display those values in UTC; the opened_at_ist, created_at_ist, and whatsapp_opened_at_ist columns in love_letter_open_events_ist convert them for display and append IST. The original event data is not shifted or rewritten.
