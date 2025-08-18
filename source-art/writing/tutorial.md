# Goals

1. Stay true to the lore doc `Naous - The Still World`.
2. Introduce the player to both the world and the game systems.
3. Keep things flexible and replaceable.


# Story Summary

- The player is formed from Naous to assist in quelling the Stilled
- They explore an abandoned Ossified Ruins to wipe out any threats
- In doing so, they acquire their first set of powers and gear
- The explore and defeat some basic enemies until their presence alerts a horde
- They use their new powers to fend them off for a time, but soon realize they are outnumbered
- Some NPC "players" arrive to help take out a few more, but they too are ill-equipped for the long haul
  - These don't have to be full AI-driven actors. Just have some masks fly around while the enemies get hit a few extra times and maybe the player gets healed occasionally
- A massive boss enemy arrives that smashes a "player" or two, forcing those remaining to retreat
- The player (and "group") decide to regroup and go back into this new dungeon with a full party and refreshed resources

# Tutorial Summary

- Player spawns with a default mask providing little-to-no benefits
- Explores some ruins to find 2 combat abilities (Echoes)
  - Attack + Utility
- Learn how to attack a static, non-threatening object
- Fight a simple, combative enemy
  - Absorb a healing ability as reward
- Explore further to defeat a few more Stilled
- Acquire 2 masks from the area and/or enemies defeated
  - Stats-based example: Melee/Tank focused + Ranged/Magic focused
  - Learn how mask benefits work
- Learn how to equip different masks to gain their appropriate benefits
    - Any not equipped go into inventory
- Fight a medium-sized miniboss with more aggressive attacks
  - Absorb another combat ability that can't be slotted in with their current abilities due to a Draw limit
  - Can be swapped with a current ability, but any ability not equipped goes to inventory 
- A small horde of weak enemies attack, player defeats several
- The horde begins to overwhelm them as some (scripted/fake) "players" save them
  - Can be entirely faked. Just randomly incur attacks on the enemies and occasionally heal the player
- A massive boss enemy arrives defeats some allies
  - Opportunity to show what it looks like when a fellow player is defeated
- Player leaves, causing the ruins to become a new dungeon that must be tackled fresh with a group of players

# Full Story & Tutorial

## Scene 1 - Opening / Game Start

Camera fades into an environment of grayish-blue that hints at purple. An empty thoroughfare stretches forward with a sparse smattering of ruins that only just convey an impression of their original building forms.

The ruins of a building rest just in view on the right accompanied by a doorless entryway that begs for attention.

(Maybe a mask flies up from the ruined building and towards the player?)

The player awakens as a new Bearer. They are opaque yet formless as a dirtied mask drifts in and attaches to their body. As the mask affixes itself to their form, the player's body forms into a recognizable humanoid. The transition is eerily smooth... calm. As though the body was there the whole time and we've only just been gifted with the ability to perceive it.

> The player is initially given a mask that provides minimal (or zero) benefits.

### Scene 1.1 - Initial Exploration
A sense transcending intuition somehow indicates the player should drift forward.

> Player is given control and UI prompts as necessary.
> 
> Text displays with a task to "Investigate the Ossified Ruins" (quest log?)

This space is functionally linear, but provides several rooms or buildings to meander through. It's hard to discern if the signs of life are truly remnants of past cultures or if it has always been here since existence was first conceptualized.

Furniture imitates plants birthed from the land. You feel like you knew all along that these tools would be here when you entered.

A barricade of rubble blocks the path forward, but you know your goal is to be on the other side.

> Quest update: "Find something to help break through the rubble"

### Scene 1.2 - Echoes

The mask has known what to do and provides a hint as the camera seems to point towards a particular building nearby. Upon entering, a loose pile of debris covers a glow that can't be ignored.

The Echoes wordlessly speak of powers long past. The mask invites them into our being as a reminder that the choice is not ours.

> Inventory/Gear screen is opened, displaying a set of empty slots. One slot is highlighted that indicates where this Echo will be equipped.
>
> - Player is shown 2 Echoes to choose from, both offensive focused abilities.
>   - [INSERT_ATTACK_ECHO_DETAILS_HERE]
>     - Placeholder_A: Melee attack, short cooldown, medium damage
>     - Placeholder_B: Ranged attack, medium cooldown, medium-high damage

> After selecting the first Echo, the remaining one can be seen entering our inventory. A new slot is highlighted showing where the next Echo will be equipped.
>
> - The player is shown 2 new Echoes to choose from, both utility focused. 
>   - [INSERT_UTILITY_ECHO_DETAILS_HERE]
>     - Placeholder_A: Short dash, medium cooldown, provides brief invicibility
>     - Placeholder_B: Shield bubble, short-medium cooldown, provides a small overshield/buff that reduces incoming damage until depleted (or time expires)

> After equipping the utility Echo, the remaining one is placed in the player inventory.
> 
> A message appears to say: "Echoes can be equipped from the inventory any time outside of combat"

> After selecting their Echoes, the hotbar UI fades in to display their newly acquired abilities along with several "empty" ability slots to indicate that they can expect to acquire more in the future.

Wielding the Echoes, the player returns their focus to the barricade.

> Quest update: "Destroy the barricade"
>
> Player can target the barricade rubble and deal damage with their new attacking Echo. A health indicator is shown and depletes with each attack made.

Destructive intent clashes with the serene silence. The only entities with any sense of life appear to be you, this barricade, and whatever is suddenly bursting through from the other side.

A short backstep leaves just enough room as a creature violently breaks through, piercing the solid rocks and stopping just short of doing the same to you.

Memory becomes knowledge. The reason you are given form becomes crystal clear.

> Quest update: "Eliminate the Stilled"

### Scene 1.3 - Combat

> Player enters combat with the UI shifting as necessary (red outlines? combat-specific elements fade in?).
> 
> - The player can target and attack the enemy, similar to the rubble barricade.
> - The enemy also has a health bar, depletes when attacked.
> - Enemy takes ~8 attacks to defeat? Enough that it has a chance to use both of its attacks a few times.

> _Stilled Actions_:
>
> - Constantly walks slowly towards the player. Easy to walk/run away from, maybe 60-80% of player speed.
> - **Basic melee attack**: When in range, makes an attack with modified damage output as necessary for tutorial purposes (don't defeat the player unless they literally step away for dinner or something silly)
> - **Frontal AoE attack**: circular flat shape on the ground directly in front of the Stilled. Indicated with a red or otherwise "scary" zone that suggests the player should get away. Has a long wind-up and animation where the Stilled rears it's head and shoulders back to scream, then slams down. Should have a cooldown, maybe 5-10 seconds.
>   - Possibly trigger this after taking X hits? Eg. every 2 hits will always use the AoE attack next?

Persistence and purpose win the day as the Stilled's form dissolves into the surroundings. From its core another Echo involuntarily combines its shape with our own, providing yet another ability.

> A new support Echo is automatically equipped to the player in the next available slot. The slot on the hotbar illuminates to grab attention as its icon appears.
> 
> - [INSERT_SUPPORT_ECHO_DETAILS_HERE]
>   - Placeholder: Healing Echo: Heal self for X% of max health, long cooldown

> (Optional) A message displays to the player: "Echoes can be arranged on the hotbar to fit your needs"
> 
> - Communicate how to arrange/assign Echo abilities on the hotbar

## Scene 2 - Explore the ruins

Two obstacles removed leaves a wide plaza open for us to explore.

> Quest update: "Investigate the Ossified Ruins [0/3]" & "Eliminate the Stilled [0/3]"
> - Separate simultaneous objectives

The plaza is largely flat with a statue/fountain in the center. More ruined buildings with tighter spacing outline the area, separated by paths leading in a handful of directions. These paths appear to be blocked by rubble sturdier and taller than what we dealt with earlier. We have no clear way to get past them, so we'll need to explore the area first.

Several Stilled seem to be patrolling the plaza in a manner both mindless and predictable. Eliminating them proves to be expectedly easy.

### 2.1 - Masks

> Each of the quest objectives are assigned a mask reward. They can be progressed and completed in any order, giving the player their respective reward upon completion.
>
> - The first quest completed will initiate a tutorial for changing masks and communicating what they do.
> - Both masks can be acquired and equipped, with the remaining one left in the inventory.

#### Defeating Stilled

The 3 Stilled in the area are near oblivious as we ambush each of them right in the open. However, fighting multiple at once may present a challenge with our limited kit.

> 3 Stilled enemies patrol the area, all largely identical to the first one fought. Can opt to give them more aggressive AI or extra abilities if desired. Player now has a healing ability to help them jump from fight to fight or mitigate damage from getting outnumbered.
> 
> Each of the 3 enemies can be aggro'd separately, but will initiate combat if the player gets close enough.
> 
> - (Optional) If the player retreats through the opening path, they may disengage and return to their patrol location.

One way or another, their death is inevitable as our abilities lay waste. As the third falls, a mask is found within its remains.

> After defeating all 3 Stilled, a mask is given as a reward.
> 
> (Initiate Tutorial if necessary, otherwise simply show a toast for "item acquired" or something)
> 
> Inventory/Gear screen open. Similar to the Echoes, a slot indicates where the mask will be equipped to.
> 
> - Message appears: "Masks provide various benefits. Find and equip a mask that fits your playstyle!"
>   - (Add details as necessary)
>   - Placeholder: Melee/Tank focused, increases melee attack (strength?) and max health

#### Exploring Ruins

The building layout begins to suggest they were built rather than born. Hints of shops and inns float through the mind, fleeting as they are against this empty backdrop.

Throughout the area, 3 relics are calling out. They tell inspirations of stories, like a bard with no tongue. Naous cycles through all, repeating every story's ending as though it were a new beginning.

> (Initiate Tutorial if necessary, otherwise simply show a toast for "item acquired" or something)
> Inventory/Gear screen open. Similar to the Echoes, a slot indicates where the mask will be equipped to.
>
> - Message appears: "Masks provide various benefits. Find and equip a mask that fits your playstyle!"
>  - (Add details as necessary)
>  - Placeholder: Ranged/Magic focused, increases ranged attack (mind?) and reduces utility Echo cooldowns

### Scene 2.2 - Miniboss

The plaza seems combed through for only a brief moment. A shuddering vibration nearby acts as a siren's call. A new type of enemy seems to have kindly demolished the debris blocking one of the paths, but doesn't seem keen on letting us by without greeting us first.

> A new Stilled enemy appears, slightly larger than the previous type. It has thicker, muscle-like appendages with sharp edges and points. It moves notably faster and hits harder, though it takes a bit more time between attacks than the previous enemy.
> 
> - _Miniboss Stilled_:
>   - Tankier enemy, aggressive, feels fast but not hard to dodge. 10-15 attacks to defeat but has a vulnerability to deal more damage
>   - When in range to attack, will "zip" laterally in a strafing motion before starting the attack.
>     - Thinking something like it stretches and almost teleports a short distance left/right 2 or 3 times before acting.
>     - Doesn't have to happen before every attack, but can act as a "tell" for some attacks
>   - When out of range to attack, will quickly move towards the player to get in range.
>   - **Swipe attack**: In melee range, makes a "swipe" motion (like a cat swiping something off a counter) to deal damage
>     - Could be a fancy AoE hitbox that can hit multiple players, or could just be an animation with a simple targeted attack at one player
>   - **Stomp attack**: In near-melee range, will wind or "rear" up. A circular damage zone appears on the ground centered beneath it with a radius of about 1.5 its body length (overhead perspective). After ~1.2 seconds, will slam down damaging any players in the zone.
>     - Could save this attack until re-encountered with a team in the dungeon if we want a nice surprise.
>   - **Dash attack**: At a large distance, will charge up a dash. A red zone on the ground about 4-6 body lengths in size indicates the damage zone (static, doesn't move/turn once initiated). After "charging" for about 1.5 seconds, will dash along the path and damage anyone still in the zone.
>     - If the dash attack hits no players, will become briefly "stunned/dizzy" and take extra damage from attacks until recovered (maybe 3-4 seconds)
>   - (Optional) **Projectile attack**: At medium-long distance, will violently shift in place to fire a projectile. Can be dodged with basic movement or a utility Echo.
>     - Maybe something simple like a large sphere that floats at chest height for a limited distance? Or a ground-level wave in an arc shape?



- Fight a medium-sized miniboss with more aggressive attacks
  - Absorb another combat ability that can't be slotted in with their current abilities due to a Draw limit
  - Can be swapped with a current ability, but any ability not equipped goes to inventory
- A small horde of weak enemies attack, player defeats several
- The horde begins to overwhelm them as some (scripted/fake) "players" save them
  - Can be entirely faked. Just randomly incur attacks on the enemies and occasionally heal the player
- A massive boss enemy arrives defeats some allies
  - Opportunity to show what it looks like when a fellow player is defeated
- Player leaves, causing the ruins to become a new dungeon that must be tackled fresh with a group of players








