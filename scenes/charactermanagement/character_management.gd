extends Control

var char_to_mng: GameCharacter
var Stat = Global.Stat
var IType = GameCharacter.InvType
## variable references to control nodes

@onready var lbl_char_name: Label = $Background/VBoxContainer/hbcMainSegments/vbcLeftSeg/lblCharName
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

## Populates the item list for buttons to view abilities
func populate_abilities_ilist() -> void:
	il_abilities.clear()
	for ability in char_to_mng.unique_abilities.keys():
		var id = il_abilities.add_item(ability)


func _ready() -> void:
	var params = GGT.get_current_scene_data().params
	print("entring _ready() of character_management.tscn. params keys: ",params.keys())
	
	## This scene expects a GameCharacter object, "char_to_mng_character", as a parameter.
	## First, ensure it is there...TODO 20250807: someday
	char_to_mng = params.char_to_manage
	
	# char_to_mng.curr_hp = 50 <- DEBUG CODE, delete this line when no longer needed
	
	## Connect relevant signals from GameCharacter to functions within this script
	char_to_mng.hp_updated.connect(_on_char_to_mng_hp_updated)
	char_to_mng.equipped_weapon_changed.connect(_on_wpn_updated)
	char_to_mng.equipped_armor_changed.connect(_on_amr_updated)
	char_to_mng.equipped_accessory_changed.connect(_on_acc_updated)
	
	
	## set initial values for each of the UI controls
	_on_char_to_mng_hp_updated(char_to_mng.curr_hp) # bump the UI updater on ready
	lbl_char_name.text = char_to_mng.character_name
	#lbl_curr_hp.text = str(char_to_mng.curr_hp,"/",char_to_mng.get_stat(GameCharacter.Stat.MAX_HP))
	tpb_curr_hp.max_value = char_to_mng.get_stat(Stat.MAX_HP)
	tpb_curr_hp.value =  char_to_mng.curr_hp
	btn_weapon.text = char_to_mng.equipped_weapon
	btn_armor.text = char_to_mng.equipped_armor
	btn_accessory.text = char_to_mng.equipped_accessory
	rtl_stat_vals.text = char_to_mng.get_stats_str_for_cha_mgmt_scr()
	populate_abilities_ilist()
	

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
	
	
