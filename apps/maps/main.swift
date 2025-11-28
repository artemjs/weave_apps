import WeaveUI

struct MapsApp: App {
  @State var searchQuery: String = ""
  @State var mapUrl: String = "https://www.google.com/maps/embed?pb=!1m14!1m12!1m3!1d15000!2d-122.4194!3d37.7749!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!5e0!3m2!1sen!2sus!4v1"
  @State var currentLocation: String = "San Francisco, CA"
  @State var savedPlaces: [String] = ["Home", "Work", "Gym"]
  @State var showSidebar: Bool = true
  @State var mapType: String = "roadmap"
  @State var zoom: Int = 12

  var body: some View {
    HStack(spacing: 0) {
      // Sidebar
      if showSidebar {
        VStack(spacing: 0) {
          // Search bar
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
                  .foregroundColor(.secondary)
              }
            }
            .padding(.bottom, 8)

            HStack {
              Text("🔍")
              TextField("Search places...", text: $searchQuery)
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            Button(action: { searchPlace() }) {
              HStack {
                Text("Search")
                Spacer()
                Text("→")
              }
              .padding(10)
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
          }
          .padding()
          .background(Color.black.opacity(0.3))

          // Quick actions
          VStack(spacing: 8) {
            Text("Quick Actions")
              .font(.caption)
              .foregroundColor(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
              QuickButton(icon: "🏠", label: "Home", action: { goToPlace("Home") })
              QuickButton(icon: "💼", label: "Work", action: { goToPlace("Work") })
              QuickButton(icon: "📍", label: "My Location", action: { goToMyLocation() })
            }
          }
          .padding()

          Divider()

          // Map type selector
          VStack(spacing: 8) {
            Text("Map Type")
              .font(.caption)
              .foregroundColor(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
              MapTypeButton(type: "roadmap", label: "🛣️", current: $mapType)
              MapTypeButton(type: "satellite", label: "🛰️", current: $mapType)
              MapTypeButton(type: "terrain", label: "⛰️", current: $mapType)
              MapTypeButton(type: "hybrid", label: "🌍", current: $mapType)
            }
          }
          .padding()

          Divider()

          // Saved places
          VStack(spacing: 8) {
            HStack {
              Text("Saved Places")
                .font(.caption)
                .foregroundColor(.secondary)
              Spacer()
              Button(action: { addPlace() }) {
                Text("+ Add")
                  .font(.caption)
                  .foregroundColor(.blue)
              }
            }

            ScrollView {
              VStack(spacing: 4) {
                ForEach(savedPlaces, id: \.self) { place in
                  Button(action: { goToPlace(place) }) {
                    HStack {
                      Text("📌")
                      Text(place)
                        .lineLimit(1)
                      Spacer()
                      Text("→")
                        .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                  }
                }
              }
            }
          }
          .padding()

          Spacer()

          // Current location info
          VStack(spacing: 4) {
            HStack {
              Text("📍")
              Text(currentLocation)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Text("Zoom: \(zoom)x")
              .font(.caption2)
              .foregroundColor(.secondary)
          }
          .padding()
          .background(Color.black.opacity(0.2))
        }
        .frame(width: 260)
        .background(Color(hex: "#1a1a2e"))
      }

      // Map view
      VStack(spacing: 0) {
        // Map toolbar
        HStack {
          if !showSidebar {
            Button(action: { showSidebar = true }) {
              Text("☰")
                .font(.title2)
                .padding(8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
          }

          Spacer()

          // Zoom controls
          HStack(spacing: 4) {
            Button(action: { zoomIn() }) {
              Text("+")
                .font(.title2)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
            Button(action: { zoomOut() }) {
              Text("-")
                .font(.title2)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
          }

          Spacer()

          // Directions button
          Button(action: { getDirections() }) {
            HStack {
              Text("🧭")
              Text("Directions")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))

        // Google Maps embed
        WebView(url: mapUrl)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(maxWidth: .infinity)
    }
    .background(Color(hex: "#0f0f1a"))
  }

  func searchPlace() {
    if !searchQuery.isEmpty {
      let encoded = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
      mapUrl = "https://www.google.com/maps/embed/v1/place?key=AIzaSyBFw0Qbyq9zTFTd-tUY6dZWTgaQzuU17R8&q=\(encoded)&zoom=\(zoom)"
      currentLocation = searchQuery
    }
  }

  func goToPlace(_ place: String) {
    searchQuery = place
    searchPlace()
  }

  func goToMyLocation() {
    // Use geolocation
    mapUrl = "https://www.google.com/maps/embed?pb=!1m14!1m12!1m3!1d15000!2d-122.4194!3d37.7749!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!5e0!3m2!1sen!2sus"
    currentLocation = "Current Location"
  }

  func addPlace() {
    if !searchQuery.isEmpty && !savedPlaces.contains(searchQuery) {
      savedPlaces.append(searchQuery)
    }
  }

  func zoomIn() {
    if zoom < 20 {
      zoom += 1
      updateMapZoom()
    }
  }

  func zoomOut() {
    if zoom > 1 {
      zoom -= 1
      updateMapZoom()
    }
  }

  func updateMapZoom() {
    let encoded = currentLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? currentLocation
    mapUrl = "https://www.google.com/maps/embed/v1/place?key=AIzaSyBFw0Qbyq9zTFTd-tUY6dZWTgaQzuU17R8&q=\(encoded)&zoom=\(zoom)&maptype=\(mapType)"
  }

  func getDirections() {
    let encoded = currentLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? currentLocation
    mapUrl = "https://www.google.com/maps/embed/v1/directions?key=AIzaSyBFw0Qbyq9zTFTd-tUY6dZWTgaQzuU17R8&origin=My+Location&destination=\(encoded)&mode=driving"
  }
}

struct QuickButton: View {
  let icon: String
  let label: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Text(icon)
          .font(.title2)
        Text(label)
          .font(.caption2)
      }
      .frame(maxWidth: .infinity)
      .padding(8)
      .background(Color.gray.opacity(0.2))
      .cornerRadius(8)
    }
  }
}

struct MapTypeButton: View {
  let type: String
  let label: String
  @Binding var current: String

  var body: some View {
    Button(action: { current = type }) {
      Text(label)
        .font(.title2)
        .frame(width: 44, height: 44)
        .background(current == type ? Color.blue : Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
  }
}
