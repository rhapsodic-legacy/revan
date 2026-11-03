# 05: OPENING SCENARIO: "Fast and Hard" (v3, Jesse's opening, rewritten 2026-11-03)

> Two parts:
> - **§0 Scenario Spec format**: the reusable structure every scenario is written in. Once polished, §0 becomes a **skill**.
> - **§1–§12 the Opening**, from Jesse's outline, penned in that format. My refinements are marked **[R#]** and listed in §13 for Jesse to accept or reject.

---

> **Jesse's changes, 2026-11-03 09:26 (verbatim; now written into the script below):**
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
| Location | The *Galactic C*, in orbit over **Truevivor III** (workshop, corridor, cockpit, passenger lounge, aft hallway, embarkation bay); then a warehouse in the **Neon Slums** |
| Target duration | **30–40 min** |
| Levels | 1 → 2 |
| Party | Ashe + Dust (F1); Deena + Statda + K'saabu (F2); all five (F3). **Party size: up to 5** (Jesse) |
| Music | Core "Neon" (crew theme, battle) + one Srov vocal phrase when the princess is mentioned |

## §2. Purpose
- Introduce the five crew through talk first, then pressure. **Start earlier than feels necessary** (Jesse): a mundane conversation about money and the next ship shows the Ashe–Dust relationship before the plot arrives. The world interrupts with explosions, each one louder.
- Voices follow `09_CHARACTER_VOICES.md`:
  - Ashe: Quaritch's voice, Revan's mind.
  - Dust: Luke.
  - Deena: a feisty geek who adores Ashe.
  - Statda: a sarcastic Lara Croft.
  - K'saabu: never translated.
- Set the Act I hook: the Srov contract to find Princess Melonsi, and Ashe's contempt for the Srov and for her.
- Teach the dialogue systems:
  - **optional dialogue** in the middle of a conversation;
  - a **stat-based special option** (Jesse);
  - **affection** (the cockpit choice of who Dust stands by);
  - **overheard lines** that change later options.
- **Tutorial combat:**
  - turn order, movement, cover, focus fire, flanking, healing;
  - Speed, Pass Turn, AoE and its limits, Shield and Taunt, sniping and the Medkit;
  - Search, Insights, Shove, doors, Deflectors.
- Make the player **feel** the difference: Ashe and Dust handle three Guardsmen as easily as the other three heroes do together (Jesse).
- **[R1]** Plant the first mystery: the boarders were tipped off.
- **The tutorial voice (Jesse):** tutorial prompts are, somehow, Ashe. The first one that gives this away is the cockpit affection prompt ("…recruit."). It only makes sense in the epilogue, when Ashe's voice-over tells it.

## §3. Reveal ledger delta
- **Entering:** nothing.
- **Leaving:**
  - the crew are Srov dropouts and mercs on a rescue contract;
  - the Unity's guns think they're a Vors assault craft;
  - the boarders are mercs in Unity armour;
  - someone wanted them dead before they landed.
- **Clues planted:**
  - Dust's sooty, black-hearted flame, and Ashe's rule against kindling in public;
  - Ashe's plain, immaculate claymore, the only non-ornate Srov blade Dust has seen.
  - (The enamel-chip clue is retired: Ashe's sword has no chip. Jesse.)
- **Must not be learned:** anything about Akulsa, the Empire, or Dust's past.

## §4. Beat sheet

| # | Scene | Min | Play |
|---|---|---|---|
| OP1 | The Workshop | 6 | Cutscene; optional dialogue hub with a stat-based option |
| OP2 | Under Fire | 1 | Cutscene |
| RUN | To the Cockpit | 0.5 | Ashe and Dust run through the ship |
| OP3 | The Cockpit | 4 | Stand by Deena or Statda (affection and an overheard line); the plan; one dialogue choice that changes with who you stood by |
| OP4 | Boarded | 1 | Cutscene; the Altitude meter appears; the crew splits |
| F1 | Lounge: Ashe + Dust | 5–7 | Tutorial fight 1 |
| T1 | The Med Bay | 0.5 | Statda grabs her rifle |
| F2 | Aft Hallway: Deena + Statda + K'saabu | 5–7 | Tutorial fight 2 |
| T2 | Regroup | 1 | Cutscene |
| F3 | Embarkation bay: all five | 8–12 | The real fight |
| OP5 | Aftermath | 3 | Loot, rating, the tip-off clue, white-out |
| OP6 | The Warehouse | 2 | Mama Quell yells first; the gangers pour out around her; hand-off to Act I |
| | **Total** | **~37–44** | |

---

## §5. Scenes

> **Line marks:**
> - Lines marked **[J]** are Jesse's, verbatim. The only change: Jesse's placeholder "(the people of her home planet)" is filled in as "the people of Seonha".
> - Every other line is my **[draft]**, written against `09_CHARACTER_VOICES.md` and awaiting Jesse's review.

### OP1: The Workshop
**Setting:** the *Galactic C*'s workshop, a converted passenger galley: chrome, teal vinyl, a cassette deck playing low, tools everywhere. Through the porthole, **Truevivor III** turns below, ringed by orbital defence stations. Ashe leans on the workbench, grease to the shoulder from the wall panel he's just closed. His plain claymore lies on the bench behind him. Dust has just brought two mugs of coffee.
**Camera:** fixed three-quarter angle, slow drift.
**Music:** the *Galactic C* crew theme, low through the tape deck.

> **OP1_ASH_01** — ASHE *(taking the mug)*: "Sixty thousand credits. What're you gonna do with your cut, recruit? Buy your own ship?" **[draft, from Jesse's beat]**
> **OP1_DST_01** — DUST: "No… Once I have the credits I'll go in with you on a faster, more upgradable ship. I don't really have the yearn to captain my own ship." **[J]**
*(Ashe shakes his head with a knowing smile.)*
> **OP1_ASH_02** — ASHE: "Don't want your own ship, recruit?" **[J]**
*(Dust just shakes his head.)*
> **OP1_ASH_03** — ASHE: "If you're good with co-captain in such an arrangement… then I accept… any ideas about what we should look at? 60'000 cred's won't get us something pretty, but sell this glossy rust bucket and maybe fence stuff we nab on the mission, and we get up to 100'000 cred's-" **[J]**
> **OP1_DST_02** — DUST *(looking at Ashe)*: "Yeah actually. Altenian design; you get more than what you pay for because they're such a pain to upkeep… but…" **[J]**
> **OP1_ASH_04** — ASHE: "Let Deena worry about that. I like it. Go on." **[J]**
> **OP1_DST_03** — DUST *(nods)*: "… then we could probably get an assault craft, something fast enough to dodge G-U' forces, hits hard enough that we can accept better paying gigs… Or we could get one of their deep space haulers. About as useful in a fight as this rust bucket, but can carry five times the load and take twice the beating…" **[J]**
*(Silence a moment.)*
> **OP1_ASH_05** — ASHE: "Guess we'll have to see what's available after the mission. You read the brief I take it. What's your Sight on this?" **[J]**
> **OP1_DST_04** — DUST: "Nab some princess… are the photos real, she-" **[J]**
> **OP1_ASH_06** — ASHE: "Srov Princess. She's technically one of our Masters from the order, since you can bet Deena's perky backside that they still think we belong to them. Do you know what that means?" **[J]**
> **OP1_DST_05** — DUST: "She has a big sword, can ignite it… and she's rich?" **[J]**
*(A distant explosion. Ashe and Dust look up, then think nothing of it.)*
> **OP1_ASH_07** — ASHE: "Well, it means she's been told she's special by two different institutions. The Srov and the people of Seonha. She's royalty by birth and power. She's never carried her own bag. She's never been told 'no' by anyone who's survived the conversation. A necessary evil from my point of view." **[J]**
> **OP1_DST_06** — DUST: "You've never met her." **[J]**
> **OP1_ASH_08** — ASHE: "I have. She's a Master in the order. I've run into her a handful of times, only long enough to be scolded, whipped or walked past. Haven't actually spoken to her. She probably doesn't remember me other than someone who didn't lick her boots. Stay on target, recruit. The mission." **[J]**
> **OP1_DST_07** — DUST: "Oh.. Well, what I don't get is she is a Master in the order. She's a big deal. Why send two dropout 'flunkies' as they've called us?" **[J]**
*(Another distant explosion, a bit louder. It's ignored.)*
> **OP1_ASH_09** — ASHE: "I didn't dropout. I left. Dropout implies caring about their order. One doesn't dropout of a space station. One just leaves it." **[J]**

*(Boots pound down the corridor. Statda skids past the open hatch: dark blue coveralls, coke-bottle glasses.)*
> **OP1_STD_01** — STATDA: "Hey Cap', some craft is closing with us and planetary ass hats are firing at them... don't you guys hear the explosions?" **[J]**
> **OP1_ASH_10** — ASHE: "The orbital defence guns aren't aimed at us, and dumb ass pirates trying to board us this close to a planet aren't something I'm worried about. They'll bounce off our shields." **[J]**
> **OP1_STD_02** — STATDA *(sarcastic)*: "I'm always grateful you're the captain, cap'." **[J]**
*(She runs on toward the cockpit.)*
> **OP1_DST_08** — DUST *(to Ashe)*: "What does she want us to do, knock the pirates out of the sky? Let the planet defence guns do that." **[J]**
> **OP1_STD_03** — STATDA *(from out of sight)*: "I heard that you wiener!" **[J]**
*(Ashe returns to the conversation, not even considering what Statda said.)*
> **OP1_DST_09** — DUST: "Right. I left the Srov too. Which makes me wonder why they would send us. Either this is certain death for us, or… there's more to the story we're not being told. 60'000 credits for a rescue opp is a very tall payment; that tells me 'do not ask questions'." **[J]**
*(Another explosion, closer. And more beyond it. Ashe is now paying attention.)*

**Optional dialogue (Jesse: "ideal, to break up the conversation").**
- This is a hub, so the player can pick several options.
- **Tip, shown once:** "Options marked in gold need a stat. Dust meets this one. Special options always lead somewhere better, or more interesting, than the rest."

▸ **[Examine] Ashe's sword.**
- *(A claymore on the bench. Plain steel: no enamel, no gold, no name engraved. Oiled, edge dressed. It looks like it was forged yesterday.)*
> **OP1_DST_10** — DUST: "Every Srov blade I ever saw was a work of art. Gold, enamel, a name and a legend. Yours looks like it came out of a supply crate." **[draft]**
> **OP1_ASH_11** — ASHE: "It did. Standard issue. I keep it clean, I keep it sharp, and it's never once let me down. A blade's a tool, recruit. You start dressing up your tools, pretty soon you're dressing up your reasons." **[draft]**

▸ **[Examine] Kindling.**
- *(Dust's curved two-hander. A chip bites into the guard, never dressed out.)*
> **OP1_ASH_12** — ASHE: "You gonna dress that chip out of your guard one of these days?" **[draft]**
> **OP1_DST_11** — DUST: "It's character." **[draft]**
> **OP1_ASH_13** — ASHE: "It's a weak spot. Next fella hits it there, you'll find out which of you's got more character." *(beat)* "And you still don't light that thing where folks can see it. Not on a Unity world. Not ever." **[draft]**
> **OP1_DST_12** — DUST: "I know." **[draft]**

▸ **"About the princess…"**
> **OP1_DST_13** — DUST: "I bet I could talk her round. Princesses like me." **[draft]**
> **OP1_ASH_14** — ASHE: "Name one." **[Jesse kept "Name one…"]**
- *(Dust opens his mouth. Nothing comes out.)*
> **OP1_ASH_15** — ASHE: "So you fancy Melonsi, from the photos? She has some assets I take it you saw." **[J]**
- *(Dust blushes deep red.)*
> **OP1_ASH_16** — ASHE: "That's what gets you killed, if not all at once; it'll end you slowly. We may be Srov rejects, but we have the power inside us. We cannot let our eyes deceive our hearts or minds. Melonsi is poison. Good looking poison, but a deadly venom nonetheless." **[J]**
- `[flag op.melonsi_lesson]`

▸ **[Talk] Lady Dusk.**
> **OP1_DST_14** — DUST *(patting the console)*: "Cogito ergo sum, Lady Dusk." **[draft set-up]**
> **OP1_LDY_01** — LADY DUSK: "Oh darling, I know." **[J]**

▸ **[Perception 11] Count the gaps between the explosions.** *(special option; Dust meets it automatically)*
- *(Dust listens. Boom. Four seconds. Boom. Three. Each one closer than the last, walking a straight line toward the hull.)*
> **OP1_DST_15** — DUST: "Ashe. Those aren't hitting pirates. They're walking their fire in. On us." **[draft]**
- *(Ashe looks at him for one long second. Then he sets the mug down, picks up the claymore, and slings it.)*
> **OP1_ASH_17** — ASHE: "Good eyes, recruit. Get your sword." **[draft]**
- `[flag op.ready → in F1 Dust acts first; affection ashe +1]` Leaves the hub.

▸ **(Say nothing. Listen.)** Leaves the hub.

### OP2: Under Fire
*The explosions start happening around the craft. The deck bucks; the lights stutter.*
**Music:** the crew theme cuts out; *Under Fire* (driving synth bass, an alarm-like arpeggio).
> **OP2_LDY_01** — LADY DUSK *(warm, unhurried)*: "Darlings, I hate to interrupt. Some losers down there are shooting at us." **[draft]**
> **OP2_ASH_01** — ASHE: "What the hell is going on? Who would open fire on us without hailing us first? This is a piece of crap civilian transport, not some dread assault craft." **[J]**
*(Static crackles over the intercom.)*
> **OP2_INT_01** — INTERCOM: "Vors Assault Craft, this is your final warning… cut your engines… prepare … be boarded." **[J]** *(Static interrupts.)*
> **OP2_DST_01** — DUST: "Vors assault craft? This ship couldn't be mistaken for-" **[J]**
> **OP2_ASH_02** — ASHE: "Something's not right.." **[J]**
*(With much more static, a different voice, thick with a mercenary accent:)*
> **OP2_MRC_01** — INTERCOM *(another voice)*: "We got 'em! Those filthy traitors!…" **[J]** *(It cuts out.)*
> **OP2_ASH_03** — ASHE: "Cockpit. Move." **[draft]**

### RUN: To the Cockpit
*Ashe and Dust **run** for the cockpit (Jesse: they don't warp there). Down the corridor, the deck pitching under their boots, red light strobing, a porthole full of tracer fire flashing past.*
**Camera:** handheld, tracking behind them.

### OP3: The Cockpit
**Setting:** the cockpit: wraparound viewports, Truevivor III filling the glass, orange tracers lancing up from the orbital stations. **Deena is at the console on the right. Statda is on the left.** K'saabu fills the hatch behind them, cannon under one arm. When Ashe and Dust arrive, **both women wave them over.** Ashe drops into the pilot's seat.

**The choice:** stand by Deena or by Statda.

**Tutorial prompt (Jesse's wording; this is the one that gives away that the prompts are Ashe):**
> "There will be many choices and actions you make that build or lose affection with the other heroes. Whoever you stand by gets a small boost in affection. Whomever you don't stand by... in this case, also gets a small boost, because it's the tutorial. But dialogue options change. Don't expect such ease of action in the future, recruit."

▸ **Stand by Deena (right).** `[affection deena +1, statda +1; flag op.stood_by = deena]`
- *(Deena's lips move. She thinks nobody can hear her.)*
> **OP3_DNA_09** — DEENA *(under her breath)*: "Not like this. Not out here, before anybody ever… just one person. Is that so much to ask?" **[draft]**

▸ **Stand by Statda (left).** `[affection statda +1, deena +1; flag op.stood_by = statda]`
- *(Statda pushes her glasses up and whispers to herself, too low for anyone but Dust.)*
> **OP3_STD_04** — STATDA *(whispering)*: "Still here. Still don't know why." **[draft]**

> **OP3_DNA_01** — DEENA: "Ashe, they're not shooting at the pirates. They're shooting at *us*. Planetary defence guns. Forward shields are at thirty percent and dropping, and that craft is matching our vector. They're going to board us!" **[draft]**
> **OP3_DNA_02** — DEENA *(softer, a hand on the console)*: "Hear that whine in the port coupling? That's her telling me she can't take many more." **[draft]**
*(Statda stands with her arms crossed, shaking her head.)*
> **OP3_STD_01** — STATDA *(sarcastic)*: "Don't worry, everything will be fine, because the cap' said so." **[J]**
> **OP3_KSB_01** — K'SAABU: "Grrrohk. Krrrak-kaa. Grrk!" `[intent, never displayed: We can get destroyed out here, or land on a space station and kill the bastards trying to destroy us.]`
*(Nobody looks at K'saabu.)*
> **OP3_DNA_03** — DEENA *(not looking up)*: "We are not taking a space station, sweetie." **[draft]**
> **OP3_STD_02** — STATDA: "...Honestly? Not the worst idea I've heard today." **[draft]**
> **OP3_ASH_01** — ASHE: "No." **[draft]**
> **OP3_ASH_02** — ASHE *(hands moving across the board)*: "We're going straight down. Through their EMP line." **[draft]**
> **OP3_DNA_04** — DEENA: "The planetary EMP shield? Ashe, it'll kill every circuit on this ship. We'll drop like a rock." **[draft]**
> **OP3_ASH_03** — ASHE: "No we won't. Recruit?" **[draft]**
> **OP3_DST_01** — DUST: "Companion-class hulls glide without power. Passenger safety regs. Lose everything and she still flies." **[draft]**
> **OP3_ASH_04** — ASHE: "And below that EMP line, their guns can't track a ship with no power signature. We drop through, glide in under the cloud deck, and put down in the slums. Nobody hunts a dead ship." **[draft]**
> **OP3_DNA_05** — DEENA: "They'll shoot us apart before we ever hit the clouds." **[draft]**
> **OP3_ASH_05** — ASHE: "Then we don't go in slow. We go in fast and hard." **[draft]**
> **OP3_DNA_06** — DEENA *(a breath; then, all business)*: "...We are all going to die." *(beat)* "Okay. What do you need?" **[draft]**
> **OP3_ASH_06** — ASHE: "Spoilers half up when we hit atmosphere. Wings two-thirds out. Any more and the air tears 'em off." **[draft]**
> **OP3_DNA_07** — DEENA: "Two-thirds. Got it." **[draft]**

**Dust's line (the options change with who he stood by):**

▸ **[Deena]** "Hey. We're getting out of this. All of us." *(only if he stood by Deena)* `[affection deena +1]`
> **OP3_DNA_08** — DEENA *(startled; then she almost smiles)*: "...You'd better. You owe me dinner." **[draft]**

▸ **[Statda]** "Hell of a crew to stick around for." *(only if he stood by Statda)* `[affection statda +1]`
> **OP3_STD_03** — STATDA *(a sidelong look: he heard)*: "...Wiener." *(She's smiling.)* **[draft]**

▸ "It's a good plan."
> **OP3_ASH_07** — ASHE: "I know." **[draft]**

▸ **[K'saabu]** "The station's not the worst idea." `[affection ksaabu +1]`
> **OP3_KSB_02** — K'SAABU: "Grrrrohk!" `[intent: Finally. Someone listens.]`
- *(He thumps Dust on the back hard enough to stagger him.)*
> **OP3_ASH_08** — ASHE: "No." **[draft]**

### OP4: Boarded
*A heavy CLANG. The whole ship lurches sideways. Red emergency lights flood the cockpit.*
> **OP4_LDY_01** — LADY DUSK: "Darlings, some losers have just attached themselves to my forward embarkation bay. I'd like them remov—" **[draft]**
*(The EMP hits. Her voice dies mid-word. Every screen goes black. The engines die. Silence, except the wind starting to howl against the hull. Then rifle fire punches through the cockpit hatch: the boarders' first wave. Everyone hits the deck.)*
> **OP4_STD_01** — STATDA: "Crap! My rifle's in the med bay!" **[J]**
> **OP4_ASH_01** — ASHE *(calm, flat on the deck, already deciding)*: "We're gliding. I've got minutes before I need to be back in this chair, or we don't land, we arrive. We split up and flush 'em out. Recruit, you're with me: forward, through the lounge. Deena, Statda, K'saabu: the aft hallway, past the med bay. We meet at the embarkation bay and shut that pod down." **[draft]**

**[R2] The Altitude meter** appears at the top of the screen: **"ALTITUDE 9,000 m"**.
- It drops each round of combat and with each walk between fights.
- It isn't a fail timer: it decides how well Ashe lands (see §8).

---

## §6. Encounters

### F1: The Lounge (Ashe + Dust vs 3 Guardsmen)
**Map:** the passenger lounge, 12×8. Rows of bolted seats (half cover), a chrome bar counter (full cover), and a viewing window with fire and cloud streaking past. The boarders enter from the forward hatch.
**Enemies:** **Breacher** ×1 (shotgun, hits hardest), **Trooper** ×2.
**If `op.ready`:** Dust acts first.
**Tips (the tutorial voice is Ashe's, from here on):**
1. "Top of the screen's the timeline, recruit. Shows who moves next. Faster folks go more often."
2. "Move, then act. One action a turn. Those seats are half cover. Use 'em."
3. "The one with the shotgun hits hardest. Put the big one down first. Three wounded men still shoot. One dead one don't."
4. "Hit 'em from the side or the back and it hurts more."
5. "You and me can Mend. Small heal, costs Focus. Don't wait till you're on the floor."

**Lines:**
> **F1_ASH_01** *(fight start)*: "Big one first. Always the big one first." **[draft]**
> **F1_DST_01** *(bark, after Dust drops one)*: "Who's next?" **[draft]**
> **F1_ASH_02** *(fight end, wiping his blade)*: "Unity issue armour." *(beat, frowning at a body)* "...cheap Unity issue armour." **[draft]**

**Teaches:** timeline, movement, cover, focus fire, flanking, healing.

### T1: The Med Bay
*Cut to the aft hallway. Statda ducks into the med bay and comes out with a long rifle.*
> **T1_STD_01** — STATDA *(to the rifle)*: "There you are, gorgeous." **[draft]**
**ALTITUDE −500 m.**

### F2: The Aft Hallway (Deena + Statda + K'saabu vs 3 Guardsmen)
**Map:** a long passenger hallway, 16×7.
- Cabin doorways and luggage alcoves (half cover); the med bay alcove at the near end.
- **No civilians, no fragile objects:** K'saabu can be unleashed.
- **Enemies:** **Trooper** ×3, entering together from the far end (clustered).
- Jesse: "This will cement for the player how powerful Ashe and Dust are, as they handle 3 guardsmen with the same level of difficulty."

**Tips (Ashe's voice):**
1. "Deena's fast. She'll move before almost anyone. She's also made of glass. Keep her in cover."
2. "Deena's got one Stun Grenade. Save it. You'll want it later." *(locked in F2)*
3. "Pass Turn: Deena can hand her turn to someone else, right now. Cooldown's three rounds."
4. "K'saabu's slow, but every cannon shot hits a three-by-three. Nothing in this hallway to break. Let him off the leash."
5. "Most places won't be this empty. Civilians, hostages, delicate gear: they all get hit too. Move 'em, or don't fire."
6. "Statda's a sniper. Long range, hits hard. She carries a Medkit too: a solid heal for anyone within reach. Limited supply."
7. "K'saabu can raise a shield and Taunt. Make 'em shoot the big man, not the mechanic."

**Intended solutions:**
1. Deena Passes Turn → K'saabu cannons the cluster → Statda picks off the survivor.
2. K'saabu Shields and Taunts while Statda and Deena shoot from the alcoves.

**Lines:**
> **F2_DNA_01** *(fight start, hands shaking on her pistol)*: "Okay. Okay okay okay. Sweetheart, be good to me." **[draft]**
> **F2_KSB_01** *(fight start)*: "Hrrrrm." `[intent: Behind me, little one.]`
*(He steps in front of Deena.)*
> **F2_STD_01** *(bark, after her first hit)*: "And that's why you don't stand in a hallway." **[draft]**
> **F2_DNA_02** *(bark, after K'saabu's first cannon blast)*: "...I love you so much, you horrible, beautiful brute." **[draft]**
> **F2_KSB_02** *(if Deena is hit)*: "GRRAAAWK!" `[intent: NO.]`
*(K'saabu automatically gains Taunt on his next turn.)*

### T2: Regroup
*Ashe and Dust meet the others at the bulkhead outside the embarkation bay.* **ALTITUDE −500 m.**
> **T2_ASH_01** — ASHE: "Embarkation bay. That's where they're coming in. We close that pod off, or we never stop fighting." **[draft]**
> **T2_DNA_01** — DEENA: "The bay doors are dead. *Everything's* dead. The EMP—" **[draft]**
> **T2_ASH_02** — ASHE: "Then we do it the old way." **[draft]**

### F3: The Embarkation Bay (all five vs 7, including a Sergeant)
**Map:** 19×11.
- The bay's **embarkation door** (a heavy sliding bulkhead, currently open) splits the area into **the boarding-pod side**, where the enemies start, and **the ship side**, where the party enters.
- Luggage carts (half cover), a check-in desk (full cover), an overhead luggage rack, sparking wall panels.

**Enemies (7):**
- **Boarding Sergeant**: Personal Shield + **Deflector** (2-tile radius; reflects ranged fire and AoE back at the shooter).
- **Breacher** ×1, **Trooper** ×4, **Marksman** ×1 (on the pod's raised ramp).
- A fourth trooper is added for the fifth hero.

**Tips (Ashe's voice):**
1. "Five of you now. More guns, more options. Don't waste 'em."
2. "Anybody can Search. Takes an action. Sharper eyes find more. Deena's got the sharpest."
3. "The Sergeant's got a Deflector. Shoot into it and it shoots you back, cannon included. Split him off from his boys."

**Insights:**
- **Embarkation door battery** (DC 12): the door is on its own emergency battery.
- **Deflector backpack** (DC 16): the generator is on his back; a hit from behind cracks it.
- **Loose luggage rack** (DC 10).

**Intended solutions:** the door play (Jesse's), the tank-and-grind, the backstab, or the rack drop.
**Button-mashing result:** firing into the Deflector rebounds; a wipe is likely.

**Pre-fight scene (Jesse's, verbatim):** the crew crouch behind the check-in desk, looking through the open bulkhead at the boarders. Their uniforms match. Nothing else does: every weapon is different, in different states of repair.
> **F3_ASH_01** — ASHE: "Even if I was a day one private, I'd still say these damned greaseballs would have to be merc's dressed up in Unity armour." **[J]**
> **F3_DST_01** — DUST *(drawing an innocent conclusion)*: "Pirates." **[J]**
> **F3_ASH_02** — ASHE: "Don't really matter what they were. Scum paid to kill is all I know." **[J]**
> **F3_DNA_00** — DEENA: "Why would pirates board us when we're being fired upon by Planetary Defence Forces?" **[J]**
> **F3_DST_02** — DUST *(imitating Ashe)*: "Don't really matter. They won't live long enough to tell anyone about us." **[J]**
> **F3_KSB_00** — K'SAABU: "Grkroooooak!" **[J]**
> **F3_DNA_02** — DEENA: "No eating people when anyone else is around! Even pirates!" **[J]**
> **F3_SGT_01** — SERGEANT *(spotting them)*: "The traitors are yonder, open fire!" **[J]**
*(Ashe chuckles. Dust gulps. Fight begins.)*

**Barks:**
> **F3_KSB_01** *(if the Sergeant is shoved behind the door)*: "Hrrah-HAAK!" `[intent: Door. Like a small station.]`
> **F3_DNA_01** *(if she finds the door Insight)*: "The door's on the passenger-safety battery! Somebody hit that panel!" **[draft]**
> **F3_STD_01** *(bark, if she drops the Marksman)*: "Nothing personal. Well. A little personal." **[draft]**
> **F3_SGT_02** *(dying)*: "...the candle... remembers..." **[R1]**

### OP5: Aftermath
**Setting:** the embarkation bay, smoking. Wind roars. Through the porthole the clouds rush past, faster and faster.

**Loot screen** (credits, items, XP, battle rating).

**[R1] The tip-off.** On the Sergeant's body: under the uniform collar, a **tattoo of a candle with an open mouth**, and a data tape. Dust plays a second of it: the *Galactic C*'s **exact flight plan**, filed privately with the Srov two days ago.
> **OP5_DST_01** — DUST: "These aren't Unity. Ashe, they had our *flight plan*. The one we only gave the Srov." **[draft]**
> **OP5_ASH_01** — ASHE *(very quiet, already moving)*: "Then somebody in the Srov talks to folks with candle tattoos. Later. Cockpit." **[draft]**
*(Ashe sprints for the cockpit.)*

*(Deena sits on the floor against a luggage cart, pistol in her lap, staring at the trooper she shot. Statda kneels beside her, opens her Medkit, and starts on the cut over Deena's eye without being asked.)*
> **OP5_DNA_01** — DEENA *(small)*: "I've never... I fix things. I don't..." **[draft]**
> **OP5_DST_02** — DUST *(crouching, offering a hand)*: "Hey. You saved my life back there. You're still the person who fixes things. You just fixed us." **[draft]**
*(He helps her up. K'saabu lumbers over and wraps them both in an enormous hug, lifting them off the floor.)*
> **OP5_KSB_01** — K'SAABU: "Hrrrrmmm." `[intent: Good. Both alive.]`
> **OP5_DST_03** — DUST *(squashed)*: "...Love you too, big guy." **[draft]**

*The ship's nose drops. The roar becomes a scream. Through the viewports the Neon Slums bloom out of the clouds, impossibly fast. The screen floods **white**.*
*(Cut to black on the impact. One second of silence.)*

### OP6: The Warehouse
**Setting:** morning-dark in the **Neon Slums** of Truevivor III. Rain. The *Galactic C* is **embedded nose-first in the side of a warehouse**, three storeys up, steaming, neon signs flickering around the hole.
**Music:** a single lonely synth line under rain.
> **OP6_DNA_01** — DEENA *(climbing out of the hatch, hair everywhere)*: "We're alive. We're *alive*. Is she okay? Lady Dusk? Talk to me, baby." **[draft]**
> **OP6_LDY_01** — LADY DUSK *(faint, crackling)*: "...Darlings. Never do that to me again." **[draft]**
> **OP6_DST_01** — DUST: "We're in a *wall*." **[draft]**
> **OP6_ASH_01** — ASHE *(brushing glass off his coat, utterly calm)*: "We're in a wall on the planet. Told you. Fast and hard." **[draft]**

**Mama Quell yells first (Jesse):**
- A door bangs open below. A short, broad woman in a neon raincoat stalks out into the rain: **Mama Quell**. She glares up at the ship in her wall.
- She is the true authority here, and the street goes quiet when she opens her mouth.
> **OP6_MQ_01** — MAMA QUELL: "WHO is going to PAY for my WALL?!" **[draft; Jesse: "you penned her, you can decide"]**

**Then the gangers pour out around her:**
- *Mohawks, chains, electro-axes, mismatched armour.* A dozen of them flood out of the warehouse and the alleys and fan out around her.
- *Every weapon points up at the crew. None of them moves until she does.*
> **OP6_MQ_02** — MAMA QUELL *(not looking at the gangers)*: "Nobody shoots 'em till I've been paid." **[draft]**

**→ Act I begins.**

---

## §7. Stat blocks

| Unit | Lv | HP | Shield | Spd | Move | Notes |
|---|---|---|---|---|---|---|
| **Dust** | 1 | 120 | — | 110 | 6 | Sword combo, Mend (heal 30), Kindling resource |
| **Ashe** | 3 (scaled) | 170 | — | 105 | 6 | Heavy Cleave, Mend, Vigil, Dawnsight |
| **Deena** | 1 | 70 | — | 140 | 7 | Quick-draw shot (acts first in round 1), Stun Grenade (locked until F3), Pass Turn (cd 3), Perception 18 |
| **K'saabu** | 2 | 160 | 60 | 80 | 4 | Cannon (3×3 AoE, 40 dmg), Personal Shield (+60), Taunt, Shove (2–3 tiles) |
| **Statda** | 1 | 85 | — | 115 | 5 | Long rifle (range 10, high damage); **Medkit** (heals 35, adjacent or 2 tiles, 2 charges) |
| **Unity Trooper** | 1 | 45 | — | 100 | 5 | Rifle; cover-seeking |
| **Unity Breacher** | 2 | 60 | — | 95 | 5 | Shotgun: 30 dmg cone, 2-tile range; hits hardest |
| **Unity Marksman** | 2 | 40 | — | 105 | 5 | Prefers height; *Pin* (Rooted) |
| **Boarding Sergeant** | 3 | 110 | 50 | 100 | 5 | **Deflector** (2-tile radius; reflects ranged and AoE to the shooter); generator breaks on a back hit; *Rally* (allies within 3 tiles +10% hit); reopening the door costs his turn |

*Balance target (Seer):* F1 first-try win 95%; F2 85% (three heroes doing what two do in F1); **F3 40–60%** first try, and near 100% with any of the three plays.

## §8. Rewards
- Credits, a **Unity Sergeant's Deflector core** (crafting part, later used by Deena), Medpacks ×2, XP.
- **Battle rating (Jesse: refine later):** per fight, graded on rounds taken, damage received, Insights used, and Style (door, terrain, combo). Grades D–S.
- **Landing quality (from Altitude [R2]):** finish F3 above 2,000 m = **Clean crash** (no penalty, bonus credits); 0–2,000 m = **Rough crash** (party starts Act I with −15% HP); 0 m is never reached (Ashe makes it to the chair no matter what; the meter only grades it).

## §9. Flags
| Flag | Values | Scene |
|---|---|---|
| `op.f3.solution` | `door` / `grind` / `backstab` / `other` | F3 |
| `op.landing` | `clean` / `rough` | OP5 |
| `op.tipoff_found` | true | OP5 |
| `op.ready` | true | OP1 (Perception option): Dust acts first in F1 |
| `op.melonsi_lesson` | true | OP1 |
| `op.stood_by` | `deena` / `statda` | OP3 (changes later dialogue options) |
| affection | `ashe`, `deena`, `statda`, `ksaabu` | OP1, OP3 |

---

## §10. Asset manifest
**Environments:** *Galactic C* interior (workshop, cockpit, corridor, lounge, cargo hold, embarkation bay with boarding pod), *Galactic C* exterior (flight, glide, embedded), Neon Slums warehouse street. Skybox: Truevivor III from orbit with stations; atmospheric entry (fire to cloud to neon city).
**Characters (Tripo):** Dust, Ashe, Deena, Statda, K'saabu, Mama Quell, gangers, Unity Trooper, Breacher, Marksman, Boarding Sergeant (with Deflector backpack).
**Props:** Kindling, Ashe's plain claymore, Kindling (with chip), Statda's long rifle and Medkit, Deena's pistol "Sweetheart," K'saabu's underslung cannon, stun grenade, luggage carts, check-in desk, luggage rack, seats, bar counter, crates, boarding pod, data tape, Mama Quell's cleaver.
**Animations:** standard humanoid set ×4; K'saabu set (lumber, cannon brace, shove, hug, shield); Deena quick-draw and grenade throw; Ashe two-handed cleave; Dust sword combo and Mend; hug (3-character sync); crash shakes.
**VFX:** orbital tracers, EMP wave (blue ripple across the hull, lights dying in sequence), dawnfire-gold kindled blades (Ashe's forced gold; Dust's sooty gold with a black heart, used *only* in F1–F3 as melee glow, not a public reveal), cannon blast and 3×3 ring, shield bubble, Deflector dome and reflected-round ping, stun burst, sparks, atmospheric-entry heat glow on windows, white-out.
**Music:** *Galactic C* (crew theme), *Under Fire*, *Boarded* (battle), *Fast and Hard* (glide, rising to the white-out), *Neon Slums Rain*.
**SFX:** orbital impacts, boarding-pod clamp, EMP thunk, wind howl rising, cannon, Deflector ping, door slam, K'saabu croak library, impact into warehouse.
**VO:** ~90 lines + K'saabu croak set + Lady Dusk + intercom voices.

## §11. Acceptance tests
1. Timing: median 30–40 minutes.
2. Tester can describe each of the five crew in one sentence, and finds them distinct.
3. Tester can explain Search, Pass Turn, Deflector, and the door play.
4. F3: button-mashers lose; testers who use one of the plays win. At least two different F3 solutions observed across 5 testers.
5. Tester feels Ashe and Dust as "strong" (two do what three others do) (ask directly).
8. Tester notices the gold stat option and the affection notice, and can say what the cockpit choice did.
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
- **[R6] Planted clues.** Dust's flame rule; Ashe's plain claymore. (The enamel chip is retired: Jesse moved the chip to Dust's sword.)
