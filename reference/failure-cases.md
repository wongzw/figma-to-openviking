# Known failures

| Symptom | Cause | Fix |
|---|---|---|
| One huge image with tiny unreadable screens | Exported a PAGE/SECTION node | Run `list_frames.js` and export each frame |
| Image is 1x or blurry | Used `get_screenshot` (max 1x) | Use `download_assets` with `defaultScale: 2` |
| `curl` 403/404 on export URL | URL expired | Re-run `download_assets` for that batch and download immediately |
| 2x export errors or too large | Very tall frame | Retry 1.7, then 1.5; record in `scales.tsv` |
| File named `.png` but `not-png` | Error page saved as file | Re-export that node |
| Two files with the same bytes | Duplicate frames in Figma, or a mix-up | Re-export both; same `sizeBytes` = real duplicate, keep both |
| `ov add-resource --to` fails: exists | Target already there | Ask: `--replace`, or per-file upload |
| `manifest.md` not found remotely | OV stores markdown as a folder with a renamed file | Expected; check with `ov tree` |
| A PNG appears as `x.png/x.png` | Older OV versions wrap media in a folder | Expected; `upload.sh` checks both forms |
| `ov` wait times out | Indexing still running | `ov task list`; don't resubmit while it is `running` |
| `get_metadata` returns huge XML or JSON errors | Page too big | Use `list_frames.js` via `use_figma` instead |
| Figma permission error | No access to the file | `whoami` to confirm the account; ask the owner to share |
| Figma rate limit | Too many parallel calls | Lower the batch to 4, retry after a minute |
| `REJECT url` from download_batch | URL is not a Figma MCP export URL | Use only `export.url` from `download_assets` |
| `REJECT path` from download_batch | Path is absolute, has `..`, or isn't `.png` | Fix the row in `plan.tsv` |
| `refusing target parent` from upload | Destination is a root, or under memories/skills | Use a named folder under `viking://resources/` or the user's `resources/` |
