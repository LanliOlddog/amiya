extends Node

@onready var enemy_bullet_pool: Node = $BulletPool/EnemyBulletPool
@onready var player_bullet_pool: Node = $BulletPool/PlayerBulletPool
@onready var boss_bullet_pool: Node = $BulletPool/BossBulletPool

@export var enemy_bullet_datas:Array[Resource]
@export var player_bullet_datas:Array[Resource]

var bullet_pools :Dictionary = {}

func _ready() -> void:
	initialize_enemy_bullet_pool()
	initialize_player_bullet_pool()
	#print(pools["amiya_normal"])

func initialize_enemy_bullet_pool():
	#遍历所有子弹数据
	for data in enemy_bullet_datas:
		#对单个子弹数据建立对象池数组
		var new_pool:Array[Node] = []
		#建立对象池节点
		var p = Node.new()
		p.name = data.name
		#获取data中的场景
		var scene = data.scene
		#根据size实例化
		for i in range(data.pool_size):
			var b = scene.instantiate()
			b.name = data.name + str(i)
			b.pool_name = data.name
			b.add_to_group("enemybullets")
			new_pool.append(b)
			p.add_child(b)
		bullet_pools[data.name] = new_pool
		enemy_bullet_pool.add_child(p)
		print("对象池已创建: %s (数量: %d)" % [data.name, data.pool_size])

func initialize_player_bullet_pool():
	for data in player_bullet_datas:
		#对单个子弹数据建立对象池数组
		var new_pool:Array[Node] = []
		#建立对象池节点
		var p = Node.new()
		p.name = data.name
		#获取data中的场景
		var scene = data.scene
		#根据size实例化
		for i in range(data.pool_size):
			var b = scene.instantiate()
			b.name = data.name + str(i)
			b.pool_name = data.name
			b.add_to_group("playerbullets")
			new_pool.append(b)
			p.add_child(b)
		bullet_pools[data.name] = new_pool
		player_bullet_pool.add_child(p)
		print("对象池已创建: %s (数量: %d)" % [data.name, data.pool_size])
		
##发射特定子弹的池子（好像都没怎么用过）
func spawn(bullet_name:String,pos:Vector2):
	var target_pool =bullet_pools[bullet_name]
	if target_pool.is_empty():
		print_debug("对象池已空，请增大")
		return
	var bullet = target_pool.pop_back()
	bullet.bullet_on(pos)

func mark_bullet_active(b: Bullet):
	var pid = b.pool_name
	if not bullet_pools.has(pid):
		return
	while bullet_pools[pid].has(b):
		bullet_pools[pid].erase(b)
	
func recycle(b:Bullet):
	if not b.is_active:
		return
	var pid = b.pool_name
	if bullet_pools.has(pid):
		b.bullet_off()
		if not bullet_pools[pid].has(b):
			bullet_pools[pid].append(b)
	else:
		b.queue_free()

func clear_enemy_bullets():
	clear_bullets_under(enemy_bullet_pool)
	clear_bullets_under(boss_bullet_pool)

func clear_bullets_under(root: Node):
	for child in root.get_children():
		if child is Bullet:
			if child.visible:
				recycle(child)
		else:
			clear_bullets_under(child)
