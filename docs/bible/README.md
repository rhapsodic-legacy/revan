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
| `07_CONCEPT_ART_PROMPTS.md` | Image-generator prompts for concept art and Tripo turnarounds | Making concept art |

---

## 1. The north star

**What story are we telling?**
A young man who has been given a kind, false life discovers, piece by piece, that he was once the right hand of a conqueror, then that the gentle mentor at his side *is* that conqueror, and finally that the conqueror stole him as a baby from the one being in the universe more terrible than either of them: his father.

**The theme, in one line:** *What we forget can still find us, and what we choose is what we become.*

Every faction is built on this theme:
- **The Srov** erase memory as a sacred act. They believe a god that is forgotten starves. They wiped Dust out of mercy, and the mercy was also a lie.
- **The Vors** remember everything and burn for it.
- **The Immortal Empire** never forgets and never dies, and that is the horror of it.
- **The Core** (the neon-lit majority) lives in an endless present of music, arcades, and chrome. They forgot how to fight, and a hundred of their worlds fell in a hundred days.

**The emotional shape:** warmth (Act I) → dread and grief (Act II) → loss (Act III) → betrayal and revelation (Act IV) → terrible truth, sacrifice, and choice (Act V).

**Tone:** larger-than-life space opera. Villains monologue. Swords blaze. Fleets are cathedrals. People are funny when they are frightened. Nobody is beige.

---

## 2. Canon locks (do not change without Jesse)

These are Jesse's core ideas. Everything else in the bible serves them.

1. The player is **Tyranus**, apprentice of **Vors Akulsa**, memory-wiped by the Srov and renamed **Dust of the Sun** ("Dust"). **Dust is 19**; he woke in the Srov temple medbay at 7, left the Srov with Ashe at 14, and has been a mercenary since.
2. Dust's false past: village burned, parents killed, sold to slavers, freed by the Srov, a cave-in during his trial and a rock to the head. **All of it was fabricated by the Srov.**
3. The player is led to believe they are **Vors Akulsa** (via the interrupted Succession rite: Dust carries Akulsa's memories). They are not.
4. **Vors Kultaka** (spelling confirmed) betrayed Akulsa 12 years ago. The Srov boarded his flagship and captured and wiped Akulsa and his apprentice. Everyone believes Akulsa is dead. Rogue Vors fleets (with scores of Juggernaut-class battlecruisers) still roam and hide; the Srov hunt them and beg worlds for battleships.
5. **Ashe Dawnbringer** is Vors Akulsa: a ruthless, charismatic ex-military mercenary who says he's in his early fifties and looks 25, put on "indefinite sabbatical" by the Srov five years ago. **Kultaka reveals it in Act IV.**
6. Kultaka is the apprentice of **Emperor Voidreaper** (a quiet terror: black armour, black cape, a black mask with a horizontal visor slit and white pinprick eyes) of the **Immortal Empire** (dark gods, human sacrifice, believed dead, a belief the Srov enforce), who promises him immortality and the millions of galaxies beyond.
7. Akulsa built his armada to face the Emperor, who is as strong in **Eternity** as Akulsa, or stronger.
8. Final act: Kultaka beaten, the trap springs, the Emperor reveals **he is Tyranus's father**, Akulsa admits stealing him to raise a weapon, the Emperor offers his hand, Kultaka gloats.
9. **Final battle: 2v2, Dust and Ashe vs Kultaka and the Emperor.**
10. **Four musical/visual identities:** Empire dirge, Srov wild mystical vocals, Vors grand orchestral march, everyone else 70s–80s synthwave (also architecture and ships).
11. **No lightsabers:** ornate swords, each reflecting its wielder, telepathically kindled in crackling energy. Eternity users are **Seers**, each gift unique.
12. "A hundred worlds fell in less than a hundred days."
13. **The starting crew (Jesse's):** Dust, Ashe, **Deena Ateray**, **K'saabu**, aboard the ***Galactic C*** ("Galactic C~~ompanion~~hampion"). **Princess Melonsi Ananna** of Seonha joins in Act I.
14. **Act I (Jesse's):** the Srov send the crew to find Melonsi, missing on a Unity core world after her party was betrayed from within and ambushed.
15. **The Opening (Jesse's):** under fire, boarded, EMP, glide, three tutorial fights (Search, Pass Turn, Deflector, the door play), crash into a warehouse.
16. **Engine: Godot.** Combat is turn-based and grid-based, in the real environment.

### Originality guardrails
Broad genre strokes are fine (a hidden-identity twist, a princess to find, a fallen order, a betrayer, a dark father). Specifics stay ours:
- Don't copy specific planets, characters, set pieces, or beat-by-beat plot from existing Star Wars games or films, even renamed.
- Don't quote famous film lines verbatim. The father reveal is written in our own words (see `01_STORY.md`, Act V).
- Music prompts describe sound in our own terms. Never prompt with real composers' or soundtracks' names.

---

## 3. The reveal ledger

The story is built on three nested reveals. To keep it cohesive through polishing, **every scene must respect this ledger**. If a scene would let the player learn something earlier than listed, it's a bug.

| Truth | Player suspects | Player learns | Who reveals it |
|---|---|---|---|
| Dust's past is false | Opening/Act I (hazy memories) | Act II (Calder: the village never burned) | Marta Fenn, by not recognizing him |
| Dust was Akulsa's child-apprentice, Tyranus | Act I (Kultaka knows him) | Act III (Ondine's dying words) | Ondine Saar |
| Dust carries Akulsa's memories (Succession) | Act I (first fragment) | Act II (the Unbowed kneel) | Castellan Hesk, Seraphine |
| **Misdirect:** Dust is Akulsa reborn | Act I → Act IV (deliberately encouraged) | Exploded in Act IV | Kultaka |
| Ashe is Akulsa | Only on replay or by sharp players | Act IV (Throne Hall) | Kultaka, then Ashe himself |
| The Immortal Empire is real and coming | Act I (Candlemouth cult) | Act IV (Ashe tells what he knows) | Ashe |
| The Emperor is Dust's father | Never, but clued fairly | Act V | The Emperor; Ashe confirms |
| Only the Emperor's own blood can kill him | Never | Act V, final phase | Ashe (dying) |

### Fair-play clues (plant every one of them; they make the replay sing)
1. **Dust's flame is sooty gold with a black heart** (Ashe forbids kindling it in public); at full strength in Act III it burns pure black (gravefire). Srov flame is gold, Vors flame is red-violet. Nobody has seen black. Act V: the Emperor's sword burns the same black.
2. **The Hollow (cave trial):** Dust fights a figure in black armour and a **black visor-mask with two white pinprick eyes**, with frost spreading around it. He cracks the mask and sees his own face. Players read it as "the darkness is me." Act V: it's the Emperor's mask, and the Emperor reminds him of the cave.
3. **Ashe looks 25 and says he's 52** (strong Seers barely age; so does the Emperor). **Ashe's sword Morningwake** is white enamel with a gold sunburst. One chip shows **black lacquer beneath**. It is Akulsa's sword *Nightfall*, repainted.
4. **Ashe's harp lullaby** is the Vors march, slowed down and played gently. Players who know the march theme can hear it.
5. **The memory fragments are in Akulsa's own first-person voice**, which is Ashe's actor heavily mask-filtered. On replay it's recognizable.
6. **Vors Succession lore** ("a Vors does not die; he passes into the heir") gives players the wrong answer to "why do I remember being him?"
7. **Ondine's dying words:** "Forgive me... and forgive *him*." She is looking at Ashe. Players assume she means herself.
8. **The Candlemouth scripture** speaks of "the Son Who Was Carried Into Snow." The Tal Vorrun throne-vision shows a child carried through snow by a masked man.
9. **Ashe flinches from the Vors throne** and from Kultaka's oath-song before he knows why.
10. **Dust's temple scar** is round and surgical, not a rock wound. Melonsi notices that it's "too neat."
11. **Kultaka's leitmotif** is the Vors march with Empire dirge bells hidden under it. His double allegiance is audible.
12. **Dust's leitmotif** (four notes) is sung by Srov voices in Act I, played by Vors brass in Act IV, and growled by the Empire choir in the reveal.

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
| Story outline, all acts | v2 (Jesse's crew and Act I folded in) |
| Characters and arcs | v2 |
| Systems design | v2 (grid, Search, Pass Turn, Deflectors, collateral) |
| Production plan | v2 (Godot, services and keys) |
| Opening scenario + storyboard | Penned v2; refinements R1–R6 awaiting Jesse |
| Concept-art prompts | v1 |
| Act I scenario | Not started |
| Engine | Not started (repo: github.com/rhapsodic-legacy/revan) |

### Open questions for Jesse
- Accept refinements R1–R6 in `05_OPENING_SCENARIO.md` §13?
- The Succession fix for Dust being 19 (§3 of `01_STORY.md`): OK?
- API keys in the cloud environment: Tripo, Fal.ai, ElevenLabs; music service choice.
