import WeaveUI

struct MapsApp: App {
  @State var searchQuery: String = ""
  @State var mapUrl: String = "https://www.google.com/maps/embed?pb=!1m14!1m12!1m3!1d50000!2d-122.4194!3d37.7749!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1"

  func doSearch() {
    const encoded = encodeURIComponent(searchQuery)
    mapUrl = "https://www.google.com/maps/embed/v1/place?key=AIzaSyBFw0Qbyq9zTFTd-tUY6dZWTgaQzuU17R8&q=" + encoded
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
