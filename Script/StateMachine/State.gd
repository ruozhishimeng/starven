extends Node
class_name State
## 状态基类
## 所有具体状态（如 player_idle, player_run）都应该继承这个类
##
## 【小白理解】
## 想象一个游戏角色：
## - 待机状态：站着不动，等你操作
## - 移动状态：正在走路
## - 攻击状态：正在挥拳
##
## 每个状态都有：
## - 进入（Enter）：刚进入这个状态时要做的事
## - 退出（Exit）：离开这个状态时要清理的事
## - 更新（process/physics_process）：每帧都在做的事
## - 输入处理（handle_input）：响应你的按键

## 引用所属的状态机，用于切换状态
var state_machine : StateMachine

## 【小白的重点】
## character 是谁？就是这个状态所在的 StateMachine 的父节点！
## 例如：Player 节点下有 StateMachine，StateMachine 下有 idle 状态
## 那么 idle.character 就是 Player！可以访问 Player 的 velocity、SPEED 等
var character: Node2D:
	get:
		return state_machine.get_parent()

## ============================================
## 生命周期方法 - 状态机的"开关"
## ============================================

## 进入状态时调用一次
## 【小白的重点】在这里做状态的初始化
## 例如：播放待机动画、设置初始速度为零
func Enter() -> void:
	pass

## 退出状态时调用一次
## 【小白的重点】在这里清理状态留下的痕迹
## 例如：停止动画、清除临时变量
func Exit() -> void:
	pass

## 状态刚创建好时调用（类似 _ready）
## 【小白的重点】这里放只执行一次的初始化逻辑
func Ready() -> void:
	pass

## ============================================
## 每帧更新方法 - 状态的核心
## ============================================

## 每帧调用（用于视觉、UI等）
## 【小白的重点】这里放不涉及物理的逻辑
## 例如：播放动画、检测距离、更新时间
## delta = 距离上一帧过了多少秒（通常约0.016秒）
func Process(delta: float) -> void:
	pass

## 每物理帧调用（用于物理移动）
## 【小白的重点】这里放涉及物理的逻辑
## 例如：应用重力、移动角色、检测碰撞
## delta = 距离上一帧过了多少秒
func PhysicsProcess(delta: float) -> void:
	pass

## 处理输入事件
## 【小白的重点】当玩家按键时，这里可以响应
## event = 发生了什么输入事件（按键、鼠标等）
func HandleInput(event: InputEvent) -> void:
	pass
