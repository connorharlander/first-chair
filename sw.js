// First Chair Prep service worker: works offline, never caches Supabase data calls.
const VERSION = "fc-v4";   // change this string on each deploy to push an update
const SHELL = ["./", "./index.html", "./config.js", "./manifest.webmanifest",
  "./img/teton-1400.jpg", "./icons/icon-192.png", "./icons/icon-512.png", "./icons/apple-touch-icon.png",
  "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.110.0/dist/umd/supabase.js"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => Promise.all(SHELL.map(u => c.add(u).catch(() => {})))).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

function timeout(ms) { return new Promise((_, rej) => setTimeout(() => rej(new Error("timeout")), ms)); }

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.hostname.endsWith("supabase.co") || url.hostname.endsWith("supabase.in")) return; // live data: network only

  if (url.origin === self.location.origin) {
    // Our own files: try the network (3 s), fall back to cache. Keeps updates fast and works offline.
    e.respondWith(
      Promise.race([fetch(req), timeout(3000)]).then(res => {
        const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); return res;
      }).catch(() => caches.match(req, { ignoreSearch: true }).then(r => r || caches.match("./index.html")))
    );
    return;
  }
  // Fonts and the Supabase library: cache first.
  e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => {
    if (res.ok || res.type === "opaque") { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
    return res;
  })));
});
