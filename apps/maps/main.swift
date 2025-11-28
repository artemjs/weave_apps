import WeaveUI

struct MapsApp: App {
  @State var searchQuery: String = ""
  @State var lat: Number = 37.7749
  @State var lon: Number = -122.4194
  @State var zoom: Number = 13

  func buildUrl() {
    return "https://www.openstreetmap.org/export/embed.html?bbox=" + (lon-0.05) + "," + (lat-0.05) + "," + (lon+0.05) + "," + (lat+0.05) + "&layer=mapnik&marker=" + lat + "," + lon
  }

  func doSearch() {
    let query = encodeURIComponent(searchQuery)
    fetch("https://nominatim.openstreetmap.org/search?format=json&q=" + query).then(function(r) { return r.json() }).then(function(data) {
      if (data.length > 0) {
        setLat(parseFloat(data[0].lat))
        setLon(parseFloat(data[0].lon))
      }
    })
  }

  func getLocation() {
    navigator.geolocation.getCurrentPosition(function(pos) {
      setLat(pos.coords.latitude)
      setLon(pos.coords.longitude)
    })
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 8) {
        TextField("Search places...", text: $searchQuery)
          .padding(10)
          .background(Color.white.opacity(0.9))
          .cornerRadius(10)
        Button(action: { doSearch() }) {
          Text("🔍")
        }
        .padding(10)
        .background(Color.blue)
        .cornerRadius(10)
        Button(action: { getLocation() }) {
          Text("📍")
        }
        .padding(10)
        .background(Color.green)
        .cornerRadius(10)
      }
      .padding(10)
      .background(Color.black.opacity(0.8))

      WebView(url: buildUrl())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
