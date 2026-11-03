# 05: OPENING SCENARIO: "Fast and Hard" (v2, Jesse's opening)

> Two parts:
> - **§0 Scenario Spec format**: the reusable structure every scenario is written in. Once polished, §0 becomes a **skill**.
> - **§1–§12 the Opening**, from Jesse's outline, penned in that format. My refinements are marked **[R#]** and listed in §13 for Jesse to accept or reject.

---

> **Jesse's changes, 2026-11-03 09:26 (verbatim; these override the script below until it's rewritten):**
>
> Where is Statda in the opening scene? During the initial conversation, she runs by and tells Ashe "Hey Cap', some craft is closing with us and planetary ass hats are firing at them... don't you guys hear the explosions?" (Statda mistakes the planetary defence fire as being aimed at the pirates).
> "The orbital defence guns aren't aimed at us, and dumb ass pirates trying to board us this close to a planet aren't something I'm worried about. They'll bounce off our shields." Ashe replies.
> "I'm always grateful you're the captain, cap'." Statda says sarcastically, and runs towards the cockpit.
> "What does she want us to do, knock the pirates out of the sky? Let the planet defence guns do that." Dust says to Ashe.
> "I heard that you wiener!" Statda yells from out of sight.
> (Ashe returns to the conversation, not even considering what Statda said. He's very convinced of his assessment.)
> In the cockpit, when Deena is talking about the planetary defence guns knocking their shields out, and they're being boarded, Statda mostly stands with arms crossed, shaking her head. "Don't worry, everything will be fine, because the cap' said so." She says sarcastically.
> When they fall under fire, Statda laments "Crap! My rifle's in the med bay!" (She's a sniper as well)
> In the first tutorial fight, it's still Ashe and Dust vs. 3 Guardsmen.
> In the second tutorial fight (which takes places down another hallway, as Ashe told them to split up and flush the attackers out of the ship), it's Statda, K'bassu and Deena. --> This will cement for the player how powerful Ashe and Dust are, as they handle 3 guardsmen with the same level of difficulty.
> In the third tutorial battle, it's the 5 heroes vs. the enemy. (So the player can have up to 5 characters at once).

## §0. SCENARIO SPEC FORMAT (skill draft)

Every scenario file has these sections, in this order. ★ = mandatory before any asset work.

1. ★ **Header**: id, act, title, location, target duration, levels, party, prerequisite flags, music palette.
2. ★ **Purpose**: what the scenario must achieve for story, character, and gameplay.
3. ★ **Reveal ledger delta**: what the player knows entering and leaving; which fair-play clues are planted (check `README.md` §3).
4. ★ **Beat sheet**: numbered scenes with minutes; totals hit the target.
5. **Scenes**: setting, camera, music, flow, dialogue with **line IDs** `<SCENE>_<SPK>_<NN>`, stage directions in *italics*, choices marked `▸` with flag effects in `[brackets]`.
6. ★ **Encounters**: id, map (doors, heights, cover, hazards, collateral), enemies, **Insights** (Search results), intended solutions (≥2; ≥3 for bosses), fail state and retry point, what it teaches.
7. **Stat blocks** for anything new.
8. **Rewards**.
9. ★ **Flags** (also added to `data/flags.yaml`).
10. **Asset manifest**: the work order for Tripo / Fal / ElevenLabs / music.
11. ★ **Acceptance tests**: human, AI agent, timing, reveal.
12. **Storyboard pointer** (shot list file).

Rules: respect canon locks and the reveal ledger; every character speaks in their voice notes; no filler fights; no borrowed famous lines or lifted plots; end on a hook.

---

## §1. Header

| Field | Value |
|---|---|
| id | `opening` |
| Act | Opening (before Act I) |
| Title | Fast and Hard |
| Location | The *Galactic C*: workshop, cockpit, passenger lounge, cargo hold, embarkation bay; then a Lowlight warehouse |
| Target duration | **30–40 min** |
| Levels | 1 → 2 |
| Party | Dust, Ashe (Fight 1); Deena, K'saabu (Fight 2); all four (Fight 3) |
| Music | Core "Neon" (crew theme, battle) + one Srov vocal phrase when the princess is mentioned |

## §2. Purpose
- Introduce four characters through **banter under pressure**, in the first five minutes.
- Establish Dust (cocky, optimistic, talks himself into trouble), Ashe (ruthless, brilliant, secretly protective), Deena (doom-poetry, flirting, loyalty), and K'saabu (croaks, "commandeer the station").
- Set the Act I hook: the Srov contract to find Princess Melonsi, and Ashe's suspicion of it.
- **Tutorial:** turn order, movement, focus fire, healing, Speed, Pass Turn, AoE and its limits, Shield and Taunt, **Search**, Insights, Shove, doors, Deflectors.
- Make the player **feel** the difference: Dust and Ashe are heroes; Deena and K'saabu take care.
- **[R1]** Plant the first mystery: the boarders were tipped off.

## §3. Reveal ledger delta
- **Entering:** nothing.
- **Leaving:** the crew are Srov-adjacent mercs on a rescue contract; the Unity thinks they're Vors; someone wanted them dead before they landed.
- **Clues planted:** Ashe's agelessness (Deena's teasing); Dust's sooty-black-hearted flame and Ashe's rule against kindling it in public; Ashe's enamel chip (one camera beat).
- **Must not be learned:** anything about Akulsa, the Empire, or Dust's past.

## §4. Beat sheet

| # | Scene | Min | Play |
|---|---|---|---|
| OP1 | The Workshop | 4 | Cutscene + walkable workshop, 2 optional examines |
| OP2 | Under Fire | 2 | Cutscene |
| OP3 | The Plan | 4 | Cutscene, one dialogue choice |
| OP4 | Boarded | 1 | Cutscene; the Altitude meter appears |
| F1 | Lounge: Ashe + Dust | 5–7 | Tutorial fight 1 |
| T1 | Run to the hold | 1 | Short walk, Altitude ticks |
| F2 | Hold: Deena + K'saabu | 5–7 | Tutorial fight 2 |
| T2 | Regroup | 1 | Cutscene |
| F3 | Embarkation bay: all four | 8–12 | The real fight |
| OP5 | Aftermath | 3 | Loot, rating, the tip-off clue, the hug, white-out |
| OP6 | The Warehouse | 2 | Wake-up; hand-off to Act I |
| | **Total** | **~36–42** | |

---

## §5. Scenes

### OP1: The Workshop
**Setting:** The *Galactic C*'s workshop, a converted passenger galley. Chrome, teal vinyl, a cassette deck playing low, tools everywhere. Through a porthole: a neon-lit planet, Lumenhaven, with a ring of orbital stations. Ashe, sleeves rolled, has his arm inside an open wall panel. Dust sits on a crate flipping a credit chip.
**Camera:** fixed three-quarter angle (FFIX-style), slow drift.
**Music:** *Galactic C* crew theme, low through the tape deck.

> **OP1_ASH_01** — ASHE *(not looking up)*: "Princess Melonsi Ananna of Seonha. Srov-trained. Do you know what that means, kid?"
> **OP1_DST_01** — DUST: "She can kindle a sword and she's rich?"
> **OP1_ASH_02** — ASHE: "It means she's been told she's special by two separate institutions. Royalty, *and* the Srov. She's never carried her own bag. She's never been told 'no' by anyone who survived the conversation."
> **OP1_DST_02** — DUST: "You've never met her."
> **OP1_ASH_03** — ASHE: "I've met the type. I was trained by the type." *(a spark from the panel; he doesn't flinch)* "Three weeks missing on a Unity world, and the Srov send *us*? Two people they threw out?"
> **OP1_DST_03** — DUST: "They didn't throw me out. I left."
> **OP1_ASH_04** — ASHE: "You stowed away in a fuel locker and threw up on my boots." *(beat)* "This is a leash, kid. They want us back in robes. Rescue the princess, come home, all is forgiven. I don't want to be forgiven."
> ▸ **"Then why take the job?"** → **OP1_ASH_05**: "Because the pay's good, and because the princess is still a person in trouble. I'm not a monster. I'm a monster who reads contracts." `[ashe +1]`
> ▸ **"Maybe I want to go back."** → **OP1_ASH_06**: *(he finally looks at Dust; a long, unreadable look)* [REMOVED: Ashe never calls Dust "moron" (Jesse). Rewrite pending.] `[flag op.dust_wants_back]`
> ▸ **"I'll charm her. Princesses love me."** → **OP1_ASH_07**: "Name one princess." / **OP1_DST_04**: "...Statistically—" / **OP1_ASH_08**: "That's what I thought." `[dust charm +1]`

**Optional examines (walkable workshop):**
- *Ashe's sword on the bench* (Morningwake, white enamel and gold sunburst). Camera beat on the chipped corner showing black. Dust: **OP1_DST_05**: "You ever going to fix that chip?" Ashe: **OP1_ASH_09**: "It's character."
- *Dust's sword* (Kindling). Dust: **OP1_DST_06**: "Still say a little soot on the flame gives it personality." Ashe: **OP1_ASH_10**: "And I still say you don't light that thing where people can see it. Not on a Unity world. Not ever."

### OP2: Under Fire
*The ship jolts. Every light flickers. Through the porthole, streaks of orange: orbital battery fire.*
**Music:** crew theme cuts; *Under Fire* (driving synth bass, alarm-like arpeggio).

> **OP2_SHP_01** — SHIP COMPUTER *(cheerful 80s announcer voice)*: "Attention passengers! The *Galactic Companion* is experiencing... hostile weapons fire. Please remain seated and enjoy the complimentary—" *(static)*
> **OP2_UNT_01** — UNITY ORBITAL CONTROL *(over comms, clipped)*: "Unidentified Vors assault craft, you are inside Lumenhaven defense space. Cut your engines and prepare to be destroyed."
> **OP2_DST_01** — DUST: "'Prepare to be destroyed' isn't really an *option*, it's more of a—"
> **OP2_ASH_01** — ASHE: "Cockpit. Now."

### OP3: The Plan
**Setting:** The cockpit: wraparound windows, a planet filling the view, defense stations glittering in orbit, orange tracers. Deena comes skidding in, wrench in hand, coral hair half-down.
**Camera:** wide on the four, then fast cuts on each speaker; the planet grows behind them.

> **OP3_DNA_01** — DEENA: "The aft shield emitter, *my* aft shield emitter, the one I rebuilt from a *toaster*, a beautiful, *loyal* toaster, it's gone! And the port coupling's singing like a dying bird, and the inertial dampers are *weeping*, Ashe, I can hear them weeping, we are *so* dead, we are dead in a way that has paperwork—"
> **OP3_KSB_01** — K'SAABU *(ducking through the hatch, cannon under one arm)*: *[Croak. Grunt-grunt.]* `(subtitle) (Station. Big one. Left side. We take it.)`
> **OP3_DNA_02** — DEENA: "We are not landing on a Unity *starbase* and *commandeering* it! It has ten thousand people on it! *We* have four people and a *frog!*"
> **OP3_KSB_02** — K'SAABU: *[Indignant croak.]* `(I am not a frog. I am a K'saabu.)`
> **OP3_DNA_03** — DEENA: "You are a *frog* and I *love* you and *no*."
> **OP3_ASH_01** — ASHE *(sliding into the pilot's seat)*: "Straight at the planet."
> **OP3_DNA_04** — DEENA: "The *planetary EMP shield*, Ashe! It'll kill every circuit on this ship! We'll drop like a brick!"
> **OP3_ASH_02** — ASHE: "Not a brick. A glider. Kid?"
> **OP3_DST_01** — DUST: "*Galactic Companion*-class. Passenger safety regs: total power loss means a hull designed to glide. Wings, spoilers, no power needed. It's in the brochure."
> **OP3_DST_02** — DUST *(beat)*: "I read the brochure."
> **OP3_ASH_03** — ASHE: "Below the EMP line their batteries can't track us, because their targeting's shielded out too. We glide into the slums under the cloud deck. Nobody looks for a dead ship."
> **OP3_DNA_05** — DEENA: "If we *gently glide* in, they'll shoot us out of the sky before we hit the clouds!"
> **OP3_ASH_04** — ASHE: "Then we don't glide in gently. We go in fast and hard." *(the smallest smile)* "Just the way you like it."
> **OP3_DNA_06** — DEENA: "You have *no idea* what I like, and now you'll *never* know, because we're all going to *die* because of your *stupid plan!*"
> **OP3_DNA_07** — DEENA *(to Dust, pointing at Ashe)*: "And for a man who's *supposedly* fifty, you have the impulse control of a *teenager*."
> **OP3_ASH_05** — ASHE: "I'm fifty-two."
> **OP3_DNA_08** — DEENA: "You moisturize *nothing*! It's *offensive*!"
> **OP3_KSB_03** — K'SAABU *(quietly, to no one)*: *[Croak.]* `(Station would work.)`
> **OP3_ASH_06** — ASHE *(hands flying across switches)*: "When we hit atmosphere: spoilers up halfway. Wings out, not all the way, or the air rips them off. Two-thirds. Maybe three-fifths. Feel it."
> **OP3_DNA_09** — DEENA: "'*Feel it*'? This plan is *so* bad, it's like *Dust* came up with it!"
> **OP3_DST_03** — DUST: "Hey."
> ▸ **"It's a good plan."** → **OP3_DST_04**: "It's a good plan. I'd have come up with it eventually." / Deena: **OP3_DNA_10**: "*That's my point!*" `[deena +1]`
> ▸ **"What if we took the station?"** → K'saabu: **OP3_KSB_04**: *[Delighted croak!]* `(FINALLY.)` / Ashe: **OP3_ASH_07**: "No." `[ksaabu +2]`
> ▸ **"Deena. We've got this."** → Deena: **OP3_DNA_11**: *(softening, just for a second)* "...You'd better. You owe me dinner." `[deena +2]`

### OP4: Boarded
*A heavy CLANG. The whole ship lurches sideways. Red emergency lights flood the cockpit.*
> **OP4_SHP_01** — SHIP COMPUTER: "Attention passengers! A boarding pod has attached to the forward embarkation bay! The *Galactic Companion* welcomes all guests, but please— " *(The EMP hits. The voice dies mid-word. Every screen goes black. The engines die. Silence, except the wind starting to howl against the hull.)*
> **OP4_ASH_01** — ASHE *(calm)*: "We're gliding. Kid, you're with me, lounge. Deena, K'saabu, hold the cargo deck. Clear them out before they reach the cockpit. I need to be back in this chair before we hit the cloud deck, or we don't land, we *arrive*."

**[R2] The Altitude meter** appears (top of screen): **"ALTITUDE 9,000 m"**. It drops each round of combat and with each walk step between fights. It isn't a fail timer; it decides how well Ashe lands (see F3 rewards). The pressure is real, but it stays turn-based and AI-friendly.

---

## §6. Encounters

### F1: The Lounge (Ashe + Dust vs 3 boarders)
**Map:** the passenger lounge, 12×8 tiles. Rows of bolted seats (half cover), a chrome bar counter (full cover), a viewing window with fire and cloud streaking past. Boarders enter from the forward hatch.
**Enemies:** **Unity Breacher** ×1 (shotgun, hits hardest), **Unity Trooper** ×2.
**Tutorial prompts (in order, each shown once):**
1. *Turn order*: "The timeline at the top shows who acts next. Faster units act more often."
2. *Move then act*: "Move up to your Move range, then take one action. Seats give half cover."
3. **Focus fire**: "The Breacher hits hardest. Dropping one enemy fast beats wounding three." (Ashe's Dawnsight intent icon shows the Breacher aiming a big shot at Dust.)
4. *Flanking*: "Attacks from the side or back hit harder."
5. *Mend*: "Dust and Ashe can Mend: a small Eternity heal."
**Intended solutions:** (1) Ashe and Dust both focus the Breacher, then mop up. (2) Use the bar as full cover and make the Troopers come round it into melee.
**Insight (Search):** none (Search isn't introduced yet).
**Fail:** near-impossible (Dust and Ashe are heroes). If the party falls, retry from fight start.
**Teaches:** timeline, movement, cover, focus fire, flanking, healing.

> **F1_ASH_01** *(fight start)*: "Big one first. Always the big one first."
> **F1_DST_01** *(bark, after a kill)*: "And *that's* why you read the brochure."
> **F1_ASH_02** *(fight end, wiping his blade)*: "Unity issue armor." *(beat, frowning at a body)* "...cheap Unity issue armor."

**T1:** a short run aft through a tilted corridor (the floor is at an angle now) toward the cargo deck. **ALTITUDE −500 m.** Cut to the hold.

### F2: The Cargo Hold (Deena + K'saabu vs 3 boarders)
**Map:** cargo hold, 12×12. Stacked crates (full cover, destructible), a raised catwalk on one side (height), loose cargo sliding with the ship's tilt. **No civilians, no fragile objects.** K'saabu can be unleashed.
**Enemies:** **Unity Trooper** ×3, entering together through the forward hatch (clustered).
**Tutorial prompts:**
1. *Speed*: "Deena is very fast; she'll often act before enemies do. She's also brittle. Keep her in cover."
2. *Stun Grenade*: "Deena carries one Stun Grenade. **Save it**; you'll want it later." (It's greyed out with a padlock icon in this fight.)
3. **Pass Turn**: "Deena can give her turn to an ally, who acts immediately. Cooldown: 3 rounds." The prompt suggests passing to K'saabu before the troopers spread out.
4. **AoE**: "K'saabu is slow, but every cannon shot hits a 3×3 area. Here there's nothing to protect, so unleash him."
5. *Collateral warning (one line)*: "In many fights, civilians and delicate equipment will be in the blast. Move them first, or don't fire."
6. **Shield and Taunt**: "K'saabu can raise a personal shield and Taunt enemies into attacking him instead of Deena."
**Intended solutions:** (1) Deena Passes Turn → K'saabu cannons the cluster → Deena picks off the survivor. (2) K'saabu Shields and Taunts while Deena shoots from the catwalk.
**Fail:** possible if Deena stands in the open; retry from fight start.
**Teaches:** Speed, Pass Turn, AoE, Shield, Taunt, height, and *why* this pair needs care.

> **F2_DNA_01** *(fight start, hands shaking on her pistol)*: "Okay. Okay okay okay. Sweetheart, be good to me."
> **F2_KSB_01** *(fight start)*: *[Low, rolling croak.]* `(Behind me, little one.)`
> **F2_DNA_02** *(bark, after K'saabu's first cannon blast)*: "...I love you so much, you horrible frog."
> **F2_KSB_02** *(if Deena is hit)*: *[Furious bellow.]* `(NO.)` — K'saabu automatically gains Taunt on his next turn.

**T2: Regroup.** Ashe and Dust drop into the hold from a ceiling hatch. **ALTITUDE −500 m.**
> **T2_ASH_01**: "Forward embarkation bay. That's where they're coming in. We close that pod off, or we never stop fighting."
> **T2_DNA_01**: "The bay doors are dead. *Everything's* dead. The EMP—"
> **T2_ASH_02**: "Then we do it the old way."

### F3: The Embarkation Bay (all four vs 6, including a Sergeant)
**Map:** 16×10 tiles. The bay's **embarkation door** (a heavy sliding bulkhead, currently open) splits the area: **the boarding pod side** (6×10, where the enemies start) and **the ship side** (10×10, where the party enters). Luggage carts (half cover), a passenger check-in desk (full cover), an overhead luggage rack (can be climbed: height), sparking wall panels.

**Enemies (6):**
- **Boarding Sergeant** ×1: **Personal Shield** + **Deflector** (2-tile radius; reflects ranged rounds and AoE back at the shooter)
- **Unity Breacher** ×1
- **Unity Trooper** ×3
- **Unity Marksman** ×1 (on the pod's raised ramp; height)

**Tutorial prompts:**
1. **Search**: "Any character can **Search** as an action. Higher **Perception** spots more. Deena's Perception is very high."
2. *Deflector*: "The Sergeant's Deflector reflects ranged and AoE attacks fired into it. While it's up, K'saabu's cannon is dangerous near him. Think about how to separate him from his squad."

**Insights (found by Search):**
| Insight | Perception DC | Found by | Tip text |
|---|---|---|---|
| **Embarkation door: emergency battery intact** | 12 (Deena auto-succeeds) | Deena likely, others maybe | "The door's on its own emergency battery (passenger safety). Hit the panel and it slams shut. Anyone on the far side spends a turn reopening it before they can fire through." |
| **Deflector generator on the Sergeant's back** | 16 | Deena on a good roll; Ashe | "The Deflector's generator is a backpack unit. A hit from behind cracks it." |
| **Loose luggage rack** | 10 | Anyone | "The overhead rack is loose. Drop it (Interact) on whoever's under it: damage and Stagger." |

**Intended solutions (at least three):**
1. **The door play (Jesse's):** K'saabu **Shoves the Sergeant back into the pod side**; someone hits the door panel; the Sergeant is cut off. Deena **Passes Turn** to K'saabu (or waits for his next turn), and he cannons the Sergeant-less squad. If the Sergeant reopens the door, close it again (it costs him his turn).
2. **The tank-and-grind:** K'saabu Shields and Taunts; Deena Passes him extra turns as needed; Ashe and Dust focus the enemies one by one with swords (the Deflector doesn't stop melee); Mend to sustain.
3. **The backstab:** Deena or Dust flanks the Sergeant (using the check-in desk), cracks the Deflector generator from behind, and then K'saabu is free to fire.
4. *(Bonus)* Drop the luggage rack on the Marksman's approach path.
**Button-mashing result:** K'saabu fires into the Deflector, takes his own blast, and Deena gets focused down. **Party wipe is likely.** This is intended.
**Collateral:** none (the bay is empty), so K'saabu is free *once the Deflector is dealt with*.
**Fail:** retry from F3 start (with a one-line hint from the narrator log about what killed you).
**Teaches:** Search, Insights, doors, Shove, Deflectors, combining kits, and that the environment is a weapon.

**Pre-fight scene (Jesse's).** The crew crouches behind the check-in desk, looking through the open bulkhead at the six boarders. Their uniforms match. Nothing else does: every weapon is different, battered, half-repaired.
> **F3_ASH_01** — ASHE *(low drawl, unimpressed)*: "Look at that hardware. Even if I was a day-one private, I'd say these damned greaseballs are mercs dressed up in Unity armour."
> **F3_DST_01** — DUST: "Pirates."
> **F3_ASH_02** — ASHE: "Don't really matter what they were. Scum paid to kill is all I know."
> **F3_DNA_00** — DEENA: "Why would *pirates* board us while we're being shot at by *Planetary Defence*?"
> **F3_DST_02** — DUST *(doing his best Ashe)*: "Don't really matter. They won't live long enough to tell anyone about us."
> **F3_KSB_00** — K'SAABU: *[Grkroooooak!]* `(I could eat them.)`
> **F3_DNA_02** — DEENA: "No eating people when anyone else is around! Even *pirates!*"
> **F3_SGT_01** — SERGEANT *(spotting them)*: "The traitors are yonder! Open fire!"
*(Ashe chuckles. Dust gulps. Fight begins.)*
> **F3_KSB_01** *(if the Sergeant is shoved behind the door)*: *[Triumphant croak.]* `(Door. Is like small station.)`
> **F3_DNA_01** *(if she finds the door Insight)*: "Oh! Oh, the door's on the passenger-safety battery! *Bless* passenger safety! Somebody hit that panel!"
> **F3_SGT_02** *(dying)*: "...the candle... remembers..."

---

## §7. Stat blocks

| Unit | Lv | HP | Shield | Spd | Move | Notes |
|---|---|---|---|---|---|---|
| **Dust** | 1 | 120 | — | 110 | 6 | Sword combo, Mend (heal 30), Kindling resource |
| **Ashe** | 3 (scaled) | 170 | — | 105 | 6 | Heavy Cleave, Mend, Vigil, Dawnsight |
| **Deena** | 1 | 70 | — | 140 | 7 | Quick-draw shot (acts first in round 1), Stun Grenade (locked until F3), Pass Turn (cd 3), Perception 18 |
| **K'saabu** | 2 | 160 | 60 | 80 | 4 | Cannon (3×3 AoE, 40 dmg), Personal Shield (+60), Taunt, Shove (2–3 tiles) |
| **Unity Trooper** | 1 | 45 | — | 100 | 5 | Rifle; cover-seeking |
| **Unity Breacher** | 2 | 60 | — | 95 | 5 | Shotgun: 30 dmg cone, 2-tile range; hits hardest |
| **Unity Marksman** | 2 | 40 | — | 105 | 5 | Prefers height; *Pin* (Rooted) |
| **Boarding Sergeant** | 3 | 110 | 50 | 100 | 5 | **Deflector** (2-tile radius; reflects ranged and AoE to the shooter); generator breaks on a back hit; *Rally* (allies within 3 tiles +10% hit); reopening the door costs his turn |

*Balance target (Seer):* F1 first-try win 95%; F2 85%; **F3 40–60%** first try, and near 100% with any of the three plays.

## §8. Rewards
- Credits, a **Unity Sergeant's Deflector core** (crafting part, later used by Deena), Medpacks ×2, XP.
- **Battle rating (Jesse: refine later):** per fight, graded on rounds taken, damage received, Insights used, and Style (door, terrain, combo). Grades D–S.
- **Landing quality (from Altitude [R2]):** finish F3 above 2,000 m = **Clean crash** (no penalty, bonus credits); 0–2,000 m = **Rough crash** (party starts Act I with −15% HP); 0 m is never reached (Ashe makes it to the chair no matter what; the meter only grades it).

## §9. Flags
| Flag | Values | Scene |
|---|---|---|
| `op.dust_wants_back` | true/false | OP1 |
| `op.f3.solution` | `door` / `grind` / `backstab` / `other` | F3 |
| `op.landing` | `clean` / `rough` | OP5 |
| `op.tipoff_found` | true | OP5 |
| influence | `ashe`, `deena`, `ksaabu` | OP1, OP3 |

---

### OP5: Aftermath
**Setting:** the embarkation bay, smoking. Wind roars. Through the bay's porthole the clouds are rushing past, faster and faster.

**Loot screen** (credits, items, XP, battle rating).

**[R1, accepted] The tip-off.** It confirms what Ashe saw: thugs, not police. On the Sergeant's body: under the Unity uniform collar, a **tattoo of a candle with an open mouth**, and a data tape. Dust plays a second of it: the *Galactic C*'s **exact flight plan**, filed privately with the Srov two days ago.
> **OP5_DST_01** — DUST: "These aren't Unity. Ashe, they had our *flight plan*. The one we only gave the Srov."
> **OP5_ASH_01** — ASHE *(very quiet, already moving)*: "Then someone in the Srov talks to people with candle tattoos. Later. Cockpit."
*(Ashe sprints for the cockpit.)*

Deena is sitting on the floor against a luggage cart, pistol in her lap, staring at the body of the trooper she shot.
> **OP5_DNA_01** — DEENA *(small)*: "I've never... I fix things. I don't..."
> **OP5_DST_02** — DUST *(crouching, offering a hand)*: "Hey. You saved my life twice back there. I counted." *(beat)* "You're still the person who fixes things. You just fixed us."
*(He helps her up. K'saabu lumbers over and wraps both of them in an enormous, damp hug, lifting them off the floor.)*
> **OP5_KSB_01** — K'SAABU: *[Soft, rumbling croak.]* `(Good. Both alive. Stupid, but alive.)`
> **OP5_DST_03** — DUST *(squashed)*: "...Love you too, big guy."

*The ship's nose drops. The roar becomes a scream. Cockpit view: the city's neon blooms out of the clouds, impossibly fast. The screen floods **white**. Every sound drops out except, rising and rising:*
> **OP5_DNA_02** — DEENA *(offscreen)*: "Eeeeeeeeeeeeeeeeeeee—"
*(Cut to black on the impact. One second of silence.)*

### OP6: The Warehouse
**Setting:** morning-dark in the Lowlight. Rain. The *Galactic C* is **embedded nose-first in the side of a warehouse**, three storeys up, steaming, neon signs flickering around the hole. The "hampion" on the hull is lit by a pink holo-advert for noodles.
**Music:** a single lonely synth line under rain; then the Lumenhaven theme creeps in.
> **OP6_DNA_01** — DEENA *(climbing out of the hatch, hair everywhere)*: "We're alive. We're *alive*. Nobody talk to me. I need to kiss the ground. Where is the ground."
> **OP6_KSB_01** — K'SAABU *(looking down three storeys)*: *[Croak.]* `(Ground is there.)`
> **OP6_ASH_01** — ASHE *(stepping out, brushing glass off his coat, utterly calm)*: "Told you. Fast and hard."
> **OP6_DST_01** — DUST: "We're in a *wall*."
> **OP6_ASH_02** — ASHE: "We're in a wall *on the planet*."
*(Below, a door bangs open. A short, furious woman in a neon raincoat, **Mama Quell**, glares up at them, a cleaver in one hand and an invoice already in the other.)*
> **OP6_MQ_01** — MAMA QUELL: "Who's paying for my *wall?*"

**→ Act I begins.**

---

## §10. Asset manifest
**Environments:** *Galactic C* interior (workshop, cockpit, corridor, lounge, cargo hold, embarkation bay with boarding pod), *Galactic C* exterior (flight, glide, embedded), Lowlight warehouse street. Skybox: Lumenhaven from orbit with stations; atmospheric entry (fire to cloud to neon city).
**Characters (Tripo):** Dust, Ashe, Deena, K'saabu, Mama Quell, Unity Trooper, Breacher, Marksman, Boarding Sergeant (with Deflector backpack).
**Props:** Kindling, Morningwake (with chip), Deena's pistol "Sweetheart," K'saabu's underslung cannon, stun grenade, luggage carts, check-in desk, luggage rack, seats, bar counter, crates, boarding pod, data tape, Mama Quell's cleaver.
**Animations:** standard humanoid set ×4; K'saabu set (lumber, cannon brace, shove, hug, shield); Deena quick-draw and grenade throw; Ashe two-handed cleave; Dust sword combo and Mend; hug (3-character sync); crash shakes.
**VFX:** orbital tracers, EMP wave (blue ripple across the hull, lights dying in sequence), dawnfire-gold kindled blades (Ashe's forced gold; Dust's sooty gold with a black heart, used *only* in F1–F3 as melee glow, not a public reveal), cannon blast and 3×3 ring, shield bubble, Deflector dome and reflected-round ping, stun burst, sparks, atmospheric-entry heat glow on windows, white-out.
**Music:** *Galactic C* (crew theme), *Under Fire*, *Boarded* (battle), *Fast and Hard* (glide, rising to the white-out), *Lowlight Rain*.
**SFX:** orbital impacts, boarding-pod clamp, EMP thunk, wind howl rising, cannon, Deflector ping, door slam, K'saabu croak library, impact into warehouse.
**VO:** ~90 lines + K'saabu croak set + Ship Computer.

## §11. Acceptance tests
1. Timing: median 30–40 minutes.
2. Tester can describe each of the four crew in one sentence, *and* says the crew are funny.
3. Tester can explain Search, Pass Turn, Deflector, and the door play.
4. F3: button-mashers lose; testers who use one of the plays win. At least two different F3 solutions observed across 5 testers.
5. Tester feels Dust/Ashe as "strong" and Deena/K'saabu as "needing care" (ask directly).
6. Tester asks "who tipped them off?" or "who is 'the young one'?"
7. AI agent completes the Opening on Seer via the DOTS API in ≤250 actions.

## §12. Storyboard
Shot list: `06_STORYBOARD_OPENING.md`.

---

## §13. Refinements (Jesse accepted R1–R5 on 2026-11-03; R1 discovery rewritten by Jesse as the F3 pre-fight scene)
- **[R1] The boarders aren't Unity.** They're Candlemouth cultists in stolen Unity uniforms, with the crew's private flight plan. This (a) keeps Dust "incorruptible" (he isn't killing real police), (b) makes Deena's first kill land without souring the heroes, (c) ties straight into Act I's "betrayed from within" princess plot (the same leak), and (d) opens the game on a mystery. The Unity batteries' misidentification is genuine, and Commander Varga will hunt the crew all Act I.
- **[R2] Altitude meter, not a real-time timer.** It keeps the game turn-based and AI-playable, and it grades the landing instead of failing you.
- **[R3] Order of events.** Fire → plan → **boarded just before the EMP line** → EMP → glide → fights. That's why the boarders can attach while the ship still has power, and then everyone is trapped in a dead ship together.
- **[R4] Insights.** Jesse's door is the headline Insight. I added two more (the Deflector backpack and the luggage rack) so F3 has 3+ real solutions.
- **[R5] Stun Grenade.** Locked in F2 (with the "save it" prompt) and usable in F3, so the "save it" pays off immediately.
- **[R6] Planted clues.** Ashe's age (Deena), Dust's flame rule, the enamel chip. These are cheap now and pay off in Act IV.
