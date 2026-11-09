# Verification record

Date: 2026-11-09

## Firefox support update (0.2.0)

### Passed static and package checks

- `node --check content.js`: JavaScript syntax is valid.
- Manifest JSON parses as Manifest V3 and declares a stable Gecko UUID and
  `data_collection_permissions.required` containing only `none`.
- Reddit HTTPS matches and `document_idle` injection are preserved. No additional
  permissions, background service, storage, or UI were added.
- The shared content script, original project specification, and Firefox task
  specification are unchanged from pre-implementation commit `e5ef4e2`.
- `scripts/package-firefox.ps1` ran successfully and generated
  `dist/reddit-anon-view-0.2.0-unsigned.xpi`.
- The archive contains exactly `manifest.json` and `content.js` at its root.
  Both archived files match their source contents. Documentation, repository
  metadata, and development files are excluded.

### Passed manual browser QA (user-reported)

- The user reports successfully completing manual browser behavior checks in
  Firefox and Chrome for the Firefox support update.
- These results are manual QA reported by the user, not automated browser tests
  or browser tests executed by the implementation agent.
- Exact tested browser versions, installation methods, and per-case results were
  not supplied. Do not infer them from installed executable versions or treat this
  report as evidence of signed installation or persistence across restarts.

### Tooling limitations

- `web-ext` is not installed. An attempt to run it through `npm exec` failed with
  `ENOTCACHED` because the environment permits cached packages only and has no
  cached `web-ext` package. Mozilla's linter did not run; JSON and package checks
  are not equivalent to a successful Mozilla validation or signing submission.
- The implementation agent had no available browser connection. Firefox's local
  executable reported version 159.0.1; this does not establish the version used in
  the user's subsequent manual QA.
- No automated browser testing was performed. Browser Network-panel inspection
  and individual checklist cases are not separately evidenced by the general
  manual QA report.

### Pending signing and installation persistence

- The generated XPI is unsigned. No Mozilla submission, completed signature, or
  installation of a Mozilla-signed artifact has been reported as verified.
- Persistence of a signed installation across a full Firefox restart remains
  pending. Successful browser behavior checks do not establish persistence.
- Complete the user-operated signing, signed installation, and full-restart checks
  in README before marking this acceptance criterion as passed.

No automated test suite or typechecker is configured. The agreed seam remains
manual verification of the installed extension's external browser behavior.

### Firefox update code review

- Standards: no findings from the independent standards review.
- Spec: the earlier review identified browser verification as an acceptance gap.
  The subsequent user-reported manual Firefox and Chrome behavior QA is now
  recorded above. Exact versions and per-case evidence remain unspecified;
  signing and signed-installation persistence remain pending. No proven functional
  defects or scope creep were found through static inspection.

The original project's checks below are historical, not Firefox-update passes.

## Passed

- `node --check content.js`: JavaScript syntax is valid.
- Manifest JSON parses and declares Manifest V3.
- Content-script URL matches are exactly HTTPS `reddit.com` and `www.reddit.com`.
- Content-script injection is configured for `document_idle` and its script exists.
- Manifest has no additional permissions, host-permission declarations,
  background service, or popup action.

## Not performed

- Loading the actual extension in Chrome, Edge, or Brave.
- Browser DOM checks, including delayed insertion, reinsertion, navigation,
  unrelated-element preservation, and scrolling.
- Live anonymous Reddit smoke test and reproduction of the reported selectors.
- Browser Network-panel confirmation of extension behavior.

The browser connection inventory was empty during implementation. Installed
browser executables do not establish that the extension loads or behaves correctly.
These checks remain manual; follow the checklist in [README.md](README.md).

## Test tooling

The project has no automated test suite, typechecker, dependencies, or build step.
The first-version spec calls for a manual browser checklist. Static checks are
not a substitute for browser behavior verification.

## Code review

- Standards: no findings from the independent standards review.
- Spec: one validation gap, consisting of the browser checks listed above. No
  functional defects or scope creep found through static inspection.
