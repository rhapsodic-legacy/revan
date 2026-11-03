# DUST OF THE SUN: Design Bible (Round 3, v2)

> Working title: **Dust of the Sun** (subtitle option: *Voidweaver*).
> A space-opera RPG with turn-based tactical combat in real environments. Target main story: **33–36 hours**.

This folder is the **long-horizon memory** for the project. Any session (human or AI) that picks the work up after a context reset reads this file first, then the file for whatever it's working on.

| File | What it holds | When to read it |
|---|---|---|
| `README.md` | North star, canon locks, reveal ledger, how to use the bible | Always, first |
| `01_STORY.md` | World, factions, true history, full main story by act, endings | Writing any scene, quest, or dialogue |
| `02_CHARACTERS.md` | Player, companions, romances, betrayals, villains, side cast, side quests | Writing any character or relationship content |
| `03_SYSTEMS.md` | Exploration, stats, skills, combat, enemies, difficulty, grinding, autoplay, AI-play API | Building or tuning gameplay |
| `04_PRODUCTION.md` | Art direction, models (Tripo), VFX, music, voice (ElevenLabs), tech stack, milestones | Making assets, building the engine |
| `05_OPENING_SCENARIO.md` | The penned Opening ("Fast and Hard"), in the reusable **Scenario Spec** format, plus refinements R1–R6 | Building the vertical slice; authoring any later scenario |
| `06_STORYBOARD_OPENING.md` | Shot-by-shot storyboard of the Opening | Cutscenes, cameras, audio timing |
| `08_CREW_CANDIDATES.md` | Approved crew (Hal, Varga, Seraphine, Teodric, the Ledger, Countess Viviana, world-tied crew), Hal's "Cogito ergo sum" scene, races, classes, ship upgrades | Act III planning |
| `07_CONCEPT_ART_PROMPTS.md` | Image-generator prompts for concept art and Tripo turnarounds | Making concept art |

---

## 1. The north star

**The story (Jesse's):** a cocky, good-hearted young mercenary and his ruthless, ageless mentor are dragged back to the Srov, survive the Srov's cruel trials by Dust's wits, and set out to find who is rebuilding the Vors. Along the way the galaxy notices them, a second invasion comes, Ashe is revealed as Vors Akulsa, and in the Unknown Regions Dust learns he is Emperor Voidreaper's son. In the end Ashe anoints Kultaka as the last Vors, Akulsa is declared gone, and Dust becomes Emperor of the Immortal Empire.

**The theme (Jesse's):** right and wrong, light and dark, are not always easy to tell apart. Darkness can grow in any person; it doesn't need to wield a sword.

**Tone:** larger-than-life space opera. Villains monologue. Swords blaze. People are funny when they're frightened. Nobody is beige.

---

## 2. Canon locks (Jesse's; do not change without him)

1. The player is **Dust of the Sun** ("Dust"), 19, really **Tyranus**, Vors Akulsa's very young apprentice when Kultaka betrayed Akulsa 12 years ago. The Srov memory-wiped him and gave him a false past (village burned, slavers, freed by the Srov, cave-in during a trial). He woke in a Srov medbay at 7, and left with Ashe at 14.
2. **Ashe Dawnbringer** is **Vors Akulsa**: ruthless, charismatic, Machiavellian ex-military; says he's in his early fifties and looks 25. The reveal comes in **Act VI**.
3. **Dust doesn't have flashbacks.** No memory-transfer rite. The Srov don't erase memories as doctrine, and the Vors don't covet memories.
4. **Kultaka** betrayed Akulsa; he's the Emperor's apprentice; he's brutish, not cunning. He survives: beaten too easily in Act VI, he flees (a trap), and in the epilogue Ashe anoints him Supreme Being of the Vors.
5. **Emperor Voidreaper** of the **Immortal Empire** (dark gods, human sacrifice, believed dead, a belief the Srov enforce) is the cunning Dark Seer behind events, and **Dust's father**. He's a quiet terror: black armour, black cape, a black mask with a horizontal visor slit and white pinprick eyes.
6. Akulsa built his Armada to face the Emperor. "A hundred worlds fell in less than a hundred days."
7. **Final battle:** Akulsa and Tyranus vs Kultaka and the Emperor, on a space station of concentric rings in the Unknown Regions.
8. **Epilogue:** Akulsa declared gone; Kultaka anointed; Dust made Emperor; Ashe's voice-over explains why.
9. **The crew:** Dust, Ashe, Deena Ateray, K'saabu, aboard the *Galactic C*. **Princess Melonsi Ananna** (a Srov Seer; deliberately the one sexualised woman in the cast; easy to hate, easy to lust after) joins in Act II by Vasili's order.
10. **Seven acts:** I Rescue · II Trials · III World to World · IV Noticed · V Second Invasion · VI Grand Ball · VII Snake's Head (see `01_STORY.md`).
11. **Four sounds and looks:** Empire dirge; Srov wild mystical vocals; Vors grand orchestral march; everyone else 70s–80s synthwave and neonpunk.
12. **No lightsabers:** ornate swords, telepathically ignited. Eternity users are **Seers**, each gift unique.
13. **The Galactic Unity** is autocratic, corrupt and bureaucratic; its forces speak in an Elizabethan register.
14. **Engine: Godot.** Combat is turn-based and grid-based, in the real environment.

### Working rules
- **Jesse writes the plot.** Don't invent plot devices, lore or story mechanisms. Where there's a gap, list it as a question for Jesse.
- KotOR is broad-shape inspiration. Specific worlds, characters and set pieces are our own, and famous film lines aren't quoted.
- Music prompts describe sound in our own terms, never naming real composers or soundtracks.

---

## 3. Reveal ledger

| Truth | Revealed | By whom |
|---|---|---|
| The Immortal Empire is real | Act VI | Ashe (no specifics) |
| Ashe is Vors Akulsa | Act VI (the Grand Ball) | Kultaka |
| The Dark Seer behind events is the Emperor, not Kultaka | Act VII | The Emperor |
| The Emperor is Dust's father | Act VII | The Emperor; Akulsa confirms |

Clues (cheap now, pay off later): Ashe's agelessness; the black lacquer under the chipped white enamel of his sword; Dust's sword flame having a dark core, and Ashe forbidding him to ignite it in public; Dust's "terrible darkness" he can't explain.

---

## 4. How to work from this bible (long-horizon protocol)

1. **Story first, then systems, then assets.** No asset gets made for a scene that isn't penned in `01_STORY.md`.
2. **Every scenario is written in the Scenario Spec format** (see `05_OPENING_SCENARIO.md` §0). That format is designed to become a reusable skill, so parallel instances of Claude can author Acts I–V consistently.
3. **Before writing a scene:** check the reveal ledger, the canon locks, and the speaker's voice notes in `02_CHARACTERS.md`.
4. **After writing a scene:** update the *Status* table below and any flags added to the flag registry in `03_SYSTEMS.md` §12.
5. **Playtest gates:** each milestone ends with Jesse playing it and an AI agent playing it through the AI harness (`03_SYSTEMS.md` §11).

### Status
| Piece | State |
|---|---|
| Story outline, all acts | v3: Jesse's seven-act plot; gaps listed as questions |
| Characters and arcs | v3 for Jesse's cast; later crew approved in 08 (2026-11-03) |
| Systems design | v2 (grid, Search, Pass Turn, Deflectors, collateral) |
| Production plan | v2 (Godot, services and keys) |
| Opening scenario + storyboard | Penned; refinements R1–R5 accepted |
| Concept-art prompts | v1 |
| Act I scenario | Not started |
| Engine | M1 engine core built: headless rules, AI, agent API, 3 test arenas (repo: github.com/rhapsodic-legacy/revan, branch engine-core) |

### Open questions for Jesse
See `01_STORY.md` §12.
