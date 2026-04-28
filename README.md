# gspot-game-damalobana
თამაში დამალობანა, ინტერგრირებული gspot-web თან

A multiplayer hide-and-seek game built with **Godot 4 / GDScript**.  
A single codebase is exported as a **WebGL** build for players and a **Linux Headless** build for the dedicated server.

---

## Directory Structure

```
gspot-game-damalobana/
├── client/
│   ├── scenes/          # Client-only scenes (menus, HUD, in-game camera rigs…)
│   └── ui/              # Control nodes, theme resources, UI components
├── server/              # Server-only scripts (game-loop authority, match state…)
├── shared/
│   ├── mechanics/       # Game rules shared between client & server (visibility, tagging…)
│   ├── entities/        # Shared entity definitions (Player, HidingSpot…)
│   └── NetworkManager.gd  # Autoload singleton — WebSocket networking
├── assets/
│   ├── models/          # Blockbench .glb exports
│   ├── textures/        # PNG/WebP textures
│   └── sounds/          # SFX & music
└── project.godot
```

---

## Networking

`shared/NetworkManager.gd` is registered as an **Autoload singleton** (`NetworkManager`).

| Build type | Behaviour in `_ready()` |
|------------|------------------------|
| Dedicated server (`OS.has_feature("dedicated_server")`) | Starts a WebSocket server on **port 8080** |
| Client / WebGL | Does nothing automatically; call `NetworkManager.connect_to_server(url)` from the UI |

### Client usage

```gdscript
# From a menu button handler:
NetworkManager.connected_to_server.connect(_on_connected)
NetworkManager.connect_to_server("ws://your-server.example.com:8080")
```

### Signals

| Signal | Emitted on | Description |
|--------|-----------|-------------|
| `client_connected(peer_id)` | Server | A new client joined |
| `client_disconnected(peer_id)` | Server | A client left |
| `connected_to_server()` | Client | Successfully connected |
| `disconnected_from_server()` | Client | Connection lost |
