// hydrus-web used to be served at the root of the tailnet address, and it
// installs a service worker there. The dashboard has the root now, but a
// browser keeps a worker whose script answers 404. tailscale serve gives this
// file at the old script's path, so the browser updates to it: it deletes the
// caches, unregisters, and reloads the open pages.
self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
      await self.registration.unregister();
      const windows = await self.clients.matchAll({ type: "window" });
      for (const w of windows) w.navigate(w.url);
    })()
  );
});
