import WeaveUI

struct MapsApp: App {
  @State var searchQuery: String = ""
  @State var mapUrl: String = "https://www.openstreetmap.org/export/embed.html?bbox=-122.5,37.7,-122.3,37.85&layer=mapnik"
  @State var hasLocation: Bool = false

  func doSearch() {
    let encoded = encodeURIComponent(searchQuery)
    mapUrl = "https://www.openstreetmap.org/export/embed.html?bbox=" + encoded + "&layer=mapnik&marker=true"
  }

  func getLocation() {
    navigator.geolocation.getCurrentPosition(function(pos) {
      let lat = pos.coords.latitude
      let lon = pos.coords.longitude
      let bbox = (lon - 0.01) + "," + (lat - 0.01) + "," + (lon + 0.01) + "," + (lat + 0.01)
      setMapUrl("https://www.openstreetmap.org/export/embed.html?bbox=" + bbox + "&layer=mapnik&marker=" + lat + "," + lon)
      setHasLocation(true)
    })
  }

  var body: some View {
    ZStack {
      WebView(url: mapUrl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      VStack {
        HStack(spacing: 8) {
          TextField("Search places...", text: $searchQuery)
            .padding(10)
            .background(Color.white.opacity(0.95))
            .cornerRadius(12)
          Button(action: { doSearch() }) {
            Text("🔍")
          }
          .padding(10)
          .background(Color.blue)
          .cornerRadius(12)
          Button(action: { getLocation() }) {
            Text("📍")
          }
          .padding(10)
          .background(Color.green)
          .cornerRadius(12)
        }
        .padding(12)
        Spacer()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
