extends Control

const NULL_ITEM_NAME_STRINGS = ["","None", "--empty--"]

var char_to_mng: GameCharacter
var Stat = Global.Stat
var IType = GameCharacter.InvType

var current_scenario

## variable references to control nodes

@onready var lbl_char_name: Label = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/lblCharName
@onready var tr_char_portrait: TextureRect = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/trCharPortrait
@onready var lbl_curr_hp: Label = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/lblCurrHP
@onready var tpb_curr_hp: TextureProgressBar = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/txProgBarCurrHP


@onready var btn_weapon: MenuButton = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/vbcEquipment/Weapon/mbtnWeapon
@onready var btn_armor: MenuButton = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/vbcEquipment/Armor/mbtnArmor
@onready var btn_accessory: MenuButton = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/vbcEquipment/Accessory/mbtnAccessory

@onready var rtl_stat_vals: RichTextLabel = $Background/VBoxContainer/hbcMainSegments/vbcMidSeg/CharStats/txtStatValues
@onready var vbc_item_slots: VBoxContainer = $Background/VBoxContainer/hbcMainSegments/vbcMidSeg/vbItemSlots

@onready var btn_rest: Button = $Background/VBoxContainer/hbcMainSegments/vbcRightSeg/btnRest
@onready var il_abilities: ItemList = $Background/VBoxContainer/hbcMainSegments/vbcRightSeg/ilAbilities
@onready var rtl_abil_desc: RichTextLabel = $Background/VBoxContainer/hbcMainSegments/vbcRightSeg/rtlAbilDesc
@onready var btn_view_next_battle: Button = $Background/VBoxContainer/hbcMainSegments/vbcRightSeg/btnViewNextBattle

## Populates the il_abilities item-list for buttons to view abilities
func populate_abilities_ilist() -> void:
	il_abilities.clear()
	for ability in char_to_mng.unique_abilities.keys():
		var id = il_abilities.add_item(ability)


## Populates the vbc_item_slots with MenuButtons allowing access to item slots
## and their inventory
func populate_item_slots() -> void:
	var cap = char_to_mng.get_stat(Stat.BELT_CAP)
	var belt = char_to_mng.item_belt
	## Clear out any menu buttons present
	for child in vbc_item_slots.get_children():
		vbc_item_slots.remove_child(child)
		child.queue_free()

	## Populate item slots with menu buttons
	var next_item
	var id = 0
	for idx in range(0,len(belt)):
		print("--in character_management.gd.populate_item_slots(): ")
		print("  --Current contents of character's item belt: ",char_to_mng.item_belt)
		if idx < cap: #keep making buttons as long as the items found fit within the current belt size
			next_item = MenuButton.new()
			next_item.text=belt[idx]
			next_item.flat=false
			# item_belt_btn_list.append(next_item) ## TODO ensure this isn't used, and once ensured, remove this line
			next_item.about_to_popup.connect(_on_item_slot_btn_about_to_popup.bind(next_item,id))
			id += 1
			vbc_item_slots.add_child(next_item)
		else:
			char_to_mng.manage_item_belt_state() # pull excess items out of the character's belt and put them into the inventory
			break  # stop making buttons,
	## Populate the rest of the slots with "-empty-"
	

	if len(char_to_mng.item_belt) < cap:
		print ("In character_management.gd, update_ui(): filling UI with MenuButtons for the empty item slots (of which there are: ",cap-len(char_to_mng.item_belt),"):")
		for slot in range(0,cap-len(char_to_mng.item_belt)):
			next_item = MenuButton.new()
			next_item.text="--empty--"
			next_item.flat=false
			#item_belt_btn_list.append(next_item) ## TODO ensure this isn't used, and once ensured, remove this line
			next_item.about_to_popup.connect(_on_item_slot_btn_about_to_popup.bind(next_item,id))
			id += 1
			vbc_item_slots.add_child(next_item)


func _ready() -> void:
	var params = GGT.get_current_scene_data().params
	print("entring _ready() of character_management.tscn. params keys: ",params.keys())
	
	## This scene expects a GameCharacter object, "char_to_mng_character", as a parameter.
	## First, ensure it is there...TODO 20250807: someday
	char_to_mng = params.char_to_manage
	#next_battle_idx = params.battle
	
	# char_to_mng.curr_hp = 50 <- DEBUG CODE, delete this line when no longer needed
	
	## Connect relevant signals from GameCharacter to functions within this script
	char_to_mng.hp_updated.connect(_on_char_to_mng_hp_updated)
	char_to_mng.equipped_weapon_changed.connect(_on_wpn_updated)
	char_to_mng.equipped_armor_changed.connect(_on_amr_updated)
	char_to_mng.equipped_accessory_changed.connect(_on_acc_updated)
	
	
	## set initial values for each of the UI controls
	_on_char_to_mng_hp_updated(char_to_mng.curr_hp) # bump the UI updater on ready
	populate_item_slots() # run initial run of UI item slots
	lbl_char_name.text = char_to_mng.character_name
	#lbl_curr_hp.text = str(char_to_mng.curr_hp,"/",char_to_mng.get_stat(GameCharacter.Stat.MAX_HP))
	tpb_curr_hp.max_value = char_to_mng.get_stat(Stat.MAX_HP)
	tpb_curr_hp.value =  char_to_mng.curr_hp
	btn_weapon.text = char_to_mng.equipped_weapon
	btn_armor.text = char_to_mng.equipped_armor
	btn_accessory.text = char_to_mng.equipped_accessory
	rtl_stat_vals.text = char_to_mng.get_stats_str_for_cha_mgmt_scr()
	populate_abilities_ilist()
	tr_char_portrait.texture = char_to_mng.character_portrait
	
	char_to_mng.emit_signal("item_belt_updated")
	

## -- Signal-triggered functions --

func _on_char_to_mng_hp_updated(new_hp):
	print("well the signal worked")
	lbl_curr_hp.text = str(new_hp,"/",char_to_mng.get_stat(Stat.MAX_HP))
	tpb_curr_hp.value = char_to_mng.curr_hp
	tpb_curr_hp.max_value = char_to_mng.get_stat(Stat.MAX_HP)


func _on_wpn_updated(new_wpn):
	btn_weapon.text = new_wpn
	## Because an equipped weapon may impact stats, update stats as well
	rtl_stat_vals.text = char_to_mng.get_stats_str_for_cha_mgmt_scr()


func _on_amr_updated(new_amr):
	btn_armor.text = new_amr
	## Because an equipped armor may impact stats, update stats as well
	rtl_stat_vals.text = char_to_mng.get_stats_str_for_cha_mgmt_scr()
	
	
func _on_acc_updated(new_acc):
	btn_accessory.text = new_acc
	## Because an equipped weapon may impact stats, update stats as well
	rtl_stat_vals.text = char_to_mng.get_stats_str_for_cha_mgmt_scr()

func _on_il_abilities_item_clicked(index, at_position, mouse_button_index):
	var ab_name = il_abilities.get_item_text(index)
	rtl_abil_desc.text = Abilities.get_ability_description(ab_name)


func _on_mbtn_weapon_about_to_popup():
	btn_weapon.get_popup().clear()
	var id=0
	for wpn in char_to_mng.inventory[IType.WEAPON].keys():
		btn_weapon.get_popup().add_item(wpn,id)
		id += 1
	btn_weapon.get_popup().id_pressed.connect(_on_wpn_item_selected)
	if (char_to_mng.equipped_weapon != "") and (char_to_mng.equipped_weapon != "None"):
		btn_weapon.get_popup().add_item("Un-equip",id)


func _on_wpn_item_selected(id : int) -> void:
	var itemname = btn_weapon.get_popup().get_item_text(id)
	print ("_on_wpn_item_selected(",id,"), text selected is: ",itemname)
	if itemname == "Un-equip":
		char_to_mng.gain_item(char_to_mng.equipped_weapon, GameCharacter.InvType.WEAPON)
		print("--in character_management.gd: _on_wpn_item_selected(",id,")")
		print("--  new status of character's inventory: ",char_to_mng.inventory)
		char_to_mng.equipped_weapon = "None"
	else:
		print("SELECTING WEAPON.  WEAPON SELECTED: '",itemname,"'")
		if (char_to_mng.equipped_weapon != "") and (char_to_mng.equipped_weapon != "None"):
			char_to_mng.gain_item(char_to_mng.equipped_weapon, GameCharacter.InvType.WEAPON)
		char_to_mng.equipped_weapon = itemname
		char_to_mng.remove_item(itemname,GameCharacter.InvType.WEAPON)
	populate_item_slots() ## in case weapon had an item slot mod attached to it


func _on_mbtn_armor_about_to_popup():
	btn_armor.get_popup().clear()
	var id=0
	for amr in char_to_mng.inventory[IType.ARMOR].keys():
		btn_armor.get_popup().add_item(amr,id)
		id += 1
	btn_armor.get_popup().id_pressed.connect(_on_amr_item_selected)
	if (char_to_mng.equipped_armor != "") and (char_to_mng.equipped_armor != "None"):
		btn_armor.get_popup().add_item("Un-equip",id)


func _on_amr_item_selected(id : int) -> void:
	var itemname = btn_armor.get_popup().get_item_text(id)
	print ("_on_amr_item_selected(",id,"), text selected is: ",itemname)
	if itemname == "Un-equip":
		char_to_mng.gain_item(char_to_mng.equipped_armor, GameCharacter.InvType.ARMOR)
		char_to_mng.equipped_armor = "None"
	else:
		print("SELECTING ARMOR.  ARMOR SELECTED: '",itemname,"'")
		if (char_to_mng.equipped_armor != "") and (char_to_mng.equipped_armor != "None"):
			char_to_mng.gain_item(char_to_mng.equipped_armor, GameCharacter.InvType.ARMOR)
		char_to_mng.equipped_armor = itemname
		char_to_mng.remove_item(itemname,GameCharacter.InvType.ARMOR)
	populate_item_slots() ## in case armor had an item slot mod attached to it


func _on_mbtn_accessory_about_to_popup():
	btn_accessory.get_popup().clear()
	var id=0
	for acc in char_to_mng.inventory[IType.ACCESSORY].keys():
		btn_accessory.get_popup().add_item(acc,id)
		id += 1
	btn_accessory.get_popup().id_pressed.connect(_on_acc_item_selected)
	if (char_to_mng.equipped_accessory != "") and (char_to_mng.equipped_accessory != "None"):
		btn_accessory.get_popup().add_item("Un-equip",id)
	



func _on_acc_item_selected(id : int) -> void:
	var itemname = btn_accessory.get_popup().get_item_text(id)
	print ("_on_acc_item_selected(",id,"), text selected is: ",itemname)
	if itemname == "Un-equip":
		char_to_mng.gain_item(char_to_mng.equipped_accessory, GameCharacter.InvType.ACCESSORY)
		char_to_mng.equipped_accessory = "None"
	else:
		print("SELECTING ACCESSORY.  ACCESSORY SELECTED: '",itemname,"'")
		if (char_to_mng.equipped_accessory != "") and (char_to_mng.equipped_accessory != "None"):
			char_to_mng.gain_item(char_to_mng.equipped_accessory, GameCharacter.InvType.ACCESSORY)
		char_to_mng.equipped_accessory = itemname
		char_to_mng.remove_item(itemname,GameCharacter.InvType.ACCESSORY)
	populate_item_slots() ## in case accessory had an item slot mod attached to it
	
	## Since accessories are most likely to affect item slots, check every time accessories are
	## touched
	char_to_mng.emit_signal("item_belt_updated")
		
		
func _on_item_slot_btn_about_to_popup(item_btn,slot_id):
	print("in character_management.gd: _on_item_slot_btn_about_to_popup(item_btn) called!")
	item_btn.get_popup().clear()
	var id=0
	#print("in character_management.gd -> _on_item_slot_btn_about_to_popup(): items currently in inventory: ",char_to_mng.inventory[GameCharacter.InvType.ITEM].keys())
	for itm in char_to_mng.inventory[GameCharacter.InvType.ITEM].keys():
		#print("in character_management.gd -> _on_item_slot_btn_about_to_popup(): trying to populate options with this item from inventory: ",itm, "(quantity in inv: ",char_to_mng.inventory[GameCharacter.InvType.ITEM][itm])
		#item_btn.get_popup().add_item(str(itm," x",char_to_mng.inventory[GameCharacter.InvType.ITEM][itm]),id) ## This line is bugged.  Trying to display a count in the inventory in this way screws up the code for the actual management.  This is why you keep display components separate from underlying functionality.
		item_btn.get_popup().add_item(itm,id) ## TODO 20250730: find a better way to display count of stackable items.
		item_btn.get_popup().id_pressed.connect(_on_belt_item_selected.bind(item_btn))
		id +=1 
	#item_btn.get_popup().id_pressed.connect(_on_belt_item_selected)
	if slot_id < len(char_to_mng.item_belt):
		item_btn.get_popup().add_item("Remove",id) # Give option to remove current item if accessing non-empty slot
	print('char_to_mng AVAILABLE ITEMS MENU POPPING UP')

func _on_belt_item_selected(id:int,item_btn):
	var itemname = item_btn.get_popup().get_item_text(id)
	print ("_on_belt_item_selected(",id,"), text selected is: ",itemname)
	if itemname == "Remove":
		print("in character_management.gd -> _on_item_slot_btn_about_to_popup(): 'Remove' chosen.  Attempting to ADD item to inventory, then REMOVE item from item belt")
		char_to_mng.gain_item(item_btn.text, GameCharacter.InvType.ITEM,false)
		char_to_mng.item_belt.erase(item_btn.text)
		print("in character_management.gd -> _on_item_slot_btn_about_to_popup(): item ",item_btn.text," erased from item belt.  Item belt status: ",char_to_mng.item_belt)
	else:
		print("SELECTING ITEM.  ITEM SELECTED: '",itemname,"'")
		if (itemname != "") and (itemname != "None"):
			# 1) old item is ADDED to char_to_mng inventory
			char_to_mng.gain_item(item_btn.text, GameCharacter.InvType.ITEM) if item_btn.text not in NULL_ITEM_NAME_STRINGS else null
			# 2) old item is REMOVED from the belt
			char_to_mng.item_belt.erase(item_btn.text)
			# 3) new item is APPENDED to the belt
			char_to_mng.item_belt.append(itemname)
			# 4) new item is DEDUCTED/REMOVED from char_to_mng inventory
			char_to_mng.remove_item(itemname)
		else:
			print("***ERROR in character_management.gd, _on_belt_item_selected(), somehow '' or 'None' is name of item!?")
		
	## Whatever was chosen, make sure items are updated in the UI
	populate_item_slots()


func _on_btn_view_next_battle_pressed():
	var params = {
		"player_character":char_to_mng
	}
	GGT.change_scene("res://scenes/battleselectui/battle_select_ui.tscn", params)
