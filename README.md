# 阿米娅·炉芯终曲

Godot 4.6 东方 Project 风格 Boss 战 / 弹幕射击游戏原型。当前以阿米娅（Amiya）Boss 战为测试场景，包含弹幕对象池、Boss 状态机、符卡机制、掉落物框架、演出管理、调试控制台和 3 级武器系统。

## 运行

用 **Godot 4.6** 编辑器打开项目目录，运行 `game.tscn` 主场景。无 CLI 构建管线。

## 操作

| 动作 | 按键 |
|------|------|
| 移动 | 方向键 |
| 射击 | Z |
| 集中 | 左 Shift（低速移动 + 僚机收束） |

## 核心系统

### 子弹对象池
`BulletManager` 启动时根据 `BulletData` 资源预创建子弹池，运行时通过 `spawn()` / `recycle()` 取用和回收，避免动态创建。子弹通过 `direction`、`init_speed`、`final_speed`、`acceleration` 控制运动。

子弹回收时会停止绑定到子弹生命周期的 tween，避免对象池复用后旧 tween 继续改写新弹幕的位置。弹幕脚本中需要控制子弹位置的 tween 应优先使用 `Bullet.create_lifecycle_tween()`。

### Pattern 弹幕框架
`Pattern` 节点支持三种模式：时间线（`time_line`，按秒触发）、循环（`is_loop`，固定间隔）、单发（`one_shot`）。子类覆写 `spawn()` 实现具体弹幕样式；`CombinePattern` 可组合多个子 Pattern 统一启停。

### Boss 状态机
自动推进的阶段流程：`idle` → `nonspell`（非符攻击）→ `transition`（转阶段归位）→ `spellcards`（符卡连战）→ 循环。

### 符卡系统
`Spellcard` 拥有独立血量、时限和奖励分。`SpellcardLauncher` 管理符卡序列：符卡击破后自动推进下一张，全部耗尽后返回 idle。

### 武器系统
`launcher.gd` 提供 3 级武器：Lv1 直线单发 → Lv2 扇形散射 → Lv3 散射 + 僚机编队。僚机平滑跟随玩家，共享射击输入，集中时收束至同一点。

### UI 系统
`UIManager` 提供 68/32 左右分屏布局：左侧游戏区域，右侧信息栏（分数 / 残机 / Bomb / Power）。

### 掉落物系统
`DropManager` 是掉落物 Autoload，负责生成、统一销毁和奖励发放。敌人死亡时按 `drop_power_items` / `drop_score_items` 配置生成掉落物。

`DropItem` 是掉落物基类，继承 `Area2D`，自治处理下落、吸附锁定、碰撞拾取和出屏清理。掉落物第一次进入玩家吸附半径后会进入 carried 状态，此后即使玩家离开原吸附范围也会持续追踪玩家；已进入 carried 状态的掉落物不会再因超时或出屏被清理。当前已有 `power_drop.tscn` 与 `score_drop.tscn` 两种基础掉落物：分数掉落调用 `UIManager.add_score()`，Power 掉落调用 `UIManager.add_power()`。

掉落物生成统一走 `DropManager.spawn_drop*` / `spawn_drops*` 接口，支持直接按坐标生成，也支持以某个 `Node2D` 为来源加本地偏移和随机散布生成。调试菜单的掉落物按钮会在当前 Boss 下方生成选中的掉落物，并带随机坐标偏移，便于测试下落、吸附和拾取。

### 演出管理
`PresentationManager` 负责立绘出现、文本展示和剧情对话等演出功能。当前符卡释放时的立绘进场 / 停留 / 退场动画已由它统一管理，符卡启动时通过 `PresentationManager.show_spellcard_announcement()` 播放，并同步播放 `spellcard_activatived` 音效。

### 调试系统
`DebugManager` 是调试单例，集中管理 Boss 状态切换、普攻弹幕选择、扣血、BGM 切换和符卡释放动画预览。主场景 `game.tscn` 下的 `DebugManagerUI` 提供调试控件，不再把调试 UI 分散挂在 Boss 场景内部。

## 目录结构

```
├── project.godot              # 项目配置（autoload、输入映射）
├── game.tscn / game.gd        # 主场景（物理帧率 120）
├── src/
│   ├── core/                  # 单例系统（Audio / Bullet / UI / Game / Drop / Debug / Presentation）
│   │   └── managers/          # 纯脚本 Autoload 的场景壳，用于检查器管理导出变量
│   ├── drops/                 # 掉落物基类与基础掉落物场景
│   ├── boss/                  # Boss 框架（状态机、普攻、符卡）
│   ├── patterns/              # 弹幕框架（Pattern / CombinePattern）
│   ├── player/                # 自机（移动 + 武器发射器）
│   ├── characters/            # 角色实现
│   │   ├── amiya/             #   阿米娅 Boss（场景、状态、专属弹幕）
│   │   ├── enemy/             #   基础敌人与掉落配置
│   │   └── wingmans/          #   僚机编队
│   └── resources/             # 资源类（BulletData / BossAttackSegment）
├── assets/                    # 游戏资源（BGM、子弹贴图、精灵、音效）
└── levels/                    # 关卡场景（预留）
```

## 参考

- [ARCHITECTURE.md](ARCHITECTURE.md) — 详细架构文档与类继承层次
- [project_content.md](project_content.md) — 开发过程日志与设计决策记录
