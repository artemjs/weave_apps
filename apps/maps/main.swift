import WeaveUI

struct MapsApp: App {
  @State var lat: Number = 55.7558
  @State var lon: Number = 37.6173
  @State var zoom: Number = 12
  @State var searchQuery: String = ""
  @State var isDragging: Bool = false
  @State var dragStartX: Number = 0
  @State var dragStartY: Number = 0
  @State var dragStartLat: Number = 0
  @State var dragStartLon: Number = 0
  @State var tiles: Array = []
  @State var mapLayer: String = "standard"
  @State var showLayerPicker: Bool = false

  func getTileUrl(x: Number, y: Number, z: Number) {
    if (mapLayer == "satellite") {
      return "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/" + z + "/" + y + "/" + x
    } else if (mapLayer == "terrain") {
      return "https://tile.opentopomap.org/" + z + "/" + x + "/" + y + ".png"
    }
    return "https://tile.openstreetmap.org/" + z + "/" + x + "/" + y + ".png"
  }

  func lon2tile(lon: Number, zoom: Number) {
    return Math.floor((lon + 180) / 360 * Math.pow(2, zoom))
  }

  func lat2tile(lat: Number, zoom: Number) {
    return Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * Math.pow(2, zoom))
  }

  func tile2lon(x: Number, z: Number) {
    return x / Math.pow(2, z) * 360 - 180
  }

  func tile2lat(y: Number, z: Number) {
    let n = Math.PI - 2 * Math.PI * y / Math.pow(2, z)
    return 180 / Math.PI * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n)))
  }

  func doSearch() {
    let query = encodeURIComponent(searchQuery)
    fetch("https://nominatim.openstreetmap.org/search?format=json&q=" + query).then(function(r) { return r.json() }).then(function(data) {
      if (data.length > 0) {
        setLat(parseFloat(data[0].lat))
        setLon(parseFloat(data[0].lon))
        setZoom(15)
      }
    })
  }

  func getLocation() {
    navigator.geolocation.getCurrentPosition(function(pos) {
      setLat(pos.coords.latitude)
      setLon(pos.coords.longitude)
      setZoom(15)
    }, function(err) {
      console.log("Geolocation error:", err.message)
    })
  }

  func zoomIn() {
    if (zoom < 19) {
      setZoom(zoom + 1)
    }
  }

  func zoomOut() {
    if (zoom > 1) {
      setZoom(zoom - 1)
    }
  }

  func handleWheel(e) {
    if (e.deltaY < 0 && zoom < 19) {
      setZoom(zoom + 1)
    } else if (e.deltaY > 0 && zoom > 1) {
      setZoom(zoom - 1)
    }
  }

  func handleMouseDown(e) {
    setIsDragging(true)
    setDragStartX(e.x)
    setDragStartY(e.y)
    setDragStartLat(lat)
    setDragStartLon(lon)
  }

  func handleMouseMove(e) {
    if (isDragging) {
      let dx = e.x - dragStartX
      let dy = e.y - dragStartY
      let scale = 360 / Math.pow(2, zoom) / 256
      setLon(dragStartLon - dx * scale)
      setLat(dragStartLat + dy * scale * 0.7)
    }
  }

  func handleMouseUp(e) {
    setIsDragging(false)
  }

  var body: some View {
    ZStack {
      Canvas(onDraw: { ctx, size in
        ctx.fillStyle = '#1a1a2e'
        ctx.fillRect(0, 0, size.width, size.height)

        let tileSize = 256
        let centerTileX = lon2tile(lon, zoom)
        let centerTileY = lat2tile(lat, zoom)

        let tilesX = Math.ceil(size.width / tileSize) + 2
        let tilesY = Math.ceil(size.height / tileSize) + 2

        let offsetX = size.width / 2 - (lon2tile(lon, zoom) - Math.floor(lon2tile(lon, zoom))) * tileSize
        let offsetY = size.height / 2 - (lat2tile(lat, zoom) - Math.floor(lat2tile(lat, zoom))) * tileSize

        for (let dy = -Math.floor(tilesY/2); dy <= Math.floor(tilesY/2); dy++) {
          for (let dx = -Math.floor(tilesX/2); dx <= Math.floor(tilesX/2); dx++) {
            let tileX = Math.floor(centerTileX) + dx
            let tileY = Math.floor(centerTileY) + dy

            if (tileY >= 0 && tileY < Math.pow(2, zoom)) {
              tileX = ((tileX % Math.pow(2, zoom)) + Math.pow(2, zoom)) % Math.pow(2, zoom)

              let x = size.width / 2 + dx * tileSize - (lon2tile(lon, zoom) % 1) * tileSize
              let y = size.height / 2 + dy * tileSize - (lat2tile(lat, zoom) % 1) * tileSize

              let url = getTileUrl(tileX, tileY, zoom)
              let img = new Image()
              img.crossOrigin = "anonymous"
              img.src = url
              img.onload = function() {
                ctx.drawImage(img, x, y, tileSize, tileSize)
              }

              ctx.strokeStyle = 'rgba(255,255,255,0.1)'
              ctx.strokeRect(x, y, tileSize, tileSize)
            }
          }
        }

        ctx.fillStyle = '#ef4444'
        ctx.beginPath()
        ctx.arc(size.width / 2, size.height / 2, 8, 0, Math.PI * 2)
        ctx.fill()
        ctx.fillStyle = '#fff'
        ctx.beginPath()
        ctx.arc(size.width / 2, size.height / 2, 4, 0, Math.PI * 2)
        ctx.fill()
      })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrag { e in
          handleMouseMove(e)
        }
        .onWheel { e in
          handleWheel(e)
        }

      VStack(spacing: 0) {
        HStack(spacing: 8) {
          TextField("Search places...", text: $searchQuery)
            .padding(12)
            .background(Color.white.opacity(0.95))
            .cornerRadius(12)
          Button(action: { doSearch() }) {
            Text("🔍")
          }
          .padding(12)
          .background(Color.blue)
          .cornerRadius(12)
          Button(action: { getLocation() }) {
            Text("📍")
          }
          .padding(12)
          .background(Color.green)
          .cornerRadius(12)
          Button(action: { setShowLayerPicker(!showLayerPicker) }) {
            Text("🗺️")
          }
          .padding(12)
          .background(Color.purple)
          .cornerRadius(12)
        }
        .padding(12)
        .background(Color.black.opacity(0.7))

        if showLayerPicker {
          HStack(spacing: 8) {
            Button(action: { setMapLayer("standard"); setShowLayerPicker(false) }) {
              Text("Standard")
            }
            .padding(8)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(8)
            Button(action: { setMapLayer("satellite"); setShowLayerPicker(false) }) {
              Text("Satellite")
            }
            .padding(8)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(8)
            Button(action: { setMapLayer("terrain"); setShowLayerPicker(false) }) {
              Text("Terrain")
            }
            .padding(8)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(8)
          }
          .padding(8)
          .background(Color.black.opacity(0.8))
        }

        Spacer()

        HStack(spacing: 8) {
          VStack(spacing: 4) {
            Button(action: { zoomIn() }) {
              Text("+")
            }
            .padding(12)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            Button(action: { zoomOut() }) {
              Text("-")
            }
            .padding(12)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
          }
          Spacer()
        }
        .padding(12)

        HStack {
          Text("Zoom: " + zoom + " | " + lat.toFixed(4) + ", " + lon.toFixed(4))
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
        }
        .padding(8)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
