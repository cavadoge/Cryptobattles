# GameManager.gd
# adding comments to test git
extends Node

@export var market_update_interval: float = 30.0
@export var community_update_interval: float = 120.0
@export var chat_update_interval_min: float = 5.0
@export var chat_update_interval_max: float = 15.0

@onready var event_manager = $Event_Manager
@onready var market_manager = $Market_Manager
@onready var community_manager = $Community_Manager
@onready var chat_ui = $ChatUI # Assuming you have a ChatUI node

func _ready():
	_setup_timers()

func _setup_timers():
	# Market Update Timer
	var market_timer = Timer.new()
	market_timer.wait_time = market_update_interval
	market_timer.one_shot = false
	add_child(market_timer)
	market_timer.timeout.connect(_on_market_timeout)
	market_timer.start()

	# Event Trigger Timer (Randomized using arrays and jitter)
	_start_random_event_timer()

	# Community Sentiment Timer
	var community_timer = Timer.new()
	community_timer.wait_time = community_update_interval
	community_timer.one_shot = false
	add_child(community_timer)
	community_timer.timeout.connect(_on_community_timeout)
	community_timer.start()

	# Chat Update Timer (Randomized)
	_start_random_chat_timer()

# Updated random event timer using two arrays and a random jitter modifier.
func _start_random_event_timer():
	# Define the base delays (in seconds)
	var base_delays = [300, 600, 1200, 1800]
	# Define the jitter values (in seconds)
	var jitter_values = [10, 30, 60, 100, 120, 150]
	
	# Randomly select a base delay from the array.
	var base_delay = base_delays[randi() % base_delays.size()]
	
	# Randomly select a jitter value.
	var jitter = jitter_values[randi() % jitter_values.size()]
	
	# Randomly decide whether to add or subtract the jitter.
	var sign = (randf() < 0.5) ? -1 : 1
	
	# Calculate the final delay.
	var delay = base_delay + (jitter * sign)
	
	# Optionally, you could clamp the delay if you need it to stay within a certain range:
	# delay = clamp(delay, 300, 1200)  # For example, between 5 and 20 minutes.
	
	var event_timer = Timer.new()
	event_timer.wait_time = delay
	event_timer.one_shot = true
	add_child(event_timer)
	event_timer.timeout.connect(_on_event_timeout)
	event_timer.start()

func _start_random_chat_timer():
	var chat_timer = Timer.new()
	chat_timer.wait_time = randf_range(chat_update_interval_min, chat_update_interval_max)
	chat_timer.one_shot = true
	add_child(chat_timer)
	chat_timer.timeout.connect(_on_chat_timeout)
	chat_timer.start()

func _on_market_timeout():
	if market_manager:
		market_manager.update_market()

func _on_event_timeout():
	if event_manager:
		event_manager.trigger_cycle_event(randi()) # You may want a more sophisticated event selection
	_start_random_event_timer() # Reset the random timer

func _on_community_timeout():
	if community_manager:
		community_manager.update_sentiment()

func _on_chat_timeout():
	if chat_ui:
		chat_ui.refresh_chat() # Assuming ChatUI has a refresh_chat function
	_start_random_chat_timer() # Reset the random timer
