// Request browser geolocation permission and get position
function requestBrowserLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error("Geolocation not supported"));
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        console.log("Location obtained:", position.coords);
        resolve(position);
      },
      (error) => {
        console.error("Geolocation error:", error);
        reject(error);
      },
      { 
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    );
  });
}

// Make it globally available
window.requestBrowserLocation = requestBrowserLocation;