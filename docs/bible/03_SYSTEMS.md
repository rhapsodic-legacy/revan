# 03: SYSTEMS (v2: grid, party of 4, Search/Perception, Pass Turn, Deflectors, collateral)

> Gameplay pillars, in priority order:
> 1. **The battlefield is the place you walked into.** No transition to an arena. Doors, height, cover, hazards, and choke points are real, and the player can prepare the ground before a fight.
> 2. **Every character fights like who they are.** No two kits solve fights the same way.
> 3. **Hard, fair, readable.** Bosses demand mechanics, and enemies telegraph. Too easy is a worse failure than too hard.
> 4. **Grinding is a toy, not a tax.** Creativity is rewarded and repetition decays.
> 5. **Everything is legible as text,** so an AI (or a player who can't see well) can play it.

---

## 1. Camera, control, presentation

- **3D low-poly environments** (PS1-late / PS2-early fidelity) with **director cameras**: each area has authored camera zones (fixed angles, slow rails, gentle follow), FFVII/FFIX-style framing in full 3D. Painted skyboxes and matte backdrops give the "painted" feel.
- Exploration: direct control (keyboard/gamepad) or click-to-move. Party members follow in a loose trail.
- Combat camera: a tactical view (orbit, zoom, top-down toggle) plus cinematic cut-ins for big abilities (≤1.5s, skippable, auto-skipped at 2x speed).
- Internal render at 640×480 (or 854×480 widescreen), upscaled with nearest-neighbor. Vertex lighting, fog, optional dither. See `04_PRODUCTION.md`.

---

## 2. Exploration

### 2.1 What the player does out of combat
| Verb | Notes |
|---|---|
| **Move / interact / talk** | Standard. Interactables glow faintly on Seer Sight. |
| **Seer Sight** (toggle) | Dust's Weave view: monochrome world with luminous threads. Reveals hidden paths, enemy patrol routes, weak points in walls, trap triggers, eavesdroppable conversations, Imprint traces. Drains nothing, but enemies within 5 m sense it ("you feel watched"). |
| **Stealth** | Crouch-walk. Enemies have visible **vision cones** (cone length and angle per enemy; Seer Sight shows hearing radius). |
| **Stalk mode** | When enemies are unaware nearby, the player can pause and **reposition each party member individually** (a free planning layer). See §6.1. |
| **Party switching** | Control any member out of combat (some interactions are character-specific: K'saabu swims and lifts, Deena repairs and hotwires, Roxx jacks into terminals, Seraphine reads echoes, Melonsi reads Silk, Ashe/Akulsa opens Vors locks after the reveal). |
| **Codex and objectives** | Always explicit, written in text (AI-readable). |
| **Ship hub** | The *Velvet Thunder*: crew quarters, cockpit, galley (camp scenes), workbench (sword fittings), galaxy map. |

### 2.2 World structure
- Each world is a **hub** (town or district) plus **2–4 explorable zones** plus **1–2 dungeons**.
- Zones are interconnected; doors and lifts are real (closable, lockable, destructible).
- **Encounters are visible** (roaming packs, ambush groups, set-piece guards). No invisible random battles. Some ambushers are hidden until Seer Sight or Awareness reveals them.
- Respawn: roaming packs in non-dungeon zones respawn when the player rests on the ship or travels between worlds. Set-piece encounters don't respawn.

### 2.3 Social and skill checks
Dialogue options are gated by skills and by Path and influence. Failed checks are interesting rather than blocking (different outcome, never a dead end).

---

## 3. Stats and progression

### 3.1 Attributes (start 8–14, cap 30)
| Attribute | Governs |
|---|---|
| **Might** | Melee damage, Poise damage, carry |
| **Grace** | Accuracy, evasion, ranged damage, Speed (minor) |
| **Vigor** | HP, status resistance, Poise |
| **Perception** | **Search** results, crit chance, traps, spotting ambushes, Speed (minor) |
| **Resolve** | Focus pool, fear and charm resistance, Vigil and reaction count |
| **Eternity** | Seer ability power, Focus regen, kindled-sword damage |

### 3.2 Derived
- **HP** = 40 + Vigor×6 + Level×8
- **Focus** (Seer resource) = 10 + Resolve×1.5; regen 2/turn + Eternity/10
- **Poise** = 20 + Vigor×2 + armor Poise; when broken → **Staggered** (lose the next turn, take +50% damage until it ends)
- **Speed** (timeline) = 100 + Grace×1.5 + Perception×1 + gear
- **Move** = 6 m (+/- gear and status)
- **Defense / Ward**: physical and Eternity mitigation (percentage reduction, capped at 60%)

### 3.3 Levels
- Level cap 30 for the main story (≈ Prologue 1→3, Act I 3→8, Act II 8→17, Act III 17→20, Act IV 20→24, Act V 24→27). Postgame to 35.
- Per level: +3 attribute points (free), +1 talent point.
- XP from enemies **below the area's band decays sharply** (≥3 levels below: 10%). Grinding gives breadth (Imprints, Renown, gear), not runaway levels. This keeps boss fights hard.

### 3.4 Talents
Each character has **three talent trees** (about 12 nodes each), matched to personality. Example, Deena: *Quickdraw* (speed and first-strike shots), *Gadgeteer* (grenades, traps, repairs), *Spotter* (Search, Pass Turn, ally crits). Dust's trees are special (§3.5).

### 3.5 Dust: Weave trees and the Path
- **Serenity tree (Srov):** control, protection, unraveling (Unravel, Hold Thread, Quiet Mind).
- **Burn tree (Vors):** gravefire offense (Gravefire Brand, Black Bloom, Hunger).
- **Voidweaver tree:** locked; **one node unlocks per memory fragment** (Fragment 1: Void Step; 2: Gravefire Brand+; 3: Stitch; 4: Unweave; 5: Oathbreaker). *The story directly unlocks the gameplay.*
- **Path meter (−100 Serenity to +100 Burn):** moved by choices. Strong Path unlocks capstones (Serenity 60+: *The Quiet*; Burn 60+: *Black Sun*). Middle path gets *The Unwoven*, a hybrid capstone.

---

## 4. Out-of-combat skills (0–10)

| Skill | Used for |
|---|---|
| **Sway** | Persuade, charm, de-escalate (can end fights before they start) |
| **Menace** | Intimidate; enemies with low morale may flee or surrender |
| **Read** | Insight; detect lies, read intent, spot the Corroboration actors |
| **Rig** | Tech, hacking, traps, doors, explosives |
| **Shadow** | Stealth, lockpicking, pickpocketing |
| **Lore** | History, scripture, Vors and Srov ritual, Empire signs |

Party skill checks use **the best present member's skill + Dust's bonus**, so companion choice matters out of combat too.

---

## 5. Equipment

- **Slots:** Weapon, Armor, 2× Charm, Satchel (consumables; **max 4 types, 3 each**; no potion spam).
- **Swords are built, not looted.** Each Seer sword has four **fittings**: *Hilt* (accuracy/speed), *Guard* (defense/reaction), *Core* (flame damage type and power), *Ornament* (a passive). Fittings are found, bought, or crafted from Imprints. **Swords visibly change** (ornaments render on the model).
- **Kindling vs Gravesong (Dust):** the Kindling sword favors Serenity talents (+Focus regen, +control duration). Gravesong favors Burn (+gravefire damage, heals on kill, but −Ward). Player can switch at the workbench.
- Deena: pistol mods and gadgets. K'saabu: cannon shells (blast shapes, elements) and shield cells. Melonsi: silk tassels and hairpin charms. Roxx: tapes and plating. Seraphine: masks.

---

## 6. Combat: "Live Ground"

**Grid:** when a fight starts, a visible **1 m tactical grid** fades in over the real environment (sampled from the navmesh). Movement, reach, AoE, and pushes are counted in tiles. Out of combat the grid is hidden. Party size in combat: **4**.

### 6.1 Engagement
1. **Detection.** If an enemy sees or hears the party, combat begins where everyone stands. Units within the **battle radius (25 m)** join; others within 50 m may join later if they hear combat (noise rules, §6.5).
2. **Stalk (preparation).** If the party is unseen, the player can pause and enter **Stalk**: move each party member individually with stealth rules, use the environment (close doors, set traps, place Roxx's speakers, position K'saabu at a choke), and choose an **Opener**.
3. **Openers.** Whoever starts the fight with an Opener grants **Surprise**: the attacking side gets a full free round and the defenders begin **Off-Guard** (−25% Defense, no reactions, until their first turn). Openers: an ability from stealth, a thrown lure, a trap triggered, a door slammed, a ricochet shot from cover.
4. **Being ambushed.** Enemies can ambush the party too. An Awareness check (Perception + Read + Seer Sight on) can reduce it to a normal start.

**Lure play (the "door trick" is a feature):** lures (Pim's noisemakers, Roxx's speaker, Deena's ricochet ping, Dust's Weave tug) pull specific enemies away from their group. Enemies path to the noise. **Closing and locking a door** forces them to break it (doors have HP and lock ratings) or path around. It's intended and rewarded (Style Ledger, §9.2). Boss arenas are designed knowing players will try it: some bosses punish it (they burst through walls; they call reinforcements), some reward it.

### 6.2 The timeline (conditional turn order)
- A visible **timeline of the next 12 turns** (portraits). Turn order is from Speed with tick costs:
  - Base tick cost per turn = 1000 / Speed (normalized).
  - **Action weight** adds delay: Light (×0.8), Normal (×1.0), Heavy (×1.3), Ultimate (×1.6). Using a big ability pushes your next turn back, and the timeline previews it *before* you commit.
- **Dawnsight (Ashe in party):** enemy portraits on the timeline show their **intent icons** (attack/target, area, buff, move, flee). Without Ashe, only bosses telegraph heavy attacks. *Ashe in the party makes the game more readable; leaving him out is a real tradeoff.*
- **Delay / Hold:** end your turn early to act later in the round (keeps 25% of the tick).

### 6.3 A turn
On your turn: **Move** (up to Move m) **and one Action**, in either order, or **Dash** (2× Move, no action), or **Hold**.
- **Actions:** Attack, Ability (costs Focus or a personal resource), Item (from Satchel), Interact (door, lever, hazard, pick up), Shove (Might vs Poise), Overwatch (react to first enemy that moves in a cone), **Search**.
- **Search (any character, Light action):** rolls Perception against each hidden **Insight** placed in the encounter (a working door control, a loose power coupling, a gas line, a weak floor, a shield generator on an enemy's back). Success highlights it on the field with a one-line tip. Higher Perception finds more, and finds it first. Insights are authored per encounter; every hard fight has at least two.
- **Pass Turn (Deena; cooldown 3 rounds):** Deena gives her current turn to another ally, who acts immediately with a full turn. Because Deena is the fastest unit in the game, this is how a slow, heavy character (K'saabu) acts *before* the enemy does.
- **Reactions:** each unit has 1 reaction per round (+1 at Resolve 20). Used for **attacks of opportunity** (enemy leaves your melee reach), **Vigil**, **Overwatch**, **counters**.

### 6.4 Positioning rules
| Rule | Effect |
|---|---|
| **Facing** | Attacks from the **flank** +20% hit/+15% damage; from the **back** +40% hit/+30% damage and +crit. Units turn to face their last attacker. |
| **Height** | Higher ground: +15% hit, +10% damage, +2 m ranged reach. Falling from 4 m+ deals damage. |
| **Cover** | Half cover −25% ranged hit; full cover blocks line of sight. Computed by ray tests to the target's body points (head, chest, feet). |
| **Line of sight** | Required for most abilities. Some Seer gifts ignore it (Melonsi's Silk once linked; Seraphine's echoes). |
| **Zones of control** | Leaving an enemy's melee reach triggers their reaction attack. K'saabu's reach is 2 tiles. |
| **Flanking bonus** | Two allies on opposite sides of an enemy: both get +10% hit. |
| **Knockback** | Shove or heavy hits push units. Colliding with walls: Poise damage + HP damage. Into hazards: hazard effect. Off ledges: fall damage. |

### 6.5 Environment
- **Doors:** open/close (Interact), lock (Rig, or Ashe/Akulsa for Vors doors), bar (K'saabu), break (HP 40–400).
- **Hazards** (by world): salt vents (Ithrael: blind), neon power lines (Lumenhaven: shock chain through water), wax pools (Candlemouth: root), rising tide (Calder: drowns low units), glass floors (Vesper: shatter under heavy units or song), storm rods (Tal Vorrun: lightning strikes whoever stands near at round end), gravefire rivers (Pyre).
- **Destructibles:** cover crumbles; pillars fall (line damage); chandeliers drop.
- **Noise:** each action has a noise radius (sword clash 15 m, blaster 25 m, explosion 40 m, Roxx's track 30 m). Enemies in range but outside the fight may **join after 1–3 turns**. That makes speed, silence, and doors matter.
- **Light:** some areas have darkness; unlit units are harder to hit at range (−20%). Lights can be shot out.

### 6.6 Resources and status
- **HP, Focus, Poise** (all characters) + one **personal resource** each (§6.7).
- **Downed, not dead:** at 0 HP a party member is **Downed** for 3 of their turns; any ally can revive with an Interact (adjacent). If not revived, they're **Out** for the fight (wake after the battle at 1 HP with a lingering *Wounded* status until rest). Dust Out = game over (except scripted fights).
- **Statuses (kept small and readable):** Burning, Bleeding, Rooted, Blinded, Shocked, Staggered, Feared, Charmed, Silenced, Marked, Hasted, Slowed, Guarded, Regen, Off-Guard. Each has one icon, one color, a text tooltip, and a fixed duration.

### 6.7 Kits (personality ⇒ mechanics)

**Design rule (Jesse):** Dust and Ashe should **feel like heroes**: no glaring weakness, deadly, forgiving. Deena and K'saabu **need careful play**: one is fast and brittle, the other slow and indiscriminate. The contrast should be felt in the first two tutorial fights.

| Character | Personal resource | Signature tools | How they want to fight | Weakness |
|---|---|---|---|---|
| **Dust** | **Kindling** (0–5): gained by taking risks | Sword combos; Weave: **Push**, **Pull**, **Mend** (basic heal); later Void Step, Unravel, Stitch, Gravefire Brand | Flexible striker who repositions the field | None glaring; the strongest Weave arts are slow |
| **Ashe** | **Vigil** stacks (0–3) | Heavy sword arts, **Dawnsight** (enemy intents), **Vigil** (intercept), **Command** (ally gets an extra move, once per fight), Push, Mend. After the reveal: *Nightfall stance* (big AoE, costs HP) | Commander and executioner | None glaring until Nightfall, which hurts him |
| **Deena** | **Tricks** (gadgets per fight) | Very high Speed, best **Perception**, quick-draw shots, **Stun Grenade** (1 per fight), **Pass Turn**, field repair | Acts first; sets up the turn; finds the clever answer | Low HP and Poise; dies fast if focused |
| **K'saabu** | **Shield** charge | **Cannon** (every shot is AoE: 3×3 blast), **Personal Shield**, **Taunt**, **Shove** (pushes a normal-sized unit 2–3 tiles), fights from water tiles | Unleash him when nothing nearby can break or die | Slow; AoE hits civilians, allies, hostages, fragile objects; blocked by **Deflectors** |
| **Melonsi** | **Silk** links (max 2) | Link ally-ally (shared healing and damage) or enemy-enemy (shared damage and status), **Pull**, **Charm**, fast precise swordplay | Binds the field into combos | Fragile at range; links break past 8 tiles |
| **Roxx** (optional) | **Tracks** (up to 2 speakers) | Hype, Slow Jam, Feedback, Power Ballad; positional auras that affect everyone in range | Area control by placement | Speakers destructible; Feedback hits allies' Focus |
| **Seraphine** | **Mask** (one active) | Grief (drain), Mirth (decoys), Wrath (burst), Silence (stealth and interrupt) | Changes role every turn | Fragile; punished if caught |

### 6.7a Shields, Deflectors, collateral
- **Personal Shield:** absorbs X damage, then breaks (it shows as a bar over HP).
- **Deflector** (Sergeants, Vors officers, some bosses): **reflects AoE and ranged rounds aimed into its radius (2 tiles) back at the shooter.** While a Deflector is up, K'saabu's cannon is useless or suicidal near it. Answers: melee it down, Shove the carrier away from his squad, cut him off behind a door, or Search for the generator and shoot it.
- **Collateral:** fights can contain **civilians, hostages, exposed allies, and fragile objects** (consoles, fuel cells, reactor glass, evidence). AoE hits them. Civilians can be moved: Interact ("Get down! Move!") or Shove. Some encounters fail or lose rewards if collateral is destroyed. This makes K'saabu a decision, not a button.

**Variety test (must pass in playtests):** for any given encounter, at least **three different party compositions** should have a distinct, viable winning plan.

### 6.8 Bond (Dust & Ashe)
Set by the Act IV reckoning: **Trust / Wary / Broken**. In the final battle:
- **Trust:** Vigil on Dust is free (no reaction cost), and Akulsa can be Stitched by Dust without consent checks.
- **Wary:** normal rules.
- **Broken:** Akulsa won't take Dust's Stitch, but deals +20% damage (he fights like he did in the Hundred Days).

### 6.9 Enemy AI
Each enemy has a **role** (Brute, Skirmisher, Marksman, Caster, Support, Leader, Summoner) and a **temperament**:
- **Disciplined (Vors):** formation (shield-wall, firing lines), retreat to choke points, protect the Leader, use doors themselves.
- **Fanatic (Candlemouths):** suicide charges, self-sacrifice to empower others, ignore morale.
- **Opportunist (Core thugs, mercs):** focus the weakest, flee at 30% group HP, surrender to Menace.
- **Predatory (wildlife):** flank, pull isolated targets, flee when their leader dies.
- **Construct:** predictable patterns, heavy telegraphs.

**AI uses the same rules as the player** (doors, height, cover, flanking). Utility scoring per action: damage expected, kill chance, threat to own allies, positioning value, role bias. A **difficulty knob** controls how often the AI picks its best-scored action (Story 60%, Seer 85%, Vors 100% plus coordinated focus fire).

---

## 7. Difficulty

- **Modes:** *Story* (fights are softened; for narrative), **Seer (intended)**, *Vors* (hard: smarter AI, +25% enemy HP, bosses gain a mechanic).
- **Level bands:** each area has a band (e.g., Act II worlds: first chosen 8–11, second 11–14, third 14–17). Enemy level = max(band min, min(band max, party avg)). Bosses always sit at the **top of their band + 1**.
- **Curve rules:**
  - Normal fights: winnable with sensible positioning; punishing to "stand in a line and attack."
  - Mini-bosses: one gimmick that must be answered.
  - **Story bosses:** two or three phases, a mechanic you can't ignore, a mid-fight change. **Target first-attempt failure rate on Seer: 30–50%.** No boss fight should be won by repeating one ability.
  - No consumable spam (Satchel limit). No full heals mid-boss except via kits.
- **Retry kindness:** instant retry from the start of the fight, or **from the last phase transition** for bosses. The game tells you *what killed you* in plain text ("Kultaka's Censer Sweep hit 3 allies standing within 4 m of the altar").

---

## 8. Bosses

### 8.1 Design template
Each boss spec lists: arena map (doors, heights, hazards), phases with HP thresholds, signature mechanic, telegraphs, what the door/lure trick does in this arena, intended solutions per composition (≥3), and Vors-mode extra.

### 8.2 Example: The Choirmother (Calder)
- **Arena:** a drowned chapel with three levels; the tide cycles every 3 rounds (low → mid → high). At high tide, ground level is underwater (units there take Drowning damage and are Slowed).
- **Phase 1 (100–60%):** Choirmother sings from the altar (mid-level). Drowned Acolytes climb from the water. *Mechanic:* **Undertow:** she marks a unit, and next round it's dragged 6 m toward the nearest water.
- **Phase 2 (60–25%):** she dives. Attacks from the water; can only be hit when she surfaces (telegraphed by bubbles). K'saabu can follow her into the water and fight her there.
- **Phase 3 (<25%):** she calls K'saabu by his slave-name. K'saabu is Feared unless his influence is high. She tries to drown the whole chapel (tide locked high for 3 rounds): reach the bell tower or break the sluice gates (Rig) to drain it.
- **Door trick:** sluice doors can be closed to stop the acolytes coming from the deep cells, but closing them makes phase 3's flood unstoppable unless reopened. A tradeoff, not an exploit.

### 8.3 Example: Kultaka (Act III, the Dome)
- Three tiers of balconies. Cantors (4) sing; while any cantor lives, Kultaka gains **Choir** stacks (+10% damage each).
- **Censer Sweep:** a 270° swing, 4 m radius, leaves incense (Blind) clouds.
- At 30%: **Communion**: he drains all living cantors to heal 40%. Kill cantors before 30% or burst him through the threshold. Seraphine's Silence can interrupt Communion once.

### 8.4 THE FINAL BATTLE: Dust & Akulsa vs Kultaka & the Emperor
- **Arena:** the Hall of the Wick, a circular star-cathedral floating in the dead star's heart. Outer ring (walkway), inner ring (altars), central pit (gravefire). Sections of the outer ring collapse through the fight.
- **Party:** Dust and Akulsa only (scripted). If Melonsi is with the crew and Bond = Trust, her Silk is present as a **support layer** (one link, off-field).
- **Phase 1 (2v2):** Kultaka (aggressive melee, cantorless now, gains Choir stacks from Seer cages still burning: free them in V-2 to weaken him). The Emperor (slow, devastating, one action per two Kultaka turns; **Reap**: line attack across the hall; **Claim**: marks a unit, and if it's hit again before its next turn it loses Focus to him). Akulsa's Dawnsight shows both intents.
- **Phase 2 "Forever" (Kultaka <50%):** cutscene; the Emperor absorbs him. Emperor gains Kultaka's Censer Sweep and acts every turn. The outer ring begins collapsing (one section per round, telegraphed).
- **Phase 3 "Blood" (Emperor <40%):** the black mask cracks along its visor slit; the Emperor becomes **Undying** except to gravefire (only Dust's gravefire abilities and Gravesong/Kindling kindled strikes deal damage). The Emperor targets Dust relentlessly. Akulsa's job: Vigil, Sunwall, Riposte. **Unmake** (Dust ultimate) unlocks at Emperor <10%.
- **Scripted end:** the Emperor's last Reap goes for Dust; Akulsa's Vigil triggers. In the Hidden ending, if Akulsa has 3 Vigil stacks and Melonsi's Silk links them, the damage splits and Akulsa survives.
- **Target length:** 25–35 minutes on Seer. Retry from phase start.

---

## 9. Grinding that's interesting

The goal: fighting normal enemies should feel like **practicing a craft**. Three systems work together.

### 9.1 Imprints (learning from enemies)
- When an enemy is **finished by a Seer's ability**, that Seer reads its Eternity and gains an **Imprint** of that enemy family.
- At Srov shrines, Vors altars, or the ship's meditation room, spend Imprints to learn **techniques**. **Each character learns something different from the same family**, filtered through who they are. Example, *Salt Wraiths* (Ithrael):
  - Dust: *Unseen Step* (Void Step leaves an afterimage that draws one attack)
  - Ashe: *Mirage Guard* (Vigil also grants evasion)
  - Melonsi: *Wisp Silk* (links ignore line of sight)
  - Seraphine: *Hollow Mask* (Mirth decoys explode on death)
- About **60 enemy families × 3–4 characters** = ~200 techniques. Some techniques are combo-enablers for other characters.

### 9.2 The Style Ledger (anti-one-trick)
Every win is scored for **Renown** (currency for talents, fitting crafting, and Hunt access) based on **how** you won:
| Style | Example |
|---|---|
| Ambush | Fight started with Surprise |
| Terrain | Kill by knockback, fall, hazard, collapsing pillar |
| Door | Enemy separated or delayed by a door |
| Combo | Thread + Stitch + ricochet in one round |
| Clean | No damage taken |
| Swift | Won under par rounds |
| Underdog | Won against a higher band |
| Mercy | Enemy surrendered (Menace/Sway) |

**Novelty decay:** each Style's value decays every time it's used in a row (100% → 70% → 50% → 30%) and recovers when you use others. The fastest way to grind is to **vary your tactics**, which is how we beat the one-trick problem without banning anything.

### 9.3 Gathering: "Bait and Bind"
- Dust's Weave can **Bind** visible roaming packs (up to 4 in a zone). Bound packs vanish into the Weave and follow him as faint shadow-threads.
- At any time, Dust can **Release** them all at once, in a place of his choosing. One big battle, with every bound pack arriving from the directions of the threads (shown in advance). The player picks the ground: a corridor with a door, a cliff edge for K'saabu's shoves, a pool of water for Roxx's shock tracks.
- Rewards scale with the number of packs released together (×1.0, ×1.4, ×1.9, ×2.5), plus a **Gathering Imprint** bonus.
- This turns grinding into **designing a killbox**: prep the ground, choose the comp, release the storm. It's the most fun way to farm, and also the most dangerous.

### 9.4 Hunts
- Hunt boards on every hub world (Srov shrines, Vors notice-spires, Core bounty terminals in neon).
- **Echo Hunts:** elite variants with one unique mechanic (a Salt Wraith that copies your last ability; a Vors Captain who closes doors on you).
- Rewards: unique fittings, masks, tapes, engravings.
- **The Hollow Deeps** (postgame): a boss-echo gauntlet in Ithrael's cave.

---

## 10. Autoplay

Autoplay is a first-class feature, not a cheat.

### 10.1 Standing Orders
- Each character has an editable **priority list** of rules (condition → action), FFXII-style, but **pre-filled with a preset that matches their personality**:
  - Dust: *Mend an ally below 40%* → *flank and strike the hardest-hitting enemy* → *Push an enemy into a hazard*
  - Ashe: *Vigil on Dust if Dust < 60% HP* → *strike the highest-damage enemy* → *Command the slowest ally*
  - Deena: *Search on round 1* → *Pass Turn to K'saabu if 3+ enemies cluster with no collateral or Deflector* → *shoot the lowest-HP enemy*
  - K'saabu: *Taunt if Deena is targeted* → *Cannon a cluster of 3+ (never near collateral or a Deflector)* → *Shield up*
  - Melonsi: *Silk two adjacent enemies* → *Charm the strongest enemy* → *Pull a marksman out of cover*
- Conditions/actions are picked from menus (no scripting needed). Rule slots unlock with level.

### 10.2 Controls
- **Auto** toggle (per fight or persistent), speed **1× / 2× / 4×**, with instant takeover (any key).
- **Auto-Hunt** (out of combat, in non-dungeon zones): the party roams, engages visible packs, auto-fights, loots, and repeats. **Stop conditions:** party HP below X%, Satchel item below N, rare spawn spotted, Imprint target reached, level reached, time limit.
- Autoplay **never** uses Stalk, Bind, or doors (it's competent, not creative), so manual play stays more rewarding for Renown.
- Boss fights can be auto-played on Story mode only.

---

## 11. AI-playability (the "Pokémon Red" hook)

The game exposes a complete, stable, text-first interface so an AI agent can play it. Design rules:
1. **Deterministic:** seeded RNG, fixed timestep. Same seed + same inputs = same game.
2. **Turn-based everywhere it matters.** No reflex tests. Exploration has a "travel to" command.
3. **Every visual cue has a text equivalent.** The UI text is the ground truth.

### 11.1 The Agent API
Available in the browser as `window.DOTS` and in a headless Node runner (`npm run agent`):

```ts
DOTS.getState(): {
  mode: "explore" | "dialogue" | "combat" | "menu" | "cutscene",
  scene: { id, name, objective, exits: Exit[], pointsOfInterest: POI[] },
  party: Unit[],            // hp, focus, poise, resources, statuses, position, facing
  enemies?: Unit[],         // visible only; intents if Dawnsight
  timeline?: TurnEntry[],   // next 12
  dialogue?: { speaker, line, options: { id, text, check? }[] },
  legalActions: Action[],   // every legal action, with ids and previews
  log: string[]             // last N narrator lines
}
DOTS.act(actionId: string, params?: object): Result   // returns the new state + log delta
DOTS.travelTo(poiId: string): Result                  // pathfinds in explore mode
DOTS.save(slot) / DOTS.load(slot) / DOTS.seed(n)
DOTS.describeMap(): string                             // ASCII top-down of current combat grid
```

### 11.2 Narrator log
A plain-English event stream: *"Deena ricochets a shot off the pillar and hits the Vors Marksman in the back for 34 (critical). The Marksman is Staggered."* It's also shown in-game as an optional battle log.

### 11.3 MCP wrapper
A small MCP server (`tools/dots-mcp`) exposes `get_state`, `act`, `travel_to`, `save`, `load`, so any MCP-capable AI can play directly. Ship a one-page `AGENT_GUIDE.md` that explains the game's rules to an AI player.

### 11.4 Acceptance test
An AI agent (Claude, via the MCP wrapper) must be able to complete the Opening and Act I's first hub on Seer difficulty with no human help. This test runs at every milestone.

---

## 12. Flags, saves, data

- **Save:** autosave on area change and before bosses; 20 manual slots; export/import save as a file. Saves are JSON.
- **Flag registry:** every story flag lives in `data/flags.yaml` with a description and the scene that sets it. Naming: `act.scene.fact` (e.g., `p.kindling.flame_seen`, `a2.calder.fenn_choice = truth|silence|supper`, `a3.hushword = refused|spoken`, `a4.bond = trust|wary|broken`).
- **Influence:** per companion, −100..100; changes are logged with reasons (visible in a debug panel and to the AI API).
- **Data-driven content:** dialogue in Yarn-style `.yarn` files; encounters, enemies, abilities, items in YAML; scenarios in the Scenario Spec format (see `05_OPENING_SCENARIO.md`).
