# Upstream upgrade — 7.2.3 base → Nextcloud iOS **34.1.4** (stable)

Target: `nextcloud/ios` tag **34.1.4** (latest stable release, 2026-08-24).
Skipped: `master` / 35.0.0 (unreleased dev).
Gap: **346 upstream commits** onto our base; our **6** customizations replayed on top.
Strategy: **rebase** avuz customizations onto 34.1.4 (per-release branch pattern, e.g. `avuz-customization-v34.1.4`).

> Not in 34.1.4 yet (master-only, arrives a future release): **Albums integration**, **unified sharing interface**.

---

## New features (11)

| Feature | PR |
|---|---|
| Load media-viewer originals on demand | #4256 |
| Media repeat + auto-advance controls | #4243 |
| VLC playback options for videos | #4213 |
| Media date navigation by month | #4199 |
| Persist media preview backfill failures | #4197 |
| Document editor coordinator | #4237 |
| API support in direct editing | #4249 |
| Manage tags | #4055 |
| Track server certificate trust status | #4222 |
| NC governance | #4152 |
| Add Dependabot | #4257 |

## Login / security / E2EE

- **Passkeys on login** (#3996)
- Server certificate trust status tracking (#4222)
- E2EE overhaul: renew certificate (#4189), key-checksum fix (#4182), setup refactor (#4056), improvements (#4052), string/error review (#4050)
- OAEP notification encryption (#4103)
- Wrong-passcode prompt shows immediately (no delay)

## Performance / refactor

- Async file preview loading (#4210)
- Prefetch collection-view images + avatars (#4215)
- Image cache window management into `NCImageCache` (#4207)
- Consolidated media metadata backfill (#4198)
- Reorganized plus-menu document actions (#4271)
- Removed obsolete upload no-delete handling (#4246)
- Removed Assistant text handling from share extension (#4240)

## Notable behavior / i18n

- "Group folder" → **"Team folder"** rename (#4075) — user-facing terminology.

## Stability

- Crashlytics integration (#4083), release build settings (#4082), assorted crash fixes.
- **161 bug fixes** total across files, media, sync, sharing.

---

## Rebase — expected conflict set

Our 6 commits touch (conflict-prone in **bold**):

- **`Nextcloud.xcodeproj/project.pbxproj`** — bundle IDs, automatic signing, MARKETING_VERSION 7.2.3. Upstream bumped to 34.x + added files → guaranteed conflict.
- `Brand/*` (NCBrand.swift, plists, entitlements, Intro storyboard, assets) — mostly fork-only, low risk; watch NCBrand.swift for new upstream keys.
- `iOSClient/NCBackgroundLocationUploadManager.swift` — simulator-guard patch; conflict if upstream touched it.
- `iOSClient/Settings/NCSettingsModel.swift`, `NCSettingsView.swift` — conflict if upstream changed settings.
- `CLAUDE.md`, `customizations.json`, `assets/` — fork-only, no conflict.

Post-rebase: bump MARKETING_VERSION intent (keep Avuz scheme vs adopt 34.1.4?), verify build on iPhone + iPad, re-check branding surfaces.

---

## Rebase result (done)

Rebased cleanly onto **34.1.4**; all 6 customizations replayed. Backup ref: `backup/pre-34.1.4-rebase-20260913`.

Conflicts resolved:
- `Brand/Custom.xcassets/AppIcon.appiconset/Contents.json` — adopted upstream **single universal 1024** icon format (old multi-size PNGs left as harmless orphans; branding replaces icon).
- `iOSClient/Settings/Settings/NCSettingsView.swift` — kept our `disable_information_section_in_settings` guard **and** upstream `.font(.headline)`; DEBUG crash-test section kept outside the guard.
- `Brand/Intro/NCIntroViewController.swift` — kept our removal of `signupWithProvider`/`host` (single-screen onboarding; storyboard has no dangling refs).
- `Brand/NCBrand.swift` — kept Avuz brand color `#f2f6fb` / black text.
- `Nextcloud.xcodeproj/project.pbxproj` — rule: **upstream build settings + Avuz identity**. Adopted `DEAD_CODE_STRIPPING = YES`, kept `DEVELOPMENT_TEAM = HH38JC58JL`, `CODE_SIGN_STYLE = Automatic`, bundle `app.avuz.conecta`, `CURRENT_PROJECT_VERSION = 1`.

State: app `MARKETING_VERSION = 34.1.4`; display name still "Avuz Conecta" (→ "Conecta Drive" is the branding task).

### Build note
- No `GoogleService-Info.plist` at repo root — needed at runtime (Firebase). Use the [mock config](https://github.com/firebase/quickstart-ios/blob/master/mock-GoogleService-Info.plist) for dev builds.

