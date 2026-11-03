# 04: PRODUCTION (v2: Godot)

> How the game gets made: tech, art, effects, music, voice, and the milestone plan. Principle: **simple things, mastered.** A PS1-era fireball that reads instantly beats a sloppy particle storm.

---

## 1. Tech stack (v2: Godot)

| Layer | Choice | Why |
|---|---|---|
| Engine | **Godot 4.x** (GDScript; C# only if profiling demands it) | Jesse's pick. Free, exports to Windows/Mac/Linux/Web, runs headless for tests and AI play |
| Look | SubViewport at low internal resolution, nearest upscale, vertex-snap shader, dither, per-world fog | Late PS1 / early PS2 |
| Navigation | **NavigationServer3D** + a 1 m tactical grid (AStar3D) shown on combat start | Real 3D spaces with clean grid tactics |
| Dialogue | Lightweight Yarn-style runtime (or the Dialogic plugin) driven from text files | Plain-text authoring by humans and AI sessions |
| Data | YAML/JSON in `/data`, imported to Godot Resources | Diffable; parallel sessions can author content |
| Rules engine | Pure GDScript classes with **no scene-tree dependency** | Runs `godot --headless` for tests, balance sims, AI play |
| Tests | **GUT** for rules; headless scenario playthroughs in GitHub Actions | Every milestone gets an automated playthrough |
| Audio | AudioStreamPlayers + an interactive-music layer (explore / tension / combat stems) | Crossfades and stingers |
| Asset processing | **Blender** headless Python scripts | Decimate, bake, rig fixes, glTF export |

```
/project.godot
/engine   rules: combat, timeline, stats, AI, flags, save (no nodes)
/world    scenes, grid, triggers, director cameras
/render   retro post-process, VFX
/ui       menus, HUD, timeline, dialogue
/agent    DOTS API (local WebSocket + stdio), narrator log
/data     yaml + yarn + scenario specs
/assets   glb, textures, audio
/tools    blender scripts; tripo, fal, elevenlabs clients; dots-mcp
/docs     this bible
```

### 1.1 Services and keys
| Service | Used for | Access |
|---|---|---|
| **GitHub** | Repo, CI, builds | Jesse creates the repo; Claude pushes |
| **Tripo** | Text/image → 3D models, auto-rig, animation presets | `TRIPO_API_KEY` |
| **Fal.ai** | Concept art, textures, skyboxes, painted backdrops, portraits, UI art | `FAL_KEY` |
| **ElevenLabs** | Voice design + TTS, sound effects, optionally music | `ELEVENLABS_API_KEY` (Creator tier or above) |
| **Music** | Score | ElevenLabs Music via API (Claude iterates directly) + **Suno** for hero tracks (no public API: Jesse pastes prompts Claude writes) |
| Godot 4.x, Blender | Engine, asset processing | Installed by the cloud environment's setup script |

Keys live in the cloud environment's settings, never in chat or the repo.

## 2. Art direction

**Target:** between late PS1 (FFIX) and early PS2 (FFX). Chunky silhouettes, clear color identity per faction, painted skies, bold lighting.

### 2.1 Technical look
- Characters: **1,500–4,000 tris** (party/bosses up to 6k), **256–512 px** textures, hand-painted look, minimal normal maps.
- Environments: modular kits, 512 px tiling textures, **vertex-color lighting** baked plus a few dynamic lights for effects.
- Render at 640×480 / 854×480, nearest-neighbor upscale; optional ordered dither; distance fog per world; no anti-aliasing (deliberate).
- Faces: textured, with simple swap-texture expressions (eyes and mouth atlases), like PS1/early PS2. Masks spare us a lot of facial animation for Vors and Empire characters.

### 2.2 Faction palettes
| Faction | Palette | Shapes |
|---|---|---|
| Core | Magenta, cyan, chrome, sunset orange, black | Wedges, grids, rounded CRT corners, chrome trim |
| Srov | Sand, salt-white, ochre, ash-grey, gold flame | Curves, carved stone, cloth, spires |
| Vors | Black iron, crimson, bone, red-violet flame | Spires, cathedral arches, spikes, banners |
| Empire | Black, bone-white, verdigris, frost, sick green flame | Ossuary, candles, chains; the Emperor himself plain black, visor-slit, frost |

### 2.3 World looks
| World | Key image | Sky / fog | Signature hazard |
|---|---|---|---|
| *Galactic C* | Rounded 80s passenger liner interior, chrome and teal, emergency-red lighting | Burning atmosphere through the windows | Breached hull, sparking panels |
| Lumenhaven | Neon city-planet; rain-soaked Lowlight slums under holo-adverts | Magenta-black night | Neon power lines in rain |
| Ithrael | Srov temple carved into a salt cliff; humming resonance spires | Pale gold day, violet dusk | Salt vents (blind) |
| Lumenhaven | Neon megacity on orbital rings above a violet gas giant | Magenta-black night, perpetual | Neon power lines in rain |
| Calder | Stilt villages on black sea, glowing tide | Grey rain, cyan glow | Rising tide |
| Gallowmarket | Asteroid casino-station, disco-ball slave auction | Black space, gold and pink interiors | Collapsing stage rigs |
| Vesper | Forest of crystal trees, the crystal-grown wreck | Prismatic white | Shattering glass floors |
| Tal Vorrun | Mountain cathedrals in red lightning storms | Blood-red storm | Lightning rods |
| Hesper's Cinder | A cathedral wrapped around a dead star; caged Seers burning | Black, green gravefire | Gravefire rivers |

---

## 3. 3D models: the Tripo pipeline

1. **Concept sheet** (image model, or Tripo's own text-to-image): front/side/back turnaround, T-pose, on plain background, per the character's look notes in `02_CHARACTERS.md`. Ornate swords get their own sheet.
2. **Tripo image-to-3D** (or multiview-to-3D) → high-poly textured mesh.
3. **Tripo auto-rig** (humanoid) where possible; non-humanoids (K'saabu's frog proportions, Roxx, constructs) rigged in Blender via script, or Tripo's rig with manual fixes.
4. **Blender retro pass** (`tools/blender/retro.py`): decimate to tri budget, re-bake texture to 256/512 px, color-quantize lightly, set vertex colors, export **glTF (.glb)**.
5. **Animation:** humanoid library (idle, walk, run, combat idle, attack ×3, cast, hit, stagger, downed, revive, victory) from Tripo's animation presets or Mixamo-compatible retargeting; signature moves keyframed or adapted per character (Deena's quick-draw spin, K'saabu's underslung cannon brace, Ashe's overhead cleave, Roxx skating). **Target FFVII-and-better fidelity:** clear key poses, snappy timing, held anticipation frames.
6. **Swords:** modeled as separate props (so fittings swap visually); kindled flame is a shader on a slightly inflated copy of the blade mesh (§4).

**Asset budget (main story):** ~12 party/major characters, ~25 named NPCs, ~60 enemy families (with palette/prop variants), ~7 world kits, ~120 props.

---

## 4. VFX (simple, readable, mastered)

Toolkit: additive billboards, flipbook sprites (8–16 frames), ribbon trails, mesh-flash shells, screen flash, camera shake, a short hit-stop (2–4 frames), and color-coded light pulses. Every effect is readable in a still frame.

| Effect | Look |
|---|---|
| **Kindled blade (general)** | Inflated blade shell with scrolling noise, flicker, additive, crackle sprites at the edge; ribbon trail on swing |
| **Dawnfire** (Srov) | Gold-white core, soft glow, dust motes |
| **Wrathfire** (Vors) | Red-violet, ragged licking edges, ember sparks |
| **Starless white** (Akulsa) | Pure white, nearly no glow; it *dims* nearby lights (inverse light pulse) |
| **Gravefire** (Dust / Empire) | Black core with a sick-green rim, sparks fall *upward*; it pulls light in; faint whispering SFX |
| **Void Step** | A tear in the air (black slit with thread edges), afterimage silhouette |
| **Silk** (Melonsi) | Thin glowing lines between units, tension vibration when stressed |
| **Ricochet** (Deena) | Neon tracer lines with bright impact stars at each bounce |
| **Speakers** (Roxx) | Concentric rings pulsing to the track's BPM; color by track |
| **Masks** (Seraphine) | Porcelain shard burst on swap; decoys are pale, flickering copies |
| **Cannon / Shove** (K'saabu) | Fat green plasma ball, 3×3 shockwave ring, dust plume, camera shake |
| **Deflector** | Hexagonal shimmer dome; rounds that hit it bend back along their path with a bright ping |
| **Lightning / shock** | Jagged white-blue line with a single-frame flash |
| **Fire / burning** | Flipbook flames, orange; ember particles |
| **Heal** | Rising motes in the healer's color, soft chime |
| **Stagger / Poise break** | Glass-crack ring around the unit, hit-stop, bass hit |

Out of combat: rain, salt wind, neon flicker, tide glow, falling glass, ember storms, candle wax drip.

---

## 5. Music

### 5.1 The four sound worlds (prompt language, in our own terms)
Never name real composers or soundtracks in prompts. Use these descriptors:
- **EMPIRE "Dirge":** *"slow funeral dirge, 50 bpm, low male choir on sustained drone, tolling iron bells, sub-bass pulses, dark brass swells, long silences, phrygian minor, cathedral reverb, oppressive and ancient"*
- **SROV "Mirage":** *"wild mystical desert ritual, wordless soaring female vocals and deep throat singing, frame drums and hand percussion, breathy reed flute, vast wind-swept reverb, shifting odd meters, ecstatic and haunting"*
- **VORS "Dominion":** *"grand full symphony orchestra march, 104 bpm, martial snare and timpani, heavy low brass ostinato in minor, soaring horns, imperial and tyrannical, cinematic heroic villainy"*
- **CORE "Neon":** *"1980s synthwave, analog polysynths, arpeggiated bass, gated reverb drums, saxophone lead, retro-futurist neon city at night"* (variants: power ballad, italo-disco rink track, cop-show chase, lounge crooner, outrun racer)

### 5.2 Leitmotifs (the music tells the twist)
- **Dust's theme:** a simple four-note rising-falling figure. Act I: sung by Srov voices. Act II: a lonely synth. Act IV: Vors brass. Act V reveal: growled by the Empire choir. Epilogue: all four together.
- **Ashe's lullaby:** solo kythra (hand-harp) melody that is the **Vors march, slowed and gentled**. After the reveal, the full march and the lullaby are heard back to back.
- **Kultaka's theme:** Vors march with **Empire bells hidden under it**.
- **Galactic C theme:** a cheeky synthwave caper tune with sax; the crew's home.
- **Deena's theme:** bubbly synth-pop; slowed into a ballad for her romance.
- **Melonsi's theme:** Srov vocals over a plucked zither-like string line, regal and cold, warming over the game.
- **Emperor's theme:** almost no melody; a single sung low note with bells.

### 5.3 Cue list (first pass, ~45 tracks)
Opening: *Galactic C* (crew theme), *Under Fire* (orbital batteries), *Boarded* (tutorial battle), *Fast and Hard* (the glide and crash).
Ithrael (Act III): *Salt and Silence*, *The Hollow*, *The Kindling*, *Fire on the Choir*, *Ondine*.
Core: *Never Rewinds* (Lumenhaven), *Velvet Thunder* (ship), *Starlight Rink*, *B-Side* (undercity), *Founders' Gala*, *Muster* (anthem), *Keep the Lights On* (Dolly's death).
Calder: *Rain Sea*, *Merrow's Reach*, *The Quiet Graves*, *Choirmother*.
Gallowmarket: *Market of Chains*, *Jackpot Hymn*, *Velvet Jack's Last Set*.
Vesper: *Glasswood*, *The Last Hymn*, *Betrayal at the Glasswood*.
Tal Vorrun: *Dominion* (Vors march, full), *Hall of Oaths*, *The Hollow Crown* (reveal), *Turn the Fleet*.
Act V: *The Last Flotilla* (all four worlds), *The Pyre*, *Cardinal of Ash* (Kultaka final), *Voidreaper* (reveal), *Blood of My Blood* (final battle, three phases as stems), *Unmade*, *What We Carve*.
Battle: one standard battle theme per faction family (4), one boss theme per faction (4), victory fanfare (per faction flavor), game over.

### 5.4 Services
- **Score:** Suno or Udio (Jesse to pick; we may use both). Generate several takes per cue, select, loop-edit (Audacity/ffmpeg scripts), and export **stems where possible** for dynamic layering (explore → tension → combat).
- **SFX:** ElevenLabs Sound Effects, plus a small CC0 library for UI basics.
- **Loop points:** stored in `data/music.yaml`.

---

## 6. Voice (ElevenLabs)

### 6.1 Scope
- **Phase 1 (vertical slice):** fully voice the Opening (~90 lines plus K'saabu's croak library).
- **Phase 2:** all main-story cutscenes (~1,400 lines), combat barks per companion (~40 each), Roxx's broadcast barks (~120).
- Side quest dialogue stays text, with voiced first lines ("greeting barks").

### 6.2 Casting (voice design prompts)
| Character | Voice design |
|---|---|
| Dust | 19-year-old man, warm, quick, cocky charm, wry; drops low and steady when serious |
| Ashe | Gravelly, clipped commander's baritone; sounds 50 with a 25-year-old's energy; dry menace and charm |
| Deena | Young woman, bright, fast, melodramatic, sing-song when flirting, outraged otherwise |
| Melonsi | Young woman, precise, regal, unhurried, cool amused contempt that warms over time |
| Seraphine | Early 30s woman, low, velvety, amused, theatrical, precise diction |
| K'saabu | No words: a library of croaks, grunts, gulps and throat-sacs (ElevenLabs SFX + pitch layers); 3 intensities × 8 emotions |
| Roxx | Bubbly 80s radio-DJ woman, slightly synthetic (light vocoder; tape-slowdown effect when hurt) |
| Sable | Young woman, clipped, intense, porcelain-mask filter |
| Kultaka | Tall man's silky operatic baritone, theatrical, relishing every word; his four cantors as a choir layer |
| Emperor | **Deep bass with a tinny metallic ring**: pitch down, ring-modulate lightly, add a short metallic convolution (bell under water), very slow |
| Ondine | Elderly woman, soft, musical, utterly certain |
| Dolly Starling | Mid-50s talk-show host, warm, quick, showbiz polish |

### 6.3 Pipeline
Scripts in Yarn files → line IDs (`P_ASH_014`) → `tools/elevenlabs/render.ts` batch-generates per voice → post-process chain per character (ffmpeg filters) → normalize to −16 LUFS → `assets/vo/<id>.ogg`. Lip movement: simple mouth-flap by amplitude (PS1-appropriate).

---

## 7. Milestones

| # | Milestone | Contents | Playtest gate |
|---|---|---|---|
| M0 | **Bible** | This folder | Jesse sign-off on story and systems |
| M1 | **Engine core** | Rules engine headless: timeline, actions, positioning, doors, AI; agent API; 3 test arenas with placeholder boxes | Agent completes test arenas; unit tests green |
| M2 | **Vertical slice: Opening** | *Galactic C* boarding, three fights, glide and crash, first Lowlight street | Jesse plays; AI agent completes it on Seer |
| M3 | **Act I** | Lumenhaven, Melonsi, Roxx, Gala, blockade run | Same gates + difficulty survey |
| M4 | **Act II** | Three worlds, Imprints, Bind, Hunts, autoplay | Grinding fun test: 30 min of optional fights, rated |
| M5 | **Acts III–IV** | Ashfall, Tal Vorrun, reveal | Reveal lands? Clue audit |
| M6 | **Act V + endings** | Final battle, all endings, epilogue | Full playthrough timing (target 33–36 h) |
| M7 | **Polish** | Balance, VFX polish, music mix, bug burn-down | Full AI playthrough of main story |

**Parallelization:** once the Scenario Spec skill exists, separate Claude sessions can each own a world (scenario writing + encounter YAML + asset requests), with this bible as the shared source of truth and the reveal ledger as the hard constraint.

---

## 8. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Story drift during polish (Round 2's problem) | Canon locks + reveal ledger + Scenario Spec; any change to a locked fact needs Jesse |
| Scope (35 hours is a lot) | Vertical slice first; data-driven content; reuse kits; side content scales down without hurting the spine |
| Tripo models off-model or too dense | Concept sheets first; retro pass script; accept PS1 abstraction |
| Animation fidelity | Library first, then signature moves; masks reduce facial needs |
| Difficulty balance | Headless sim: run thousands of auto-battles per encounter with each composition to find dominant strategies before Jesse sees them |
| AI-play breakage | Agent acceptance test at every milestone |
