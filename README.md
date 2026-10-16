# ShuttleSync

ShuttleSync Database Systems project. Group members: Muhammad Mahad, Abubakar Khan, and Kaif Ul Imaan.

Pick a campus stop and see when each shuttle will next arrive there, with a live countdown.

## How it works

| Layer | Location | Stack |
|---|---|---|
| Database | [`schema.sql`](schema.sql) | MySQL 8 |
| API | [`DBS Project/Fastapi`](DBS%20Project/Fastapi) | FastAPI + PyMySQL |
| Frontend | [`DBS Project/React/shuttlesync`](DBS%20Project/React/shuttlesync) | React (Create React App) |

Each shuttle starts its route at `Shuttles.StartTime`. It reaches a stop
`Stops.Duration` after that, then again every 15 minutes, until service ends
at 17:00. The `next_arrivals(stopID, atTime)` stored procedure turns this into
each shuttle's next arrival time and the seconds until it arrives.

Other database objects:

- `show_info` / `calculate_time` procedures: read and record a shuttle's stop time for its current cycle.
- `update_cycles_trigger`: recording a time at the last stop counts as one completed cycle.
- `start_service_event` (09:00) and `end_service_event` (17:00): daily events that reset cycles and mark shuttles in or out of service, in campus time (UTC+05:00).
- [`db/create_driver_user.sql`](db/create_driver_user.sql): optional restricted `driver` account.

> `ShuttleSync.mwb` (the MySQL Workbench model) predates these schema
> changes. Treat `schema.sql` as the source of truth.

API endpoints:

- `GET /api/health`: checks the database connection
- `GET /api/stops`: lists all stops
- `GET /api/shuttles`: lists all shuttles
- `GET /api/stops/{id}/arrivals`: the next arrivals at a stop

Interactive docs are at `/docs`.

## Run locally

Requirements: MySQL 8, Python 3.10+, Node 18+.

```bash
# 1. Database
mysql -u root -p < schema.sql

# 2. API (http://127.0.0.1:8000)
cd "DBS Project/Fastapi"
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # then fill in DB_PASSWORD etc.
uvicorn main:app --reload

# 3. Frontend (http://localhost:3000)
cd "DBS Project/React/shuttlesync"
npm install
cp .env.example .env.local
npm start
```

Run the frontend tests with `npm test`.

## Deploy for free (Vercel + Aiven)

Vercel hosts both the React app and the FastAPI app (as a serverless
function). Vercel has no MySQL, so the database goes on
[Aiven's free MySQL plan](https://aiven.io/docs/products/mysql/concepts/mysql-free-tier).
That plan gives 1 CPU, 1 GB RAM and 1 GB of storage, with no time limit.

### 1. Database on Aiven

1. Sign up at [aiven.io](https://aiven.io). Create a **MySQL** service and choose the **Free** plan.
2. When it is running, copy the **Host**, **Port**, **User** (`avnadmin`) and **Password** from the service's overview page. Download the **CA certificate** (`ca.pem`).
3. Load the schema. The easiest way needs nothing installed: GitHub Actions does it for you.
   1. In the repository on GitHub, go to **Settings → Secrets and variables → Actions → New repository secret**. Add `DB_HOST`, `DB_PORT`, `DB_USER` (`avnadmin`) and `DB_PASSWORD` from Aiven. Also add `DB_SSL_CA`, pasting in the whole text of `ca.pem`, including the `BEGIN`/`END CERTIFICATE` lines.
   2. Open the **Actions** tab and choose **Load database schema → Run workflow**. Type `RESET` and run it.
   3. When the run turns green, its log ends with `ShuttleSync.Info has 100 rows.`

   Running it again wipes the database back to the seed data.

   If you have the MySQL command-line client, you can load it from your machine instead:

   ```bash
   mysql --ssl-ca=ca.pem --ssl-mode=VERIFY_CA -h <host> -P <port> -u avnadmin -p -e "source schema.sql"
   ```

   If creating the triggers fails with *"You do not have the SUPER privilege
   and binary logging is enabled"*, turn on `log_bin_trust_function_creators`
   under the service's **Advanced configuration** and run it again.

### 2. API on Vercel

1. In Vercel, choose **Add New → Project** and import this repository.
2. Set **Root Directory** to `DBS Project/Fastapi`. Vercel detects FastAPI from `main.py` and installs `requirements.txt`.
3. Add these **Environment Variables**:

   | Name | Value |
   |---|---|
   | `DB_HOST` / `DB_PORT` | from Aiven |
   | `DB_USER` / `DB_PASSWORD` | from Aiven |
   | `DB_NAME` | `ShuttleSync` |
   | `DB_SSL_CA` | the full contents of `ca.pem` |
   | `CORS_ORIGINS` | the frontend URL from step 3, e.g. `https://shuttlesync.vercel.app` |

4. Deploy, then open `https://<api-project>.vercel.app/api/health`. It should return `{"status":"ok"}`.

### 3. Frontend on Vercel

1. Add a second project from the same repository, with **Root Directory** set to `DBS Project/React/shuttlesync`. The Create React App preset is detected automatically.
2. Add `REACT_APP_API_URL` = `https://<api-project>.vercel.app`. It has no trailing slash and is read at build time.
3. Deploy. If the frontend URL differs from what you put in `CORS_ORIGINS`, update that variable on the API project and redeploy it. Environment variable changes only apply to new deployments.

Notes:

- Vercel's free Hobby plan is for non-commercial use, which covers a course project.
- Aiven may power off a free service that sits unused for a long time. It emails you first, and you can power it back on from the console.
- Never commit `.env` or real passwords. Only the `.env.example` files belong in git.
