# Reddit Anon View — First-Version Specification

Status: Requirements synthesized from the design interview. Implementation has not started. The proposed testing approach below has not been separately confirmed.

## Problem Statement

People browsing Reddit without an account can encounter a blocking promotional modal and a body scroll lock that prevent them from reading forum content already loaded on the page. Manually removing these elements through developer tools is inconvenient and may need to be repeated during navigation.

The user observed the body class `rpl-scroll-lock` and a blocking element with the ID `configured-xpromo-blocking_xpromo_nsfw_blocking_desktop`.

## Solution

Provide a small browser extension for Chrome and other Chromium browsers, including Edge and Brave. Once installed locally and enabled, it automatically removes the specified body class and blocking element on Reddit. It continues watching for either blocker to return, including during navigation that does not reload the page.

The extension operates entirely within the Reddit page, requires no account, and has no popup, settings page, or on-page controls. Users disable it through the browser's extension manager.

## User Stories

1. As an anonymous Reddit reader, I want the specified blocking modal removed automatically, so that I can read content already loaded on the page.
2. As an anonymous Reddit reader, I want the specified scroll-lock class removed from the body, so that I can scroll through the forum.
3. As an anonymous Reddit reader, I want cleanup to happen when I open a Reddit page, so that I do not need to use developer tools.
4. As an anonymous Reddit reader, I want cleanup to work when the blockers appear after the page loads, so that delayed prompts do not interrupt reading.
5. As an anonymous Reddit reader, I want the blockers removed if Reddit inserts them again, so that browsing can continue.
6. As an anonymous Reddit reader, I want cleanup to continue when I open another post without a full reload, so that I do not need to refresh the page.
7. As a Reddit reader, I want pages without either blocker to keep working normally, so that the extension does not interfere with ordinary browsing.
8. As a Reddit reader, I want unrelated prompts and body classes preserved, so that other page behavior remains available.
9. As a Chrome user, I want to install the extension locally, so that I can use the first version without a store release.
10. As an Edge or Brave user, I want the extension to use Chromium extension capabilities, so that I can install it in my browser.
11. As an extension user, I want it to run automatically without extra controls, so that it requires no routine interaction.
12. As an extension user, I want to disable it through my browser's extension manager, so that I can stop its behavior when needed.
13. As a privacy-conscious reader, I want the extension to make no external requests or analytics reports, so that my browsing is not transmitted by the extension.
14. As a privacy-conscious reader, I want the extension to store no browsing history, so that using it creates no browsing record of its own.
15. As a first-time installer, I want clear local installation and verification instructions, so that I can confirm the extension works.

## Implementation Decisions

- Use the Manifest V3 extension format and target Chromium browsers for the first version.
- Provide a manifest, a page content script, and local installation and verification documentation. The workspace is currently empty; there are no existing modules, domain glossary, or ADRs to follow.
- Limit execution to Reddit pages. Use `reddit.com` and `www.reddit.com` over HTTPS as the initial content-script URL scope; support for other Reddit subdomains is not an acceptance requirement.
- Remove only `rpl-scroll-lock` from the body class list. Preserve every other class and do not replace the body's complete class attribute or broadly override its styles.
- Remove only elements whose ID exactly matches `configured-xpromo-blocking_xpromo_nsfw_blocking_desktop`. Do not use broad modal or promotional selectors.
- Handle the two targets independently: either may appear without the other.
- Run an initial cleanup after the DOM is available, then observe relevant DOM changes for subsequent cleanup. Continued observation must handle delayed insertion, reinsertion, and navigation within the same document.
- Use DOM observation rather than repeated network requests or continuous polling. Avoid redundant observer work and self-triggered cleanup loops.
- Cleanup must be idempotent: repeated execution leaves the page in the same desired state and tolerates absent targets.
- Keep all processing within the page content script. The feature needs no backend, background service, storage, analytics, external requests, or browser-history access.
- Request only access needed to run the content script on the intended Reddit pages. Do not request access to unrelated sites.
- Provide no popup, settings page, or on-page button. Browser extension management is the enable/disable mechanism; reloading an open page after disabling restores a fresh Reddit-rendered page.
- Deliver for local unpacked installation. Do not publish to an extension store as part of this version.

## Testing Decisions

- Proposed primary seam: externally observable page behavior with the actual extension loaded in a Chromium browser. Test the resulting DOM and user-visible scrolling rather than helper names, observer callbacks, or internal call counts.
- Exercise the manifest and content script together at this seam. The empty workspace contains no existing test infrastructure or similar tests to reuse.
- Provide a manual verification checklist for the first version, consistent with the agreed scope. An automated end-to-end harness is not required for this small initial implementation.
- Use a controlled page fixture through the browser verification setup when necessary to reproduce exact targets reliably; do not broaden the shipped extension's URL access solely for testing.
- Verify initial cleanup with both targets present: the exact modal is removed and the body no longer contains the specified class. Confirm scrolling on a page where that class caused the lock.
- Verify each target independently and verify that a page with neither target produces no errors or unrelated DOM changes.
- Verify delayed insertion and repeated reinsertion of the modal and scroll-lock class.
- Verify cleanup continues after navigation within the same document.
- Verify unrelated body classes, differently identified modals, and other prompts remain intact.
- Verify the unpacked extension loads in Chrome; smoke-test installation and behavior in Edge and Brave before claiming those browsers have been verified.
- Verify the manifest's site scope and absence of unnecessary permissions. Check that the extension initiates no external requests and persists no browsing data.
- Include a live anonymous Reddit smoke test. Report when the target prompt cannot be reproduced; a fixture passing does not establish that Reddit's current live markup still matches the selectors.

## Out of Scope

- Firefox, Safari, and mobile browser support.
- Extension-store submission, public distribution, and automatic update infrastructure.
- Account creation, sign-in, authentication changes, or Reddit API integration.
- Retrieving content Reddit does not serve to anonymous visitors.
- Removing other login prompts, consent dialogs, advertisements, or unrelated overlays.
- Generic scroll unlocking through inline-style overrides or removal of other classes.
- Popup interfaces, settings, toggles inside Reddit, or user-configurable selectors.
- Analytics, telemetry, external services, stored browsing history, and synchronization.
- Guaranteed compatibility with future Reddit markup changes or additional rendering contexts not covered by the observed selectors.

## Further Notes

- The user accepted Chromium support, exact-selector cleanup, local installation, continued cleanup during navigation, automatic operation without controls, and fully local processing without analytics, external requests, or stored history.
- The exact selectors come from the user's observations. They have not been independently verified against the current live Reddit DOM. Whether the target appears inside a shadow root is also unverified; do not claim support without inspecting and testing that context.
- Removing the class only resolves scrolling when that class is responsible for the lock. Other locks are outside this specification.
- The extension reveals only content already supplied to the browser. It does not grant access to content that requires server-side authorization.
- Reddit markup changes may require updating the two selectors and repeating verification.
- No issue tracker or triage-label configuration was supplied. This document is the local spec; it has not been published as an issue. The to-spec workflow requires `/setup-matt-pocock-skills` before tracker publication with the `ready-for-agent` label.
