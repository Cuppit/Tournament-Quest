extends Control

var BChoice = Global.BattleChoice
var charDB = Global.characterDB

## Transparency to set character portraits to
const HIGHLIGHT_SETTING = Color(1.00, 1.00, 1.00, 1.00)
const TRANS_SETTING = Color(1.00, 1.00, 1.00, 0.40)

var battle = Global.scenarioDB[Global.curr_scenario][Global.curr_battle]
var player = GameCharacter.new()

## Shorthand variables for the actual character objects
var opponent1:GameCharacter = null
var opponent2:GameCharacter = null
var opponent3:GameCharacter = null

var curr_chosen_opponent = null

## reads character information for each battle, and populates UI info with each
## (e.g. portrait, name)
func initialize_ui():
	if opponent1 != null:
		$Background/VBoxContainer/HBoxContainer/BtnPackOpponent1/BtnNameOpponent1.text = battle[BChoice.OPPONENT1]
		print("texture status of battle opponent '",opponent1.character_name,"': ",opponent1.character_portrait)
		if opponent1.character_portrait != null:
			$Background/VBoxContainer/HBoxContainer/BtnPackOpponent1/BtnOpponent1.texture_normal = opponent1.character_portrait

	if opponent2 != null:
		$Background/VBoxContainer/HBoxContainer/BtnPackOpponent2/BtnNameOpponent2.text = battle[BChoice.OPPONENT2]
		print("texture status of battle opponent '",opponent2.character_name,"': ",opponent2.character_portrait)
		if opponent2.character_portrait != null:
			$Background/VBoxContainer/HBoxContainer/BtnPackOpponent2/BtnOpponent2.texture_normal = opponent2.character_portrait


	if opponent3 != null:
		$Background/VBoxContainer/HBoxContainer/BtnPackOpponent3/BtnNameOpponent3.text = battle[BChoice.OPPONENT3]
		print("texture status of battle opponent '",opponent3.character_name,"': ",opponent3.character_portrait)
		if opponent3.character_portrait != null:
			$Background/VBoxContainer/HBoxContainer/BtnPackOpponent3/BtnOpponent3.texture_normal = opponent3.character_portrait

#	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent1/BtnNameOpponent2.text = battle[BChoice.OPPONENT2].character_name
#	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent1/BtnNameOpponent3.text = battle[BChoice.OPPONENT3].character_name
	
	
	
func select_opponent(chosen:Global.BattleChoice):
	Global.curr_battle_choice = chosen
	curr_chosen_opponent = chosen
	var descriptions = Global.generate_scenario_battle_descriptions(Global.curr_scenario, Global.curr_battle)
	# -- Update the button highlights --
	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent1.modulate = \
		HIGHLIGHT_SETTING if chosen == BChoice.OPPONENT1 else TRANS_SETTING
	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent2.modulate = \
		HIGHLIGHT_SETTING if chosen == BChoice.OPPONENT2 else TRANS_SETTING
	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent3.modulate = \
		HIGHLIGHT_SETTING if chosen == BChoice.OPPONENT3 else TRANS_SETTING
	
	$Background/VBoxContainer/navBtnsRows/StartButton.visible = true
	
	# -- Update character description boxes
	$Background/VBoxContainer/HBoxContainer2/Description/richTxtLblDesc.text=descriptions[chosen]['description']
	$Background/VBoxContainer/HBoxContainer2/Strategy/richTxtLblStrategy.text=descriptions[chosen]['strategy']	
	$Background/VBoxContainer/HBoxContainer2/Rewards/RichTxtLblRewards.text=descriptions[chosen]['rewards']
	
	
func _on_btn_opponent1_pressed():
	select_opponent(BChoice.OPPONENT1)


func _on_btn_opponent2_pressed():
	select_opponent(BChoice.OPPONENT2)


func _on_btn_opponent3_pressed():
	select_opponent(BChoice.OPPONENT3)


func _on_start_button_pressed():
	var char_to_load
	if curr_chosen_opponent == BChoice.OPPONENT1:
		char_to_load=charDB[battle[BChoice.OPPONENT1]]
	elif curr_chosen_opponent == BChoice.OPPONENT2:
		char_to_load=charDB[battle[BChoice.OPPONENT2]]
	elif curr_chosen_opponent == BChoice.OPPONENT3:
		char_to_load=charDB[battle[BChoice.OPPONENT3]]
	
	
	var params = {
		"player_character": player,
		#"opponent": Global.characterDB["Goblin"]
		"opponent": Global.characterDB[Global.scenarioDB[Global.curr_scenario][Global.curr_battle][Global.curr_battle_choice]].copy_character()
	}
	GGT.change_scene("res://scenes/battle_ui/battle_ui.tscn", params)
	
func _ready():
	#print("Keys for curr scenario: ",Global.Scen)
	var params = GGT.get_current_scene_data().params
	player = params["player_character"]
	battle = Global.scenarioDB[Global.curr_scenario][Global.curr_battle]
	
	if battle[BChoice.OPPONENT1] != null:
		opponent1 = Global.characterDB[battle[BChoice.OPPONENT1]]
	if battle[BChoice.OPPONENT2] != null:
		opponent2 = Global.characterDB[battle[BChoice.OPPONENT2]]	
	if battle[BChoice.OPPONENT3] != null:
		opponent3 = Global.characterDB[battle[BChoice.OPPONENT3]]	
	
	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent1.visible = true if battle[BChoice.OPPONENT1] != null else false
	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent2.visible = true if battle[BChoice.OPPONENT2] != null else false
	$Background/VBoxContainer/HBoxContainer/BtnPackOpponent3.visible = true if battle[BChoice.OPPONENT3] != null else false
	initialize_ui()
	pass

## Takes the player back to the Character management screen
func _on_char_manage_button_pressed():
	var params = {
		"char_to_manage": player,
	}
	#Global.scene_change_params = params
	GGT.change_scene("res://scenes/charactermanagement/character_management.tscn",params)
