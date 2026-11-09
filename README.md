# Reddit Anon View

A small Manifest V3 extension for anonymous Reddit browsing. It removes the
body class `rpl-scroll-lock` and the element with the exact ID
`configured-xpromo-blocking_xpromo_nsfw_blocking_desktop`.

It runs automatically on `https://reddit.com/*` and `https://www.reddit.com/*`,
including when Reddit inserts the blockers later or navigates without reloading.
Other prompts, body classes, and inline styles are preserved.

Chrome and current stable desktop Firefox use the same manifest and content script.
Firefox signing and installation are described below. The user reports successful
manual behavior QA in Firefox and Chrome. Signed-installation persistence remains
pending; see [VERIFICATION.md](VERIFICATION.md) for evidence and limits.

## Install locally in Chrome, Edge, or Brave

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

## Firefox: package, sign privately, and install

Normal Firefox requires Mozilla's signature for persistent installation. Signing
for **self-distribution (unlisted)** does not create a public Add-ons listing.
The unsigned package below is an upload artifact, not a persistently installable
Firefox release. See [Mozilla's signing guide](https://extensionworkshop.com/documentation/publish/signing-and-distribution-overview/).

1. In PowerShell, run this from the project folder:

   ```powershell
   .\scripts\package-firefox.ps1
   ```

   This creates `dist/reddit-anon-view-0.2.0-unsigned.xpi`. Run it again after
   changing the extension; the versioned output is rebuilt from the current
   manifest and content script. No dependencies or bundler are needed.
2. Sign in with your Mozilla account at the
   [Add-ons Developer Hub](https://addons.mozilla.org/developers/).
3. Submit a new add-on and choose **On your own** / self-distribution (unlisted),
   then upload the unsigned XPI. Complete Mozilla's required declarations and any
   review steps. This extension collects no data, has no remote code, and uses
   plain source JavaScript with no compilation step. Signing is subject to Mozilla's
   acceptance; no submission or signature has been obtained by this project yet.
4. Download Mozilla's **signed** XPI when it is available. Keep it separate from
   the generated unsigned artifact, and do not modify or repackage it afterward.
5. In Firefox, open `about:addons`. Use the gear menu and **Install Add-on From
   File…**, select the signed XPI, and approve the installation and requested Reddit
   site access. If cleanup does not run, open the extension's **Permissions** or
   site-access controls and confirm it is allowed on the current Reddit site.
6. Open or reload a Reddit page while signed out. Run the checks below, fully quit
   Firefox, reopen it, and repeat the checks. Confirm the extension remains installed
   and enabled after that restart.

No Firefox preference changes or Developer Edition are needed. A Mozilla account
is required to obtain the signature, not to use the installed extension. Future
Firefox releases must retain the same Gecko ID and use a new extension version
before signing; automatic updates are outside this project's scope.

### Temporary Firefox development installation

For an unsigned development check, open `about:debugging`, select **This Firefox**,
then **Load Temporary Add-on…** and select this folder's `manifest.json` (or the
unsigned XPI). Approve Reddit access if prompted and reload Reddit. Use **Reload**
in that debugging page after code edits, then reload the Reddit tab.

This installation disappears when Firefox restarts. It cannot verify persistent
installation; use the signed artifact and the restart check above for that.
[Mozilla's temporary installation guide](https://extensionworkshop.com/documentation/develop/temporary-installation-in-firefox/)

## Privacy and limits

The extension has no popup, settings, background service, analytics, storage, or
external requests. Its only site access is the two Reddit URL patterns above.
It does not use Reddit APIs or request browser-history access.

The shared manifest declares Firefox's stable extension ID and that it collects
no data. Chrome ignores the browser-specific metadata; the runtime and Reddit
site scope are shared. See the [manifest reference](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/browser_specific_settings)
and [Firefox's no-data declaration](https://extensionworkshop.com/documentation/develop/firefox-builtin-data-consent/).
The signing upload is a separate owner-operated distribution step; the installed
extension itself does not contact Mozilla or other services.

It can reveal only content Reddit already sent to your browser. It cannot fetch
content requiring authentication. Other Reddit subdomains, other scroll-lock
mechanisms, unrelated overlays, and targets inside shadow roots are outside the
first version's scope. Reddit markup changes may require selector updates.

## Manual verification

Use this checklist with the actual extension installed. Test changes to
page content only on a disposable Reddit tab, then reload to restore the page.

In Firefox, run it with the signed extension installed, or explicitly record a
temporary development install. Record browser versions and installation methods.
The Firefox target is the current stable desktop release; Android, older releases,
and other Firefox channels are not verified targets. No historical compatibility
floor is asserted in the manifest.

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
- In Firefox, inspect the extension's permissions and confirm the no-data
  declaration and site access. Complete the signed-installation restart check;
  then rerun cleanup and navigation checks after the restart.
- In Chrome, reload the extension after this manifest update and repeat initial
  cleanup, reinsertion, and same-document navigation checks for future changes.
- Run installation and behavior checks separately in Edge and Brave before
  describing either browser as verified.

Remove the temporary marker with
`document.body.classList.remove("anon-view-check")`, or reload the tab.

## Validation status

JavaScript syntax and manifest consistency can be checked locally. Firefox
packaging only archives the runtime files; it does not compile or sign them.
There is no automated test suite or typechecking configuration in this plain
JavaScript project. Browser verification results are recorded in
[VERIFICATION.md](VERIFICATION.md); unperformed checks must not be treated as passes.

See [SPEC.md](SPEC.md) for the original behavior and
[the Firefox support spec](specs/firefox-support.md) for this update.
