extends Node

var db = Global.scenarioDB

func build_scenario_db():
	var testbattle = {Global.BattleChoice.OPPONENT1:"Goblin", Global.BattleChoice.OPPONENT2:null, Global.BattleChoice.OPPONENT3:null}
	db["testscenario"] = [{Global.BattleChoice.OPPONENT1:"Goblin", Global.BattleChoice.OPPONENT2:null, Global.BattleChoice.OPPONENT3:null}]
