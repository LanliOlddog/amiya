# 项目架构文档 — 阿米娅·炉芯终曲

## 项目概述

Godot 4.6 弹幕射击游戏原型，灵感来源于东方 Project 的 Boss 战模式。当前以阿米娅为 Boss 的测试场景为主，未接入完整关卡流程。

## 目录结构

```
├── project.godot              # 项目配置（autoload、输入映射、渲染设置）
├── game.tscn / game.gd        # 主场景入口（设置物理帧率 120）
├── CLAUDE.md                  # Claude Code 协作指引
├── ARCHITECTURE.md            # 本文档
├── project_content.md         # 开发过程记录（设计决策日志）
│
├── src/                       # 所有游戏源码
│   ├── core/                  # 单例系统（autoload）
│   │   ├── AudioManager.*     # BGM 淡入淡出、音效播放（含频率限制）
│   │   ├── BulletManager/     # 子弹对象池系统
│   │   ├── GameManager.gd     # 全局状态引用（player、game、武器等级）
│   │   └── UIManager.*       # 全屏 UI 布局 + 符卡立绘动画
│   │
│   ├── boss/                  # Boss 通用框架
│   │   ├── boss.*             # Boss 基类（血量、受伤、死亡信号）
│   │   ├── state.gd           # BossState 基类（enter/exit/update）
│   │   ├── state_machine.gd   # 状态机（手动/自动推进）
│   │   ├── launcher.gd        # BossLauncher（普攻弹幕管理）
│   │   ├── spellcard.gd       # Spellcard（符卡：血量、计时、奖励分）
│   │   └── spellcard_launcher.gd  # 符卡序列管理
│   │
│   ├── patterns/              # 弹幕模式框架
│   │   ├── Pattern.gd         # 弹幕基类（时间线/循环/单发）
│   │   ├── CombinePattern.gd  # 组合弹幕（并行控制多个 Pattern）
│   │   └── normal_attack/     # 通用普攻弹幕实现
│   │
│   ├── characters/            # 具体角色实现
│   │   ├── amiya/             # 阿米娅 Boss
│   │   │   ├── amiya.tscn     # Boss 场景（含 FSM、Launcher、SpellcardLauncher、UI）
│   │   │   ├── State*.gd      # 各状态实现（intro/move/attack/revive/spell_cards）
│   │   │   └── patterns/      # 阿米娅专属弹幕样式
│   │   ├── finalsound/        # 早期原型角色
│   │   ├── enemy/             # 通用敌人
│   │   └── wingmans/          # 玩家僚机编队
│   │
│   ├── player/                # 玩家角色
│   │   ├── player.*           # 角色移动（含集中低速模式）
│   │   └── launcher.gd        # 武器发射器（3 级武器系统 + 僚机管理）
│   │
│   └── resources/             # 资源类定义
│       ├── BulletData.gd      # 子弹数据资源配置
│       └── BossAttackSegment.gd  # Boss 攻击段配置
│
├── assets/                    # 游戏资源
│   ├── BGM/                   # 背景音乐
│   ├── bullets/               # 子弹贴图
│   ├── sounds/                # 音效
│   ├── sprites/               # 角色精灵图
│   └── raw_source/            # 原始素材文件（动画源文件等）
│
└── levels/                    # 关卡场景（目前为空壳）
```

## 核心系统架构

### 1. Autoload 单例（启动顺序等同于 project.godot 中的声明顺序）

| 单例 | 职责 |
|------|------|
| `AudioManager` | BGM 管理：双播放器交叉淡入淡出。SFX 管理：按名称播放，支持频率限制防重叠 |
| `BulletManager` | 子弹对象池：启动时根据 `BulletData` 资源预创建池，提供 `spawn()`/`recycle()`，敌弹清屏 `clear_enemy_bullets()` |
| `UIManager` | UI 布局：68/32 左右分屏，右侧信息栏（分数/残机/Bomb/火力），符卡立绘入场动画 |
| `GameManager` | 游戏状态枚举（6 种状态），持有 `player`、`game` 根节点引用，跟踪武器等级 |

### 2. 子弹系统

```
BulletData (Resource)          → 定义子弹池：场景 + 池大小 + 名称
        ↓
BulletManager._ready()          → 预实例化所有子弹到对象池字典 bullet_pools[name]
        ↓
Pattern.spawn()                 → pool.pop_back() 取弹 → 设置参数 → bullet_on(pos)
        ↓
Bullet._physics_process()       → 运动（方向/速度/加速度）
        ↓
Bullet._on_screen_exited()      → BulletManager.recycle(self) 回收
```

- `Bullet` 是基类（`Area2D`），关键属性：`direction`、`init_speed`、`final_speed`、`acceleration`
- 所有子弹变体（`amiya_bullet`、`amiya_ball`、`light_ball`、`ring` 等）继承 `Bullet`
- 子弹生命周期：池中不可见（`PROCESS_MODE_DISABLED`）→ `bullet_on()` 激活 → `bullet_off()` 或 `recycle()` 回收
- **绝对不要对子弹使用 `queue_free()`**，必须走 `BulletManager.recycle()`

### 3. 弹幕 Pattern 系统

```
Pattern (基类)
├── time_line[]      → 时间线模式：在指定秒数触发 spawn()
├── is_loop          → 循环模式：按 loop_rate 间隔反复 spawn()
├── one_shot         → 单发模式：开始瞬间 spawn() 一次
└── spawn()          → 虚函数，子类覆写实现具体弹幕逻辑
```

- Pattern 挂载在 `BossLauncher.patterns[]` 或 `Spellcard.patterns[]` 中
- `CombinePattern` 可组合多个子 Pattern 统一启停
- 调用链路：`BossLauncher.start_pattern(i)` → `pattern.pattern_on()` → `_physics_process` 计时 → `spawn()`

### 4. Boss 状态机

```
BossStateMachine
├── states: Array[BossState]    → 状态列表
├── auto_change: bool           → true=自动流程，false=手动选择
├── current_state / next_state  → 当前/下一状态
└── _on_amiya_boss_dead()       → Boss 死亡时决定下一状态

BossState (基类)
├── state_name: String          → 状态标识（"nonspell"/"attack"/"spellcards"等）
├── enter() / exit() / update() → 生命周期
```

当前流程：`idle → nonspell → transition → spellcards → idle`

状态切换时，`BossLauncher` 和 `SpellcardLauncher` 监听 `state_change` 信号，根据状态名启停弹幕/符卡。

### 5. 符卡系统

```
Spellcard
├── patterns[]      → 符卡期间激活的弹幕
├── max_hp          → 符卡血量
├── timeout         → 时间限制
├── spell_bonus     → 击破奖励分
├── spellcard_on()  → 激活（播立绘动画 → 启弹幕）
└── _on_break() / _on_timeout() → 击破/超时 → spell_finished 信号

SpellcardLauncher
├── spellcards[]              → 符卡列表
├── current_spellcard_index   → 当前符卡索引
├── start_current_spellcard() → 启动当前符卡（回满 Boss 血量）
└── advance_after_spell_break() → 推进下一符卡（无更多符卡返回 false）
```

### 6. 玩家 / 武器系统

- 移动：`player.gd` 使用 `CharacterBody2D`，方向键控制，`concentrate` 键降低移速
- 武器：`launcher.gd` 三级系统
  - Level 1：直线单发
  - Level 2：扇形 5 路散射
  - Level 3：Level 2 + 僚机编队
- 僚机：3 个单位（morry/kerry/Larry），平滑跟随玩家，共享射击输入，集中时收束到同一点
- 武器等级通过 UI 下拉框选择，运行时可动态切换

## 类继承层次

```
Area2D
├── Bullet (bullet.gd)
│   ├── EnemyBullet (amiya_bullet.gd)
│   ├── RingBullet (light_ball.gd)
│   ├── Lazer (amiya_lazer.gd)
│   ├── PlayerBullet (nifu_normal_bullet.gd)
│   └── ...其他子弹变体
└── Boss (boss.gd)

CharacterBody2D
└── Player (player.gd)

Node2D
├── Pattern (Pattern.gd)
│   ├── SpiralPattern, CirclePattern, ...
│   └── CombinePattern (CombinePattern.gd)
├── BossLauncher (launcher.gd)
├── Spellcard (spellcard.gd)
├── SpellcardLauncher (spellcard_launcher.gd)
└── Enemy (Enemy.gd)

Node
├── BossStateMachine (state_machine.gd)
└── BossState (state.gd)
    ├── StateIntro, StateMove, StateAttack, StateRevive, StateSpellCards

Resource
├── BulletData (BulletData.gd)
└── BossAttackSegment (BossAttackSegment.gd)

Control
└── UIManager (UIManager.gd)
```

## 输入映射

| 动作 | 按键 |
|------|------|
| `shoot` | Z |
| `concentrate` | 左 Shift |
| `ui_left/right/up/down` | 方向键 |

## 关键设计决策

- **物理帧率 120**：在 `game.gd` 和 `GameManager.gd` 中设置，确保弹幕运动平滑
- **子弹对象池而非动态创建**：所有子弹预创建，避免运行时 GC
- **Pattern 时间线模式与循环模式互斥**：`is_loop=true` 时 `time_line` 被清空
- **Boss 死亡时自动清屏**：`boss.gd:take_damage()` 在 HP 归零时调用 `BulletManager.clear_enemy_bullets()`
- **符卡阶段 Boss 血量自动重置**：`SpellcardLauncher.start_current_spellcard()` 调用 `boss.set_hp_full()`
