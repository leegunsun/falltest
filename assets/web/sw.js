let appKey;

self.addEventListener('message', function(event) {
  if (event.data && event.data.type === 'SET_APP_KEY') {
    appKey = event.data.appKey;
    console.log('App key received:', appKey); // appKey 수신 확인
  }
});

self.addEventListener('install', function(event) {
  console.log('Service Worker install event triggered'); // 설치 이벤트 확인
  event.waitUntil(
    caches.open('kakao-map-cache').then(function(cache) {
        return cache.add(new Request(`https://dapi.kakao.com/v2/maps/sdk.js?appkey=${appKey}&autoload=false`, { mode: 'no-cors' }))
            .then(() => console.log('SDK cached successfully'))
            .catch(error => console.error('Error caching SDK:', error));
        });
    })
  );
});

self.addEventListener('fetch', function(event) {
  console.log('Fetch event for:', event.request.url); // fetch 이벤트 확인
  event.respondWith(
    caches.match(event.request).then(function(response) {
      if (response) {
        console.log('Serving from cache:', event.request.url); // 캐시에서 제공되는 경우
      } else {
        console.log('Fetching from network:', event.request.url); // 네트워크에서 가져오는 경우
      }
      return response || fetch(event.request);
    }).catch((error) => {
      console.error('Fetch error:', error); // fetch 오류 확인
    })
  );
});
