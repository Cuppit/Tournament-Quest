extends Node

var db = Global.scenarioDB

func build_scenario_db():
	var testbattle = {Global.BattleChoice.OPPONENT1:"Goblin", Global.BattleChoice.OPPONENT2:"Wolf", Global.BattleChoice.OPPONENT3:null}
	db["testscenario"] = [{Global.BattleChoice.OPPONENT1:"Goblin", Global.BattleChoice.OPPONENT2:"Wolf", Global.BattleChoice.OPPONENT3:"Prison Guard"},\
							{Global.BattleChoice.OPPONENT1:"Alchemist", Global.BattleChoice.OPPONENT2:"Prison Guard", Global.BattleChoice.OPPONENT3:"Goblin"}]
