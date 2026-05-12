# Codex Test Patterns

## `moon_wreath_pattern.gd`

这是一个不依赖新增管理器逻辑的 `Pattern` 子类，可以直接在 Godot 里手动挂到 Boss 的 `Launcher` 或 `Spellcard` 下面测试。

建议初始配置：

- `bullet_type`: `amiya_normal`
- `is_loop`: `true`
- `loop_rate`: `0.12`
- `ring_ways`: `12`
- `burst_every`: `5`

效果：

- 持续发出旋转环形弹
- 每若干轮朝玩家方向追加一组扇形点射

手动接入方式：

1. 在 Boss 的某个 `Launcher` 或 `Spellcard` 节点下新建一个 `Node2D`
2. 给这个节点挂上 `codextes/moon_wreath_pattern.gd`
3. 在 Inspector 里把它的 `bullet_type` 设成已有对象池名字，比如 `amiya_normal`
4. 把这个新节点拖进对应的 `patterns` 数组

说明：

- 这个脚本不会修改现有代码或节点
- 如果对象池数量不够，脚本会直接停止继续取弹，不会报额外依赖错误

## `fan_sweep_pattern.gd`

建议初始配置：

- `bullet_type`: `amiya_normal`
- `is_loop`: `true`
- `loop_rate`: `0.09`

效果：

- 一组扇形弹幕持续左右扫动
- 适合做压走位的中密度普攻

## `flower_rain_pattern.gd`

建议初始配置：

- `bullet_type`: `amiya_ball`
- `is_loop`: `true`
- `loop_rate`: `0.35`

效果：

- 从 Boss 横向范围内洒下多枚球弹
- 子弹起速较慢，随后轻微加速，适合做场压

## `sniper_burst_pattern.gd`

建议初始配置：

- `bullet_type`: `amiya_normal`
- `is_loop`: `true`
- `loop_rate`: `0.55`

效果：

- 朝玩家方向发一组高速扇形狙击弹
- 密度不高，但压迫感强
