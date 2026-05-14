# 项目记录

## 项目概况

- 这是一个 Godot 4.6 项目，名称为 `阿米娅-炉芯终曲`。
- 主场景是 `game.tscn`。
- 目前项目更像是一个 Boss 战 / 弹幕原型测试场，而不是完整的关卡流程。
- 运行入口场景里直接摆了 `Amiya`、`Player` 和相机。

## 重要 Autoload

- `AudioManager`：`res://src/core/AudioManager.tscn`
- `BulletManager`：`res://src/core/BulletManager/BulletManager.tscn`
- `UIManager`：`res://src/core/UIManager.tscn`
- `GameManager`：`res://src/core/managers/GameManager.tscn`
- `DropManager`：`res://src/core/managers/DropManager.tscn`
- `DebugManager`：`res://src/core/managers/DebugManager.tscn`
- `PresentationManager`：`res://src/core/managers/PresentationManager.tscn`

## 主要架构理解

- `GameManager` 目前主要保存一些全局引用，比如 `player`、`game`、`player_launcher_level`。
- `BulletManager` 会在启动时根据 `BulletData` 资源预先建立敌我子弹对象池。
- `DropManager` 负责掉落物生成、收集奖励发放和统一销毁；掉落物自己的运动与拾取逻辑放在 `DropItem` 中。
- `Pattern` 是弹幕模式的通用基类。
- `CombinePattern` 用来把多个子 Pattern 组合后统一开关。
- `BossStateMachine` 负责 Boss 状态切换。
- `BossLauncher` 会在进入或离开 `attack` 状态时开启或关闭普通攻击 Pattern。
- `SpellcardLauncher` 会在进入或离开 `spellcards` 状态时开启或关闭符卡。
- `core/managers/` 存放纯脚本单例的场景壳，Autoload 仍保持原单例名，打开对应 `.tscn` 即可在检查器中管理脚本导出变量。

## 弹幕系统理解

- 弹幕主要通过场景节点配置，通常挂在 Boss 的 `Launcher` 下，或者挂在某个 `Spellcard` 下。
- 通用配置写在 `patterns/Pattern.gd`。
- 关键基础字段包括：
  - `bullet_type`
  - `time_line`
  - `is_loop`
  - `loop_rate`
  - `one_shot`
- 运行链路是：
  - Boss 状态或符卡激活某个 Pattern
  - Pattern 负责计时
  - 具体 Pattern 子类实现 `spawn()`
  - `spawn()` 从 `BulletManager.bullet_pools[bullet_type]` 中取子弹
  - 子弹的运动主要由 `direction`、`init_speed`、`final_speed`、`acceleration` 控制

## Amiya Boss 相关结论

- `characters/amiya/amiya.tscn` 是当前 `game.tscn` 里实际使用的 Boss 测试场景。
- Amiya 场景中包含：
  - `FSM`
  - 普攻 `Launcher`
  - `SpellcardLauncher`
  - 调试 / 测试 UI
- `FSM` 主要状态有：
  - `idle`
  - `move`
  - `attack`
  - `revive`
  - `spellcards`
- 状态切换下拉框主要用于手动测试。
- 普攻技能选择下拉框同样主要用于测试不同弹幕。

## 已观察到的现状 / 风险

- 当前项目目录不是 Git 仓库根目录。
- `levels/Level1.tscn` 基本是空壳，没有接入当前主测试流程。
- `characters/finalsound` 和 `characters/enemy` 更像早期原型或分支实验。
- 早期记录中的 `data/patterns/spells` 目录已不对应当前 `src/patterns` 结构。
- `boss.gd` 中在符卡激活时，看起来并没有真正把伤害转发到 `active_spellcard.take_damage()`，伤害似乎仍然打在 Boss 本体血量上。
- `Pattern.gd` 中 `is_loop` 分支会清掉 `time_line`，因此当前实现更像是“循环模式”和“时间线模式”二选一，而不是混合设计。

## 僚机系统理解

- 玩家有一套和武器等级绑定的僚机系统。
- 玩家武器等级由 `player.tscn` 里的 `OptionButton` 控制。
- 在 `launcher.gd` 中：
  - level 1 = 直线主炮
  - level 2 = 扇形散射主炮
  - level 3 = level 2 主炮 + 动态僚机编队
- 当武器等级切到 3 时：
  - `add_wingmans()` 会实例化 `res://src/characters/wingmans/wingmans.tscn`
  - 实例会被挂到根节点 `Game` 下
  - 实例名固定为 `wingmans`
- 当武器等级离开 3 时：
  - `delete_wingmans()` 会删除 `Game/wingmans`
- `characters/wingmans/wingmans.tscn` 中有 3 个僚机节点：
  - `morry`
  - `kerry`
  - `Larry`
- 这 3 个僚机都共用脚本 `characters/wingmans/wingman.gd`。
- 每个僚机都会：
  - 平滑跟随玩家
  - 使用各自配置的 `offset`
  - 跟玩家共用 `shoot` 输入进行开火
  - 使用 `wingman_bullet` 对象池发射子弹
- 按住低速 / 集中火力键时：
  - 所有僚机都会把 `current_offset` 改成 `Vector2(0, -80)`
  - 也就是 3 个僚机会收束到同一个位置
- `wingmans.gd` 还会在 `GameManager.player_launcher_level != 3` 时自毁整个编队，相当于额外做了一层保险。
- `wingman_bullet.tres` 复用了普通玩家子弹场景，但单独使用一个对象池名。

## 本次对话中新增的文件

- `codextes/moon_wreath_pattern.gd`
- `codextes/fan_sweep_pattern.gd`
- `codextes/flower_rain_pattern.gd`
- `codextes/sniper_burst_pattern.gd`
- `codextes/README.md`

## 本次新增的示例弹幕

- 这些新的示例弹幕没有改动核心发射逻辑。
- 它们已经接入到 `characters/amiya/amiya.tscn` 中，可以通过 Boss 技能下拉框 `choseskill` 选择。

### 已添加的示例技能

- `MoonWreath`
  - 旋转环形弹
  - 每隔几轮追加朝玩家方向的小扇形点射
- `FanSweep`
  - 持续左右扫动的扇形弹幕
  - 适合压走位
- `FlowerRain`
  - 横向散布的落弹雨
  - 适合制造场压
- `SniperBurst`
  - 朝玩家方向发射的高速扇形狙击弹
  - 密度不高，但点压迫感强

## 本次做过的重要修正

- 新增示例弹幕已经接入 Amiya 的 `Launcher.patterns` 数组。
- 新增示例弹幕的名称已经加入 Amiya UI 的 `choseskill` 下拉框。
- 之前曾误把 `ChoseState.item_count` 从 5 改成 8，导致状态 / 阶段选择下拉框里出现空白选项。
- 这个问题已经修复，`ChoseState.item_count` 已恢复为 5。

## Boss 状态流程改造记录

- 已基于现有状态机把 Boss 流程改得更接近东方 Project 的阶段感。
- `BossStateMachine.auto_change` 默认改为 `true`，让 Boss 自动按阶段流程运行。
- `BossStateMachine._ready()` 会主动调用初始状态的 `enter()`，让开场状态真正执行进入逻辑。
- `StateMove` 被改造成非符阶段控制器，场景中的 `state_name` 已改为 `nonspell`。
- `StateRevive` 在场景中的 `state_name` 已改为 `transition`，现在更像“转阶段”。
- `ChoseState` 下拉框文本同步改为：
  - `idle`
  - `nonspell`
  - `atk`
  - `transition`
  - `spellcards`
- 当前自动流程大致是：
  - `Intro / idle`
  - `NonSpell`
  - Boss 血空后进入 `Transition`
  - `SpellCards`
- 非符阶段 `StateMove` 内部现在会：
  - 在左侧上半区小范围随机滑移
  - 延迟 `first_attack_delay` 后开启当前选中的普攻 Pattern
  - 每隔 `pattern_interval` 自动切到下一个现有 Pattern
  - 每隔 `move_interval` 做一次小位移
  - 退出非符时停止当前 Pattern
- `BossLauncher` 新增了这些接口：
  - `start_pattern(index)`
  - `play_selected_pattern()`
  - `play_next_pattern()`
  - `stop_current_pattern()`
- `BossLauncher` 仍然保留旧的 `attack` 状态联动，方便手动测试。
- 新流程暂时没有重做弹幕样式，只沿用当前 `Launcher.patterns` 中已有的弹幕。

## 非符攻击段配置记录

- 已新增 `data/resources/BossAttackSegment.gd`。
- `BossAttackSegment` 是非符阶段的单个攻击段配置资源。
- 每个攻击段目前可在 Inspector 中配置：
  - `pattern_index`：调用 `Launcher.patterns` 中第几个弹幕
  - `duration_min`
  - `duration_max`
  - `move_before_attack`
  - `move_during_attack`
  - `move_interval`
  - `move_time`
- `characters/amiya/state_move.gd` 已从固定 `pattern_interval` 轮换改为攻击段调度。
- 新调度流程是：
  - 取当前攻击段
  - 如果 `move_before_attack = true`，先移动到新位置
  - 移动结束后开启对应弹幕
  - 从 `duration_min ~ duration_max` 中随机取本轮持续时间
  - 如果 `move_during_attack = true`，持续期间按 `move_interval` 小幅移动
  - 持续时间结束后停止当前弹幕，进入下一攻击段
- `characters/amiya/amiya.tscn` 的 `StateMove` 节点已经配置了 8 个攻击段，对应当前 `Launcher.patterns` 中已有的 8 个弹幕。
- 这次改动没有重写具体弹幕样式，只优化了现有弹幕的阶段持续时间和移动策略。

## 符卡推进与转阶段归位记录

- 非符状态血量被清空后，状态机会进入 `transition`。
- `characters/amiya/state_revive.gd` 的 `transition` 状态现在会把 Boss 拉回左侧活动区域中心点 `Vector2(440, 270)`。
- `transition` 会等待归位移动和 `revive` 动画都完成后，再进入 `spellcards`。
- `characters/boss/spellcard_launcher.gd` 现在维护 `current_spellcard_index`。
- 进入 `spellcards` 时会启动当前索引对应的符卡，并调用 `boss.set_hp_full()` 回满血量。
- 符卡阶段 Boss 血量清空时，状态机会调用 `SpellcardLauncher.advance_after_spell_break()`。
- 如果还有下一张符卡：
  - 停止当前符卡
  - 推进到下一张符卡
  - 回满 Boss 血量
  - 启动下一张符卡
- 如果所有符卡都已使用过一次，当前逻辑会离开符卡状态并回到 `idle`。
- Amiya 当前符卡列表已包含：
  - `TribleSams`
  - `BlackCrown`
- `BlackCrown` 已接入自己的 `crown` Pattern。

## BlackCrown / crown 弹幕记录

- `characters/amiya/crown.gd` 已实现临时符卡弹幕样式。
- 当前效果：
  - 若干个黑色球体围绕 Boss 旋转
  - 每个黑球带白色光晕
  - 环绕半径会在最小半径和最大半径之间按正弦节律呼吸
- 可在 Inspector 中调整的参数包括：
  - `ball_count`
  - `min_radius`
  - `max_radius`
  - `rotation_speed_deg`
  - `breath_period`
  - `start_angle_deg`
  - `ball_scale`
  - `ball_color`
  - `halo_scale_multiplier`
  - `halo_alpha`
  - `halo_color`
- `crown` 复用 `light_ball` 对象池。
- 符卡结束时会回收这些环绕球，并恢复对象池子弹原本的外观状态，避免影响之后复用 `light_ball` 的其他弹幕。

## Boss 血空清屏记录

- 已在 `core/BulletManager/scripts/BulletManager_AutoLoad.gd` 中新增 `clear_enemy_bullets()`。
- `clear_enemy_bullets()` 会清理敌方子弹池和 Boss 子弹池下仍显示的子弹。
- 玩家子弹池不会被清理，因此我方子弹会保留。
- `characters/boss/boss.gd` 的 `take_damage()` 在 Boss 血量第一次降到 0 时会先调用 `BulletManager.clear_enemy_bullets()`，再发出 `boss_dead` 信号。

## UI 分区系统记录

- 已开始实现东方式游玩 UI 分区。
- `core/UIManager.tscn` 已重做为全屏 `Control` 布局。
- 当前画面分为：
  - 左侧游戏运行区域，占屏幕宽度约 68%
  - 右侧信息展示区域，占屏幕宽度约 32%
- 左侧区域目前有淡色边界，用来明确游戏窗口范围。
- 右侧区域目前是深色信息栏，并预留了这些显示项：
  - `STAGE SCORE`
  - `TOTAL SCORE`
  - `GRAZE SCORE`
  - `LIFE`
  - `BOMB`
  - `POWER`
- 右侧底部暂时用文字 `阿米娅\n炉芯终曲` 作为标题 Logo 占位。
- `core/UIManager.gd` 现在继承 `Control`，并保留原有符卡立绘宣言接口 `spellcard_announcement()`。
- `UIManager.gd` 新增了临时数据接口：
  - `set_scores(new_stage_score, new_total_score)`
  - `set_graze_score(new_graze_score)`
  - `set_player_resources(new_lives, new_bombs, new_power)`
  - `add_score(amount)`
  - `add_graze_score(amount)`
  - `add_power(amount)`
  - `refresh_status_panel()`
- 当前已知分数字段：
  - `characters/boss/spellcard.gd` 中有 `spell_bonus`
  - `characters/enemy/Enemy.gd` 中有 `drop_power_items` 和 `drop_score_items`
- 目前还没有正式接入完整分数、残机和 B 数系统，右侧栏先显示占位值。

## 掉落物系统记录

- 已新增 `core/DropManager.gd`，并通过 `core/managers/DropManager.tscn` 注册为 Autoload。
- `DropManager` 当前职责：
  - `spawn_drop(type, position, value := 1, spread := Vector2.ZERO)`：在指定坐标附近生成单个掉落物。
  - `spawn_drop_from_node(type, source, local_offset := Vector2.ZERO, value := 1, spread := default_drop_spread)`：以某个节点为来源生成单个掉落物。
  - `spawn_drops(position, power_count, score_count, spread := default_drop_spread)`：按数量批量生成 Power / Score 掉落物。
  - `spawn_drops_from_node(source, power_count, score_count, local_offset := Vector2.ZERO, spread := default_drop_spread)`：以某个节点为来源批量生成掉落物，供敌人死亡、符卡击破等场景复用。
  - `collect_drop(drop_item)`：根据 `drop_type` 发放奖励。
  - `despawn_drop(drop_item)`：统一销毁掉落物；当前版本直接 `queue_free()`，后续可以替换为对象池回收。
- 已新增 `drops/DropItem.gd` 作为掉落物基类。
- `DropItem` 继承 `Area2D`，自身处理：
  - 自然下落。
  - 第一次进入玩家吸附半径后进入 `_be_carried` 状态。
  - 进入 `_be_carried` 后会持续追踪玩家，不会因为玩家离开原吸附范围而取消吸附。
  - 碰撞到 `player` group 后调用 `DropManager.collect_drop(self)`。
  - 未进入 `_be_carried` 的掉落物超过 `life_time` 或离开视口扩展范围后调用 `DropManager.despawn_drop(self)`。
  - 已进入 `_be_carried` 的掉落物不会因 `life_time` 或出屏清理，只等待被玩家拾取。
- 已新增基础场景：
  - `drops/power_drop.tscn`：`drop_type = "power"`，暂用 `assets/bullets/star.png` 作为占位贴图。
  - `drops/score_drop.tscn`：`drop_type = "score"`，暂用 `assets/bullets/light_dot.png` 作为占位贴图。
- `characters/enemy/Enemy.gd` 的 `drop_items()` 已接入：
  - `DropManager.spawn_drops_from_node(self, drop_power_items, drop_score_items)`
- 调试菜单的掉落物生成按钮会以当前 Boss 为来源，在 Boss 下方生成，并带随机坐标偏移。
- `DropManager.default_drop_spread` 可通过 `core/managers/DropManager.tscn` 在检查器中调整默认随机散布范围。
- 调试生成掉落物的 Boss 下方偏移和随机散布可通过 `game.tscn` 中 `DebugManagerUI` 的导出变量调整：
  - `debug_drop_boss_offset`
  - `debug_drop_spread`
- `player.gd` 在 `_ready()` 中加入 `player` group，供掉落物识别拾取目标。
- 当前奖励行为：
  - `score` 掉落调用 `UIManager.add_score(value)`。
  - `power` 掉落调用 `UIManager.add_power(value)`。
  - 未识别的 `drop_type` 会 `push_warning()`，然后销毁掉落物，不让游戏崩溃。
- 当前版本只更新右侧 UI 的 Power 数值，不改变玩家武器等级。

## 符卡演出音效记录

- 已新增音效资源：
  - `assets/sounds/spellcard_activatived.wav`
- `core/AudioManager.tscn` 的 `SFX` 节点下新增同名 `AudioStreamPlayer`：
  - `spellcard_activatived`
- `PresentationManager.show_spellcard_announcement()` 播放符卡立绘动画时会同步调用：
  - `AudioManager.play_sound("spellcard_activatived", 0.0)`
- `PresentationManager.gd` 新增导出变量：
  - `spellcard_announcement_sound`
- 该变量可通过 `core/managers/PresentationManager.tscn` 在检查器中调整。

## 玩家受击、Bomb 与 Game Over 记录

- `player.tscn` 下新增了 `HitPoint` 判定点和 `Bomb` 子节点。
- `player.gd` 现在集中处理玩家受击模块：
  - `HitPoint.area_entered` 监听敌人和敌方子弹。
  - 受击后先进入短暂 deathbomb 判定窗口，而不是立刻死亡。
  - 若窗口内按下 `bomb` 输入（当前绑定 X 键），会调用 `Bomb.activate(true)`。
  - Bomb 成功后会扣除 `UIManager.bombs`，刷新右侧 UI，清除敌方子弹，并取消本次死亡判定。
  - 普通死亡会扣除 `UIManager.lives`，清除敌方子弹，隐藏玩家并关闭判定。
  - life 仍大于 0 时，玩家会延迟复活到左侧游戏区域下方中央，并进入 3 秒无敌状态。
- `src/player/bomb.gd` 当前是开发期 Bomb 节点脚本：
  - `activate(is_deathbomb := false)` 检查 B 数。
  - B 数不足时打印 `没有可用炸弹` 并返回 `false`。
  - B 数足够时扣除 1 个 Bomb，刷新 UI，打印 `释放炸弹`，发出 `started` 信号。
- `project.godot` 新增 `bomb` 输入动作，暂时绑定键盘 X。
- 玩家复活位置不再使用整个 viewport 中心，而是使用左侧游戏区域宽度的中心点，避免复活到右侧 UI 信息栏。
- 玩家 life 扣到 0 时会调用 `GameManager.game_over()`，不再进入复活流程。
- `UIManager.tscn` 新增 `GameOverOverlay`：
  - 显示 `GAME OVER` 字样。
  - 包含 `RESTART` 按钮。
  - 覆盖范围限制在左侧游戏区域。
- `UIManager.gd` 新增 `restart` 信号，以及 `show_game_over()` / `hide_game_over()`。
- `GameManager.gd` 新增开发期 Restart 流程：
  - 重置游戏状态到 `PLAYING`。
  - 重置 life、bomb、power。
  - 清除敌方子弹。
  - 停止当前符卡并重置符卡序列。
  - 重置 Boss 血量和 Boss 状态机阶段。
  - 重置玩家位置、死亡 / 无敌 / 被弹状态。
  - 重置玩家火力等级。
  - 调用 `LevelManager.reset_progress()` 重置当前关卡进度。
- `BossStateMachine` 新增 `reset_phase()`，用于 Restart 时回到初始阶段。
- `player/launcher.gd` 新增 `reset_firepower(new_level := 1)`，用于 Restart 时恢复默认火力等级。
- `game.tscn` 的 `LevelManager` 节点现在挂载 `src/core/LevelManager.gd`。
- `LevelManager.gd` 当前只保存轻量进度字段：
  - `default_progress`
  - `current_progress`
  - `reset_progress()`
  - `progress_reset` 信号

## 子弹回收安全修正记录

- 测试 Game Over 后 Restart 时观察到 Godot 报错：
  - `Disabling a CollisionObject node during a physics callback is not allowed`
- 原因是敌方子弹在 `bullet.gd::_on_area_entered()` 这种物理回调里直接调用 `BulletManager.recycle()`。
- 旧的 `recycle()` 会立刻执行 `bullet_off()`，而 `bullet_off()` 会停用节点处理 / 碰撞相关状态，Godot 4 不允许在物理回调当帧这样做。
- `BulletManager.recycle()` 现在改为：
  - 不在 physics frame 时，照常立即完成回收。
  - 在 physics frame 中时，先把子弹 `is_active` 设为 `false`，再用 `call_deferred("_finish_recycle", ...)` 延迟真正回收。
  - `_finish_recycle()` 会做 `is_instance_valid()` 和重复回收保护。
- 这样可以避免同一颗子弹在延迟回收前被重复放回对象池，也避免物理回调中直接禁用碰撞对象的报错。

## 玩家擦弹记录

- `player.tscn` 下新增 `GrazeArea` 节点，并配置了独立的擦弹范围 CollisionShape。
- `GrazeArea` 当前碰撞配置为：
  - `collision_layer = 2`
  - `collision_mask = 16`
- `player.gd` 已整理为按功能分块的结构：
  - 移动 / 生存配置
  - 节点引用
  - 运行状态
  - 信号
  - 生命周期
  - 移动 / 射击
  - 受击 / Bomb
  - 擦弹
  - 死亡 / 复活 / 无敌
  - Restart / 位置辅助
- 擦弹判定写在 `player.gd` 中：
  - `GrazeArea.area_entered` 连接到 `_on_graze_area_area_entered(area)`。
  - 只接受 `enemybullets` group 的 Area2D。
  - 玩家死亡、无敌、deathbomb 判定窗口中不会产生擦弹。
  - 每次擦弹默认加 `graze_score_value = 10`。
  - 擦弹成功后调用 `UIManager.add_graze_score(graze_score_value)`。
  - 擦弹信号为 `player_grazed(bullet, score)`。
- 同一颗子弹只会结算一次擦弹：
  - 擦弹成功后给子弹设置 metadata：`player_grazed = true`。
  - 再次进入 `GrazeArea` 时检测到该 metadata 就不会重复加分。
- `Bullet.bullet_on()` 会在子弹从对象池重新激活时清除 `player_grazed` metadata。
- `UIManager` 新增独立擦弹分：
  - 字段：`graze_score`
  - 接口：`set_graze_score(new_graze_score)`
  - 接口：`add_graze_score(amount)`
  - 显示节点：`RightPanel/Info/GrazeScoreLabel`
- 擦弹分显示在 `TOTAL SCORE` 下一行，当前不计入 `TOTAL SCORE`。
- `amiya_normal_bullet.tscn` 的普通敌弹场景在本轮也有场景侧调整，包括子弹缩放和 Godot 写入的 `unique_id`。
- `characters/amiya/amiya.tscn` 中 `HurtBox.visible = false` 的场景属性行被移除，属于本轮一并提交的场景状态更新。

## Autoload 场景壳迁移记录

- 已新增 `core/managers/`，用于集中存放挂载单例脚本的场景。
- 已把这些纯脚本 Autoload 从 `.gd` 路径迁移为 `.tscn` 路径：
  - `GameManager`
  - `DropManager`
  - `DebugManager`
  - `PresentationManager`
- 单例名称保持不变，因此现有代码中的 `GameManager`、`DropManager`、`DebugManager`、`PresentationManager` 全局访问方式不需要改。
- 脚本仍保留在 `core/` 下，`managers/*.tscn` 只作为检查器可编辑的挂载外壳。
- `AudioManager`、`BulletManager`、`UIManager` 原本就是场景 Autoload，本次暂不移动。

## Shader 缓存日志说明

- 讨论过这条 Godot 日志：
  - `_load_from_cache: Condition "header != String(shader_file_header)" is true. Returning: false`
- 当前结论：
  - 这通常是 shader 缓存不匹配或缓存过期
  - 如果项目还能正常运行，往往可以先忽略
  - 如果需要清理，可以删除项目下的 `.godot` 目录后重新打开项目，让缓存重新生成

## 目前最值得优先重看的文件

- `project.godot`
- `game.tscn`
- `core/managers/GameManager.tscn`
- `core/managers/DropManager.tscn`
- `core/managers/DebugManager.tscn`
- `core/managers/PresentationManager.tscn`
- `core/GameManager.gd`
- `core/LevelManager.gd`
- `core/DropManager.gd`
- `core/BulletManager/scripts/BulletManager_AutoLoad.gd`
- `core/BulletManager/scripts/bullet.gd`
- `core/UIManager.gd`
- `drops/DropItem.gd`
- `patterns/Pattern.gd`
- `characters/boss/state_machine.gd`
- `characters/boss/launcher.gd`
- `characters/boss/spellcard.gd`
- `characters/amiya/amiya.tscn`
- `player/player.gd`
- `player/player.tscn`
- `player/launcher.gd`
- `player/bomb.gd`
- `characters/wingmans/wingman.gd`
- `characters/wingmans/wingmans.tscn`

## 这份文件的用途

- 这份文件用于保留当前对话中已经确认的重要项目上下文。
- 如果后续聊天窗口上下文被冲掉，继续讨论或继续开发前，应优先阅读这份文件来恢复项目背景。
