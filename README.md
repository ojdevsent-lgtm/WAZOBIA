# WAZOBIA

WAZOBIA is an original Nigerian open-world action game built with **Godot 3.x**. WAZOBIA is the owner/brand of the game universe; playable locations use their real Nigerian city names.

## Platform direction

WAZOBIA is **Android-first** for the first release.

The game is designed to be friendly to Android emulators on PC, with keyboard/mouse controls alongside touch controls. A native PC build can be considered later without changing the core account/world architecture.

## Current foundation — Build 0.2

### Boot and lobby
- Cinematic-style loading screen foundation
- WAZOBIA title and build information
- Main lobby
- Continue
- New Game
- Create Room UI
- Join Room UI
- Friends UI foundation
- Profile UI foundation
- Settings UI foundation
- Store UI foundation

### Character and world
- Character creation: name + gender
- Starting-city selection
- Lagos, Warri, Benin City, Port Harcourt and Abuja
- City-specific spawn positions
- Asset-integrated 3D building environment using the repository GLB library
- Procedural roads and ground
- Third-person player controller
- PC keyboard controls
- Android touch movement controls
- Drivable vehicle prototype
- Vehicle interaction
- Civilian NPCs
- Mission marker and mission state
- Money and mission rewards
- Wanted level
- Police pursuit NPCs
- Lightweight raycast combat
- Health system
- Local continuation save

### Multiplayer architecture foundation
The lobby already reflects the intended online model:

```text
WAZOBIA Android Client
        |
        +-- Account / Profile
        |
        +-- Multiplayer Room
        |
        +-- Shared World Session
        |
        +-- Cloud Save
        |
        +-- Google Play Billing
```

The current Create Room and Join Room screens are **UI/architecture foundations**, not a live internet multiplayer service yet. The authoritative server, account authentication, cloud database and real-time room transport are separate production layers.

## Controls

### PC / Android emulator
- **W/A/S/D** — move
- **Shift** — sprint
- **E** — interact / enter vehicle
- **Space** — fire

### Android
- On-screen movement controls
- **USE** button
- **FIRE** button

## Core gameplay loop

Create character → choose Nigerian city → spawn → explore → find opportunities → complete missions → earn money → build reputation → acquire vehicles/properties/businesses → travel and play with friends.

## Current production direction

The procedural building placeholders are being replaced progressively with real GLB environment assets already stored in `Assets/`. Lightweight collision proxies are retained around imported buildings to keep the first Android-focused environment manageable.

### Asset categories already entering the repository
- Buildings
- Skyscrapers
- Bridge components
- Construction props
- Awnings
- Barriers
- Lighting/details
- Other environment pieces

## Planned production systems

- Detailed Nigerian city districts and landmarks
- Proper Nigerian characters and animations
- Traffic and pedestrian simulation
- Multiple vehicle classes including taxis, buses and motorcycles
- Weapons and inventory
- Shops and businesses
- Police vehicles and escalating wanted levels
- Mission chains and story chapters
- Properties and economy
- City-to-city travel
- Friends and online accounts
- Authoritative room/session multiplayer
- Cloud save and cross-device continuation
- Google Play Billing for Android digital purchases
- Rewarded advertising
- Audio, music, dialogue and Nigerian voice/language work
- Low-end Android optimization
- Native PC release later if justified

## Engine

Godot 3.x

## First release target

- Android
- Android emulator / PC compatibility
