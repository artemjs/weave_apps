import WeaveUI

struct MapsApp: App {
  @State var searchQuery: String = ""
  @State var currentLocation: String = "San Francisco, CA"
  @State var mapUrl: String = "https://www.google.com/maps/embed?pb=!1m14!1m12!1m3!1d50000!2d-122.4194!3d37.7749!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!5e0!3m2!1sen!2sus"
  @State var showSidebar: Bool = true
  @State var zoom: Int = 12

  func searchPlace() {
    if searchQuery.length > 0 {
      const encoded = encodeURIComponent(searchQuery)
      mapUrl = "https://www.google.com/maps/embed/v1/place?key=AIzaSyBFw0Qbyq9zTFTd-tUY6dZWTgaQzuU17R8&q=" + encoded + "&zoom=" + zoom
      currentLocation = searchQuery
    }
  }

  func zoomIn() {
    if zoom < 20 {
      zoom = zoom + 1
    }
  }

  func zoomOut() {
    if zoom > 1 {
      zoom = zoom - 1
    }
  }

  var body: some View {
    HStack(spacing: 0) {
      if showSidebar {
        VStack(spacing: 0) {
          VStack(spacing: 12) {
            HStack(spacing: 8) {
              Text("🗺️")
                .font(.title)
              Text("Maps")
                .font(.title2)
                .fontWeight(.bold)
              Spacer()
              Button(action: { showSidebar = false }) {
                Text("◀")
              }
            }

            TextField("Search places...", text: $searchQuery)
              .padding(10)
              .background(Color.gray.opacity(0.2))
              .cornerRadius(8)

            Button(action: { searchPlace() }) {
              Text("🔍 Search")
            }
            .padding(10)
            .background(Color.blue)
            .cornerRadius(8)
          }
          .padding(16)
          .background(Color.black.opacity(0.3))

          VStack(spacing: 8) {
            Text("Quick Places")
              .font(.caption)
              .foregroundColor(.secondary)

            HStack(spacing: 8) {
              Button(action: { searchQuery = "Home"; searchPlace() }) {
                Text("🏠")
              }
              Button(action: { searchQuery = "Work"; searchPlace() }) {
                Text("💼")
              }
              Button(action: { searchQuery = "Restaurant"; searchPlace() }) {
                Text("🍽️")
              }
              Button(action: { searchQuery = "Gas Station"; searchPlace() }) {
                Text("⛽")
              }
            }
          }
          .padding(16)

          Divider()

          VStack(spacing: 4) {
            Text("📍")
            Text(currentLocation)
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding(16)

          Spacer()
        }
        .frame(width: 260)
        .background(Color(hex: "#1a1a2e"))
      }

      VStack(spacing: 0) {
        HStack(spacing: 12) {
          if !showSidebar {
            Button(action: { showSidebar = true }) {
              Text("☰")
            }
            .padding(8)
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
          }

          Spacer()

          Button(action: { zoomIn() }) {
            Text("+")
          }
          .padding(8)
          .background(Color.black.opacity(0.5))
          .cornerRadius(8)

          Button(action: { zoomOut() }) {
            Text("-")
          }
          .padding(8)
          .background(Color.black.opacity(0.5))
          .cornerRadius(8)

          Spacer()

          Text("Zoom: ")
          Text(zoom)
        }
        .padding(12)
        .background(Color.black.opacity(0.3))

        WebView(url: mapUrl)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#0f0f1a"))
  }
}
