extends Resource
class_name BulletData

## 子弹的唯一标识符
@export var name:String
## 该种子弹对应的场景文件 (.tscn)
@export var scene:PackedScene

## 游戏开始时预加载的数量
@export var pool_size: int = 500
