extends Control

# Character stats

var char_to_mng
var Stat = Global.Stat



# Called when the node enters the scene tree for the first time
func _ready():
	var params = GGT.get_current_scene_data().params
	char_to_mng = params.char_to_mng if "char_to_mng" in params.keys() else GameCharacter.new()
	#  Finally, update the UI
	update_ui()

# Update the UI elements
func update_ui():
	$HBoxContainer/VBoxContainer/LevelLabel.text = "Level: " + str(char_to_mng.get_char_lvl())
	$HBoxContainer/VBoxContainer/XpLabel.text = "XP: " + str(char_to_mng.experience_points)
	$HBoxContainer/VBoxContainer/LevelUpCostLabel.text = "Cost to Level Up: " + str(char_to_mng.get_char_lvl() + 1)
	#$HBoxContainer/VBoxContainer/HBoxContainer.get_node(stat + "Label").text = stat + ": " + str(stats[stat])

	$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer/STRLabel.text = "STR" + ": " + str(char_to_mng.get_stat(Stat.STR))
	$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer2/DEXLabel.text = "DEX" + ": " + str(char_to_mng.get_stat(Stat.DEX))
	$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer3/CONLabel.text = "CON" + ": " + str(char_to_mng.get_stat(Stat.CON))
	$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer4/INTLabel.text = "INT" + ": " + str(char_to_mng.get_stat(Stat.INT))
	$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer5/WISLabel.text = "WIS" + ": " + str(char_to_mng.get_stat(Stat.WIS))
	$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer6/CHALabel.text = "CHA" + ": " + str(char_to_mng.get_stat(Stat.CHA))
	
	$HBoxContainer/VBoxContainer2/rtlMaxHP.text = str("Max HP: ",char_to_mng.get_stat(Stat.MAX_HP))
	$HBoxContainer/VBoxContainer2/rtlMaxMP.text = str("Max MP: ",char_to_mng.get_stat(Stat.MAX_MP))
	$HBoxContainer/VBoxContainer2/rtlAccuracy.text = str("Accuracy: ",char_to_mng.get_stat(Stat.ACC))
	$HBoxContainer/VBoxContainer2/rtlDamage.text = str("Damage: ",char_to_mng.get_stat(Stat.DMG))
	$HBoxContainer/VBoxContainer2/rtlEvade.text = str("Evade: ",char_to_mng.get_stat(Stat.EVADE))
	$HBoxContainer/VBoxContainer2/rtlDamageReduc.text = str("Damage Reduction: ",char_to_mng.get_stat(Stat.DMG_REDUC))
	$HBoxContainer/VBoxContainer2/rtlSpecAccuracy.text = str("Special Accuracy: ",char_to_mng.get_stat(Stat.SPEC_ACC))
	$HBoxContainer/VBoxContainer2/rtlSpecDamage.text = str("Special Damage: ",char_to_mng.get_stat(Stat.SPEC_DMG))
	$HBoxContainer/VBoxContainer2/rtlSpecEvade.text = str("Special Evade: ",char_to_mng.get_stat(Stat.SPEC_EVADE))
	$HBoxContainer/VBoxContainer2/rtlSpecDamageReduc.text = str("Special Damage Reduction: ",char_to_mng.get_stat(Stat.SPEC_DMG_REDUC))
	
	
	
	## Update button text based on available XP
	if char_to_mng.experience_points > char_to_mng.get_char_lvl():
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer/IncreaseSTRButton.text = "Level Up"
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer/IncreaseSTRButton.disabled = false
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer2/IncreaseDEXButton.text = "Level Up"
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer2/IncreaseDEXButton.disabled = false
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer3/IncreaseCONButton.text = "Level Up"
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer3/IncreaseCONButton.disabled = false
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer4/IncreaseINTButton.text = "Level Up"
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer4/IncreaseINTButton.disabled = false
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer5/IncreaseWISButton.text = "Level Up"
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer5/IncreaseWISButton.disabled = false
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer6/IncreaseCHAButton.text = "Level Up"
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer6/IncreaseCHAButton.disabled = false
	
	else:
		var to_lvl = (char_to_mng.get_char_lvl() - char_to_mng.experience_points)+1
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer/IncreaseSTRButton.text = str("Level Up (need ",to_lvl," more XP")
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer/IncreaseSTRButton.disabled = true
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer2/IncreaseDEXButton.text = str("Level Up (need ",to_lvl," more XP")
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer2/IncreaseDEXButton.disabled = true
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer3/IncreaseCONButton.text = str("Level Up (need ",to_lvl," more XP")
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer3/IncreaseCONButton.disabled = true
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer4/IncreaseINTButton.text = str("Level Up (need ",to_lvl," more XP")
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer4/IncreaseINTButton.disabled = true
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer5/IncreaseWISButton.text = str("Level Up (need ",to_lvl," more XP")
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer5/IncreaseWISButton.disabled = true
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer6/IncreaseCHAButton.text = str("Level Up (need ",to_lvl," more XP")
		$HBoxContainer/VBoxContainer/BtnsContainer/HBoxContainer6/IncreaseCHAButton.disabled = true
	
# Function to  a stat
func _stat(stat: Global.Stat):
	var cost = char_to_mng.get_char_lvl() + 1
	if char_to_mng.experience_points >= cost:
		char_to_mng.base_stats[stat] += 1
		char_to_mng.experience_points -= cost
		# level += 1 ## Formula for character level: Sum(base stats) - 5
		update_ui()

# Button signals
func _on_STRButton_pressed():
	_stat(Stat.STR)

func _on_DEXButton_pressed():
	_stat(Stat.DEX)

func _on_CONButton_pressed():
	_stat(Stat.CON)

func _on_INTButton_pressed():
	_stat(Stat.INT)

func _on_WISButton_pressed():
	_stat(Stat.WIS)

func _on_CHAButton_pressed():
	_stat(Stat.CHA)


func _on_btn_back_to_char_mgmt_pressed():
	var params = {
		"char_to_manage":char_to_mng
	}
	GGT.change_scene("res://scenes/charactermanagement/character_management.tscn", params)
