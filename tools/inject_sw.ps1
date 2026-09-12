# Injects a robust offline-first service worker into the Flutter web build.
# Run AFTER `flutter build web --release`.
$ErrorActionPreference = 'Stop'

$root = 'C:\Users\User\Desktop\AUTOMOTIVE'
$build = Join-Path $root 'build\web'

$versionData = Get-Content (Join-Path $build 'version.json') -Raw | ConvertFrom-Json
$mainHash = (Get-FileHash (Join-Path $build 'main.dart.js')).Hash.Substring(0, 10)
$cacheName = 'autoassist-' + $versionData.version + '-' + $mainHash

# All deployable files (same-origin), excluding the worker itself, big canvaskit
# chunks (cached on the fly), and vercel state files.
$files = Get-ChildItem -Path $build -Recurse -File -Force | Where-Object {
    $_.FullName -notlike '*\.vercel\*' -and
    $_.Name -ne 'flutter_service_worker.js' -and
    $_.Name -ne '.last_build_id' -and
    $_.FullName -notlike '*\canvaskit\*'
} | ForEach-Object {
    ('.' + $_.FullName.Substring($build.Length)).Replace('\', '/')
}
$filesJson = $files | ConvertTo-Json

$template = @'
// AutoAssist offline-first service worker (custom).
const CACHE = '__CACHE_VERSION__';
const PRECACHE = __FILES__;

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting())
      .catch(() => {})
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((key) => key.startsWith('autoassist-') && key !== CACHE)
            .map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== location.origin) return;

  // Navigations: network-first, fall back to cached shell (kills offline 404s).
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response.ok && response.type === 'basic') {
            const copy = response.clone();
            caches.open(CACHE).then((cache) => cache.put(request, copy));
          }
          return response;
        })
        .catch(() => caches.open(CACHE).then((cache) =>
          cache.match(request)
            .then((hit) => hit || cache.match('index.html') || cache.match('./index.html') || cache.match('/index.html'))
        ))
    );
    return;
  }

  // Static assets: cache-first, then network with caching.
  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;
      return fetch(request).then((response) => {
        if (response.ok && response.type === 'basic') {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      }).catch(() => cached);
    })
  );
});
'@

$sw = $template.Replace('__CACHE_VERSION__', $cacheName).Replace('__FILES__', $filesJson)
$out = Join-Path $build 'flutter_service_worker.js'
Set-Content -LiteralPath $out -Value $sw -Encoding UTF8 -NoNewline
Write-Host "Custom service worker written: $out"
Write-Host "Cache: $cacheName | $($files.Count) precached files"