# BEAR

A simple draft of a 2D adventure game built with [LÖVE](https://love2d.org/) (Love2D) where a bear navigates through a procedurally generated forest to reach a birthday party.

## Story

A girl invites Bear to her birthday party, but the forest is full of nightmares. Help Bear escort the girl safely through the dangerous forest to her house — both must arrive together to win.

## Features

- **Procedurally generated world** — Each game creates a unique 200×200 tile map with trees, stones, and grass.
- **Dialogue system** — Conversations between Bear and the girl with scripted intro and ending sequences.
- **Enemy AI** — Enemies patrol the forest and must be avoided or defeated.
- **Two endings** — Win by escorting the girl to her house together, or face a bad ending if caught.
- **Multi-language support** — English and Russian.
- **Music** — Multiple music tracks that play during gameplay and the ending.

## Controls

- **Left mouse button** — Move Bear to a location
- **Right mouse button** — Shoot
- **ESC** — Quit (or return to menu from ending screen)
- **R** — Restart from ending screen

## How to Run

### Prerequisites

- [LÖVE](https://love2d.org/) 11.x or later installed

### Windows

```bash
love /path/to/bear
```

### Linux / macOS

```bash
love /path/to/bear
```

## Project Structure

| File/Directory | Description |
|---|---|
| `fx/` | Visual effects |
| `img/` | Sprite and tile assets |
| `locale/` | Localization files (English, Russian) |
| `music/` | Music tracks |
| `scripts/` | Scripted dialogue sequences (intro, endings) |
| `states/` | Game states (menu, game) |
| `a_star.lua` | Pathfinding algorithm |
| `baseActor.lua` | Base actor class |
| `camera.lua` | Camera system with layered rendering |
| `conf.lua` | LÖVE configuration (fullscreen, no physics) |
| `config.lua` | Game settings (world size, speeds, tile types) |
| `conversation.lua` | Conversation system |
| `dialogue.lua` | Dialogue system |
| `enemy.lua` | Enemy logic |
| `enemyManager.lua` | Enemy management |
| `girl.lua` | NPC character (the girl) |
| `hero.lua` | Player character (Bear) |
| `locale.lua` | Localization loader |
| `main.lua` | Entry point, state machine setup |
| `music.lua` | Music playback |
| `state.lua` | State machine framework |
| `util.lua` | Utility functions |
| `world.lua` | Procedural world generation |

## License

MIT License — see [LICENSE](LICENSE) for details.
