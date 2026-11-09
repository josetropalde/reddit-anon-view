# Reddit Anon View

A small Manifest V3 extension for anonymous Reddit browsing. It removes the
body class `rpl-scroll-lock` and the element with the exact ID
`configured-xpromo-blocking_xpromo_nsfw_blocking_desktop`.

It runs automatically on `https://reddit.com/*` and `https://www.reddit.com/*`,
including when Reddit inserts the blockers later or navigates without reloading.
Other prompts, body classes, and inline styles are preserved.

## Install locally

1. Keep this folder on your computer. No build or dependency installation is needed.
2. Open your browser's extension manager:
   - Chrome: `chrome://extensions`
   - Edge: `edge://extensions`
   - Brave: `brave://extensions`
3. Enable **Developer mode** and select **Load unpacked**.
4. Select this folder, which contains `manifest.json`.
5. Open or reload a Reddit tab. To check anonymous behavior, use a browser
   session where you are signed out of Reddit.

After editing the extension, click **Reload** in the extension manager and reload
the Reddit tab. To disable it, use the extension manager and reload Reddit;
disabling does not restore elements already removed from an open page.

## Privacy and limits

The extension has no popup, settings, background service, analytics, storage, or
external requests. Its only site access is the two Reddit URL patterns above.
It does not use Reddit APIs or request browser-history access.

It can reveal only content Reddit already sent to your browser. It cannot fetch
content requiring authentication. Other Reddit subdomains, other scroll-lock
mechanisms, unrelated overlays, and targets inside shadow roots are outside the
first version's scope. Reddit markup changes may require selector updates.

## Manual verification

Use this checklist with the actual unpacked extension loaded. Test changes to
page content only on a disposable Reddit tab, then reload to restore the page.

- Confirm the extension manager reports no installation or content-script errors.
- With the extension disabled, locate the observed modal and body class on an
  anonymous Reddit page, if that prompt can be reproduced. Enable the extension
  and reload: the exact modal and class should disappear and scrolling should work
  when that class was responsible for the lock.
- Browse to another post without a full reload. Confirm cleanup still works.
- Confirm unrelated prompts and body classes remain. Confirm a page with neither
  blocker continues to work without errors.
- On a matched Reddit tab, the following DevTools Console snippet can simulate
  later insertion of both blockers. This tests the installed content script;
  it does not inject extension code or broaden its URL access.

```js
document.body.classList.add("anon-view-check", "rpl-scroll-lock");
const checkModal = document.createElement("div");
checkModal.id = "configured-xpromo-blocking_xpromo_nsfw_blocking_desktop";
document.body.append(checkModal);
```

In a **separate Console evaluation**, after observers have run, check:

```js
({
  unlocked: !document.body.classList.contains("rpl-scroll-lock"),
  modalRemoved: !document.getElementById(
    "configured-xpromo-blocking_xpromo_nsfw_blocking_desktop"
  ),
  unrelatedClassPreserved: document.body.classList.contains("anon-view-check"),
});
```

All three values should be `true`. The synthetic class alone may not lock scrolling
unless Reddit's CSS applies that rule; use the real prompt for a scrolling check.

- Repeat insertion several times, using a fresh variable name or reusing the
  existing variable. Test the class and modal separately as well.
- Insert a wrapper containing the exact modal ID to check nested insertion.
- Insert a differently identified modal and confirm it stays in the document.
- Insert an element without an ID, then assign the target ID later; confirm removal.
- Repeat these checks after opening another post within the same document.
- In DevTools, confirm no extension errors. Review the manifest and content script
  to confirm there are no storage or network APIs; distinguish Reddit's own traffic
  from extension activity when inspecting the Network panel.
- Test an unrelated site: the content script should not be listed for that page.
- Disable the extension and reload: its cleanup should stop.
- Run installation and behavior checks separately in Edge and Brave before
  describing either browser as verified.

Remove the temporary marker with
`document.body.classList.remove("anon-view-check")`, or reload the tab.

## Validation status

JavaScript syntax and manifest consistency can be checked locally without a build.
There is no automated test suite or typechecking configuration in this plain
JavaScript project. Browser verification results are recorded in
[VERIFICATION.md](VERIFICATION.md); unperformed checks must not be treated as passes.

See [SPEC.md](SPEC.md) for the requirements and exclusions.
