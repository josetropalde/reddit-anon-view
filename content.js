(() => {
  "use strict";

  const modalId = "configured-xpromo-blocking_xpromo_nsfw_blocking_desktop";
  const scrollLockClass = "rpl-scroll-lock";
  let observedBody = null;

  function unlockBody() {
    if (observedBody?.classList.contains(scrollLockClass)) {
      observedBody.classList.remove(scrollLockClass);
    }
  }

  const bodyObserver = new MutationObserver(unlockBody);

  function observeBody() {
    if (document.body === observedBody) return;

    bodyObserver.disconnect();
    observedBody = document.body;
    if (observedBody) {
      bodyObserver.observe(observedBody, {
        attributes: true,
        attributeFilter: ["class"],
      });
      unlockBody();
    }
  }

  function removeModals(root) {
    if (root.nodeType === Node.ELEMENT_NODE && root.id === modalId) {
      root.remove();
      return;
    }

    root.querySelectorAll(`#${modalId}`).forEach((modal) => modal.remove());
  }

  const pageObserver = new MutationObserver((mutations) => {
    observeBody();

    for (const mutation of mutations) {
      if (mutation.type === "attributes") {
        if (mutation.target.id === modalId) mutation.target.remove();
        continue;
      }

      for (const node of mutation.addedNodes) {
        if (node.nodeType === Node.ELEMENT_NODE && node.isConnected) {
          removeModals(node);
        }
      }
    }
  });

  pageObserver.observe(document, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ["id"],
  });
  observeBody();
  removeModals(document);
})();
