# clicloud uptime

Checks clicloud every 5 minutes from GitHub's servers, so it still alerts when clicloud's own servers are down.

- What it checks: `targets.txt` (API health, connector sign-in, dashboard, website, and optionally one app on the worker).
- A target is down only after 3 failed tries 20 seconds apart.
- When something goes down, it opens an issue labelled **outage**. GitHub emails you and sends a push to the GitHub app. When everything's back, it closes the issue with the time.
- Past outages are the closed **outage** issues.

## Set up

1. Create a public repo (for example `clicloud-app/uptime`) and push this folder to it. Public repos get Actions minutes free; every 5 minutes in a private repo uses about 9,000 minutes a month.
2. Repo → Settings → Actions → General → Workflow permissions: **Read and write permissions**.
3. Actions → **uptime** → Run workflow, to check it works. The summary lists each target as up or DOWN.
4. Watch the repo (Watch → All activity, or at least Issues) and turn on push for issues in the GitHub mobile app.

To test an alert, add a line like `Test|https://api.clicloud.app/nope|200|` to `targets.txt`, run the workflow, then remove it: the next run closes the issue.

GitHub can run scheduled workflows a few minutes late when it's busy, and pauses them in a repo with no activity for 60 days (it emails you first; one click turns them back on).
