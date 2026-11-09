# Firefox Support

Status: Agreed requirements; implementation has not started. This document specifies the Firefox update. The original project specification remains preserved as the baseline for existing behavior.

## Problem Statement

Reddit Anon View currently provides automatic removal of two anonymous-browsing blockers in Chromium browsers. The user reports that the extension works in Chrome and wants the same experience in current stable desktop Firefox.

Firefox users need an installation that remains enabled after a browser restart. A temporary development installation alone does not meet that requirement. The extension is initially for personal use, without a public Firefox Add-ons listing.

## Solution

Extend the existing extension to current stable desktop Firefox while preserving its Chrome behavior. Firefox must automatically remove the same body scroll-lock class and exact blocking modal, including when Reddit reintroduces either during navigation.

Prepare an extension package and instructions for obtaining Mozilla's signature through the user's Mozilla account using private, unlisted distribution. After signing, the user installs the signed package in normal Firefox and it remains installed and enabled across restarts.

The extension continues to operate entirely within the Reddit page, without settings, analytics, external requests, or stored browsing data. A Mozilla account is needed for the signing workflow, not for using the installed extension or browsing Reddit.

## User Stories

1. As a desktop Firefox user, I want the existing extension's behavior in Firefox, so that I can browse Reddit anonymously in my preferred browser.
2. As an anonymous Reddit reader, I want the specified blocking modal removed automatically, so that I can read content already supplied to my browser.
3. As an anonymous Reddit reader, I want the specified body scroll-lock class removed, so that I can scroll when that class causes the lock.
4. As an anonymous Reddit reader, I want the two blockers handled independently, so that cleanup works when only one appears.
5. As an anonymous Reddit reader, I want blockers removed if they appear after page load, so that delayed prompts do not interrupt reading.
6. As an anonymous Reddit reader, I want blockers removed when they return, so that I do not need to repeat manual cleanup.
7. As an anonymous Reddit reader, I want cleanup to continue when opening another post without a full reload, so that navigation remains usable.
8. As a Reddit reader, I want unrelated prompts, body classes, and styles preserved, so that ordinary page behavior continues to work.
9. As a Firefox user, I want the extension to stay installed and enabled after restarting Firefox, so that I can use it every day without reinstalling it.
10. As a Firefox user, I want private installation instructions, so that I can install the extension without a public Add-ons listing.
11. As the extension owner, I want a package ready for Mozilla's signing workflow, so that I can obtain a signed Firefox installation artifact.
12. As the extension owner, I want clear signing instructions using my Mozilla account, so that I can complete the required external step.
13. As a Firefox user, I want temporary testing distinguished from persistent installation, so that I understand which installation will survive restarting the browser.
14. As an extension user, I want automatic operation without additional controls, so that Firefox requires no extra setup after installation and site-access approval.
15. As a privacy-conscious reader, I want no analytics, external runtime requests, or stored browsing history, so that Firefox support preserves the existing privacy guarantees.
16. As a Firefox user, I want the manifest to accurately declare that the extension collects no data, so that its privacy declaration matches its behavior.
17. As a Chrome user, I want the existing installation and cleanup behavior to keep working, so that adding Firefox does not disrupt my current setup.
18. As a maintainer, I want shared runtime logic where compatible, so that fixes to the two blockers remain consistent across browsers.
19. As a Firefox user, I want verification on the current stable desktop release, so that support claims reflect the intended browser target.
20. As an extension user, I want to disable the extension through browser extension management, so that I can stop cleanup when needed.

## Implementation Decisions

- Target the current stable desktop Firefox release at implementation and verification time. Record the actual tested version. Android, older Firefox releases, and additional release channels are not acceptance targets for this update.
- Retain Manifest V3. Prefer one shared manifest and the existing shared page content script where compatible; the current script uses standard DOM APIs and has no browser-specific extension API calls.
- Add a stable Firefox extension identifier through `browser_specific_settings.gecko.id`, as required for signing a Manifest V3 extension. Preserve that identifier across subsequent Firefox releases.
- Declare no data collection through Firefox's `data_collection_permissions` metadata with `required` set to `none`. This declaration must not introduce data collection, runtime requests, or new user controls.
- Do not select an arbitrary older minimum Firefox version or claim historical compatibility. If manifest validation requires a compatibility floor, document its technical basis without treating untested releases as verified.
- Keep the content script restricted to HTTPS `reddit.com` and `www.reddit.com`. Do not broaden site access for Firefox or testing.
- Preserve exact-selector cleanup: remove only the body's `rpl-scroll-lock` class and elements with ID `configured-xpromo-blocking_xpromo_nsfw_blocking_desktop`. Preserve other classes, styles, and prompts.
- Preserve initial cleanup, continued DOM observation, independent handling of each target, and idempotence. Handle delayed insertion, reinsertion, and same-document navigation without polling or network activity.
- Keep the runtime entirely within the content script. Add no backend, background service, storage, analytics, history access, popup, settings page, or on-page button.
- Prepare a Firefox-compatible ZIP/XPI package containing only required extension runtime files, with the manifest at the archive root. Exclude repository metadata, documentation, and development artifacts.
- Clearly identify the locally prepared artifact as unsigned. It becomes suitable for persistent normal Firefox installation only after Mozilla signs it.
- Document the private signing workflow: use the user's Mozilla account in the Add-ons Developer Hub, choose self-distribution/unlisted distribution, submit the package, complete required declarations, and download the signed artifact when available. Signing does not imply a public listing, and acceptance is subject to Mozilla's review.
- Document installation of the signed artifact through Firefox's add-on manager and a full-restart verification. Do not make disabling signature checks or switching browser editions part of the normal installation path.
- Temporary installation through Firefox's debugging interface may be documented for development, but must be labeled as lasting only until restart and must not substitute for signed-installation acceptance.
- Deliver packaging and signing instructions as part of implementation. Actual submission and signing are an external step performed through the user's Mozilla account; do not describe them as completed until there is evidence.
- Preserve Chromium's unpacked installation workflow and verify Chrome after the shared manifest changes.

## Testing Decisions

- Use the existing highest-level seam agreed during the interview: externally observable behavior with the actual extension installed in a browser. Exercise the manifest, content script, and Firefox package together rather than testing observer callbacks or private helpers.
- Reuse the project's manual browser-verification approach and existing checklist. There is no automated test framework or established automated integration seam; introducing one is not required for this update.
- Good checks assert what the reader experiences and what remains intact: exact modal removal, removal of the specified class, restored scrolling when that class caused the lock, and preservation of unrelated elements and styles.
- On current stable desktop Firefox, verify initial cleanup with both blockers present, each blocker individually, and neither blocker present.
- Verify delayed insertion, repeated reinsertion, and cleanup after navigation without a full document reload. Confirm absence of extension errors or unbounded cleanup loops.
- Verify the two allowed Reddit hosts and confirm the extension does not run on unrelated sites. Confirm any site-access approval required by Firefox is documented.
- Inspect the manifest and runtime for unnecessary permissions, network APIs, and storage use. Verify that the no-data declaration matches the extension's actual behavior; do not attribute Reddit's own network traffic to the extension.
- Validate the archive structure, manifest metadata, referenced scripts, and exclusion of non-runtime files. Run extension-manifest validation where available, and distinguish static validation from browser execution.
- Use temporary installation for development checks if useful. Separately verify that the Mozilla-signed artifact installs in normal Firefox, remains installed and enabled after a full browser restart, and continues removing the blockers on Reddit afterward. Temporary loading cannot satisfy this check.
- Run the relevant Chrome cleanup and navigation checks after the manifest update. The user's report establishes that the earlier Chrome version works; it does not establish that the updated manifest has passed regression checks.
- Include a live anonymous Reddit smoke test on Firefox. If the real prompt cannot be reproduced, record that limitation and use controlled DOM insertion on an allowed Reddit page to check runtime behavior without broadening production permissions. Synthetic checks do not establish that current live selectors are unchanged.
- Record browser versions, installation method, package/signing status, completed checks, and remaining gaps. Do not mark signed installation, restart persistence, or browser behavior as passed without performing those checks.

## Out of Scope

- Implementing the feature as part of this specification-writing task.
- Public listing or public distribution through Firefox Add-ons, Chrome Web Store publication, and automatic update infrastructure.
- Android, Safari, mobile browsers, and verification of older Firefox releases or additional Firefox channels.
- Requiring Developer Edition, disabling signature enforcement, or other unsigned persistent-installation workarounds.
- Changes to the extension's selectors, unrelated prompts, site scope, privacy behavior, or user interface.
- Reddit account creation, authentication changes, API integration, or retrieval of content Reddit does not serve anonymously.
- New scroll-unlocking mechanisms, shadow-root support, or guarantees against future Reddit markup changes.
- Browser-storage features, browsing-history access, analytics, telemetry, and synchronization.

## Further Notes

- The user approved identical Firefox behavior, personal use without a public listing, persistence after browser restarts, current stable desktop Firefox as the support target, and packaging with a user-completed signing workflow.
- The user reports the existing extension is working in Chrome. Firefox support, Firefox installation persistence, and Chrome behavior after future manifest changes remain to be verified.
- The original [project specification](../SPEC.md) is preserved. Its exclusion of Firefox describes the original version; this task-specific document defines the agreed Firefox scope when implementing this update. Other existing behavior and exclusions continue to apply.
- Mozilla documents the stable identifier and browser-specific manifest metadata in the [manifest reference](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/browser_specific_settings). Chrome ignores that browser-specific metadata, but actual Chrome loading still requires verification.
- Consult Mozilla's [signing and distribution overview](https://extensionworkshop.com/documentation/publish/signing-and-distribution-overview/) for persistent release-browser installation and private distribution, [package guidance](https://extensionworkshop.com/documentation/publish/package-your-extension/) for archive layout, and [data-consent documentation](https://extensionworkshop.com/documentation/develop/firefox-builtin-data-consent/) for the no-data declaration. Recheck submission requirements at implementation time.
- This is a local specification only. No issue tracker configuration was supplied, and no issue has been published. Run `/setup-matt-pocock-skills` if tracker publication is needed later.
