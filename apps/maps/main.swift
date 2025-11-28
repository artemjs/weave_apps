import WeaveUI

struct MapsApp: App {
  @State var searchQuery: String = ""
  @State var mapUrl: String = "https://www.openstreetmap.org/export/embed.html?bbox=-122.5,37.7,-122.3,37.85&layer=mapnik"

  func doSearch() {
    let encoded = encodeURIComponent(searchQuery)
    mapUrl = "https://www.openstreetmap.org/search?query=" + encoded
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 8) {
        Text("🗺️ Maps")
          .font(.title2)
          .fontWeight(.bold)
        Spacer()
      }
      .padding(12)
      .background(Color.black.opacity(0.3))

      HStack(spacing: 8) {
        TextField("Search places...", text: $searchQuery)
          .padding(8)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(8)
        Button(action: { doSearch() }) {
          Text("🔍")
        }
        .padding(8)
        .background(Color.blue)
        .cornerRadius(8)
      }
      .padding(12)

      WebView(url: mapUrl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#0f0f1a"))
  }
}
