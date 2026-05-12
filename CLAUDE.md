# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.6 Touhou-style boss fight / bullet hell prototype. The main scene (`game.tscn`) places Amiya (boss), Player, and camera directly — not a full level flow. Physics runs at 120 ticks/sec (set in both `game.gd` and `GameManager.gd`).

Open the project in the Godot editor to run it; there is no CLI build pipeline.

## Autoloads (singletons, in load order)

- `AudioManager` — BGM crossfade via two `AudioStreamPlayer` nodes; SFX with rate-limiting via `play_sound(s, limit_time)`.
- `BulletManager` — creates bullet object pools at startup from `BulletData` resources, provides `spawn()` / `recycle()`, stores pools in `bullet_pools` dictionary keyed by `data.name`. Also provides `clear_enemy_bullets()` for screen-clear on boss phase transitions.
- `UIManager` — full-screen Control with a Touhou-style side panel (68/32 split). Handles spellcard announcement animations (sprite+tween enter/stay/exit). Manages score/life/bomb/power display via `set_scores()` and `set_player_resources()`.
- `GameManager` — holds references to player, game root, and current `player_launcher_level`. Updated each physics frame.

## Architecture

### Bullet system

- `Bullet` (class_name, `src/core/BulletManager/scripts/bullet.gd`): base `Area2D` with `direction`, `init_speed`, `final_speed`, `acceleration`. Variants (amiya_bullet, amiya_ball, amiya_star, ring, light_ball, etc.) extend this class.
- Bullets live in pools under `BulletManager`. Never `free()` them — always `BulletManager.recycle(bullet)`.
- `BulletData` resource: pairs a bullet scene with a `pool_size` and name.

### Pattern system (bullet pattern emit logic)

- `Pattern` (class_name, `src/patterns/Pattern.gd`): base `Node2D`. Has `bullet_type`, `time_line`, `is_loop`, `loop_rate`, `one_shot`. Subclass and override `spawn()` to define a pattern. Call `pattern_on()` / `pattern_off()` to activate/deactivate.
- `CombinePattern`: wraps an array of child `Pattern` nodes and toggles them together.
- Patterns are mounted under a `BossLauncher` or `Spellcard` node's `patterns` array in the scene tree.

### Boss system

- `Boss` (class_name, `Area2D`): health, hurt detection, death signal. On HP zero, calls `BulletManager.clear_enemy_bullets()` then emits `boss_dead`.
- `BossStateMachine`: iterates states in the `states` array. `auto_change` flag controls manual vs automatic progression. States have `enter()` / `exit()` / `update()`. `_on_amiya_boss_dead()` routes death to the appropriate next state (transition or spell break).
- `BossState` (base): has a `state_name` String that `BossLauncher` and `SpellcardLauncher` check to know when to start/stop patterns.
- `BossLauncher`: manages the `patterns` array for normal attacks. Listens to FSM `state_change` for "attack" enter/exit. Provides `start_pattern(i)`, `play_next_pattern()`, `stop_current_pattern()`.
- `Spellcard` (class_name): a single spell card with its own HP, timer, bonus score, `patterns` array. Emits `spell_finished(success)` on break or timeout.
- `SpellcardLauncher`: manages `spellcards` array. On entering "spellcards" state, restores boss HP and starts current spellcard. On spell break, advances to next spellcard; returns false when all are exhausted.

### Player / launcher

- `player.gd`: `CharacterBody2D` movement with `concentrate` slow mode. Delegates firing to `launcher.gd`.
- `launcher.gd`: 3 weapon levels (straight shot → fan spread → fan + wingmen). Wingmen are instanced at runtime under the `Game` root node and self-destruct when level changes away from 3.
- Wingmen (`wingman.gd`): follow player with configurable offset, share the `shoot` input, collapse to `(0, -80)` when concentrating.

### Boss state flow (current)

`idle` → `nonspell` → (HP zero) → `transition` (reposition boss, wait for animation) → `spellcards` → (all spells exhausted) → `idle`

During `nonspell`, `StateMove` cycles through `BossAttackSegment` resources (configured in the scene), each specifying which pattern index to play, duration range, and movement behavior.

## Key files to read first

- `project.godot` — autoloads, input map, display settings
- `game.tscn` — main scene composition
- `src/core/BulletManager/scripts/BulletManager_AutoLoad.gd` — pool init and lifecycle
- `src/patterns/Pattern.gd` — pattern base class
- `src/boss/state_machine.gd` — state transitions
- `src/boss/launcher.gd` — normal attack pattern management
- `src/boss/spellcard.gd` — spell card lifecycle
- `src/boss/spellcard_launcher.gd` — spell card sequencing
- `src/boss/boss.gd` — boss health and damage routing
- `src/characters/amiya/amiya.tscn` — Amiya boss scene with FSM, launchers, UI

## Design context

See `project_content.md` for detailed session history, recent changes, and configuration notes. This is a living design log, not auto-generated docs — read it to understand the "why" behind recent refactors.

## Godot conventions

- `.godot/` is gitignored. If shader cache errors appear (`_load_from_cache`), delete `.godot/` and re-open the project.
- Export groups use Chinese labels in some files — that's intentional, not an error.
