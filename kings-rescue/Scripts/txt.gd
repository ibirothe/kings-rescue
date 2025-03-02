extends Node

var party_end = {
	"flee": "The King hath fled, the traitors dangle, and order is restored. Dost thou sleep soundly now, oh righteous one? \n \n \nHistory keeps repeating itself, and saving just one King per century won’t break the cycle. Increase your win streak to unlock more misery!",
	"starvation": "Your food stores are depleted. The soldiers begin to fall one by one-and soon, the king does as well. If you only listened to my instructions... \n \n \nHistory keeps repeating itself! Next time try to keep an eye on your Food Rations, maybe?",
	"assasination": "Without cautious eyes watching, the assassins were able to kill the King. Your mission failed, the King is dead. Long live the King! \n \n \nHistory keeps repeating itself, and strangely, there are always two Assassins within the King's Guard… and trust no one!",
	"trap": "You managed to stop the Assassins from killing the King... by doing it yourself. \n \n \nHistory keeps repeating itself-maybe next time, you won’t be the one to slay the King. Let me take care of your Coins so they don´t distract you from finding a safer path!"
}

var ingame = {
	"start": ["An assassination plot has been uncovered! Click to select a Soldier and move them. Soldiers can push the King to escort him safely from the board-but beware, if an Assassin gets close, only a Soldier standing next to them can stop the deadly strike."],
	"food": ["You gathered some Food. Running out of supplies leads to starvation, so this was a wise choice. If only it weren’t an apple..."],
	"mercenary_flee": ["A mercenary fled. They value gold higher than loyalty, but even the best King’s Guard has two of them."],
	"mercenary_not_flee": ["You paid. not flee. Good text."],
	"dead_body": ["He's dead, Jim.", "You cannot move dead bodies. That´s another game.", "Pretty sure he is just sleeping."],
	"soldier_leaving": [" left. Hope they bring some help. Godspeed.", " is going to buy cigarettes. Won´t be long.", " glitched through the map and is now fighting the end boss alone."],
	"dismantle_trap": ["Trap dismatling text goes here"],
	"soldier_trap_death": ["Soldier dead in trap text"]
}

var assassin_manuals = ["This one is a cooking recipe. No information about assassins.", 
"A note about knife sharpening techniques.",
"A page from human anatomy book.",
"King is an assassin.",
"There are no traps on this level.",
"If you run out of food, only traitors die.",
"**shreds the paper**",
"Bring this letter to the king, make sure he's alone.",
"It's a magical spell. Press L to use it.",
"On this level you win if the king dies."
]

var mercenary_manuals = ["This is not the dollar bill, you were looking for.", 
"A note about the 13th-century stock market.",
"You thought it was a job posting, right?",
"There is a teleporting stone close to that Coin over there.",
"You could try and sell this note!?"
]

var  CHARACTER_DESCRIPTIONS = {
	"Rupert": "Rupert has been in the guard for 45 years. The only thing he fears more than death is retirement.",
	"Thoralf": "Thoralf is an older wizard making inappropriate jokes sometimes. We try not to laugh, but it's hard at times.",
	"Ogra": "Ogra has trained for the King's Guard since she was a little girl. No way she's an imposter.",
	"Bartholo": "Bartholo wanted to be an inventor, but his parents said no. So he became a video game character.",
	"Ibrahim": "Ibrahim is a loyal kingsman. At least, that's what I assume. Placing him next to a Gold Coin will bring some clarity.",
	"Edwin": "Edwin's singing voice sounds like birds in spring. Unfortunately, we didn't hire voice actors to prove it.",
	"Marquise": "Marquise's archery is masterful. Sadly, the developers didn't put arrows in the game.",
	"Arianna": "Arianna joined the King's Guard recently. She had exceptional results in the job interview."
}

func get_party_end(key) -> String:
	refresh_party_end()
	return party_end[key]

func refresh_party_end() -> void:
	party_end = {
	"flee": "The King hath fled, the traitors dangle, and order is restored. Dost thou sleep soundly now, oh righteous one? \n \n \nHistory keeps repeating itself, and saving just one King per century won’t break the cycle. Press 'R' to restart with increased difficulty!",
	"starvation": "Your food stores are depleted. The soldiers begin to fall one by one-and soon, the king does as well. If you only listened to my instructions... \n \n \nHistory keeps repeating itself! Press 'R' to retry and keep an eye on your Food Rations.",
	"assasination": "Without cautious eyes watching, the assassins were able to kill the King. Your mission failed, the King is dead. Long live the King! \n \n \nHistory keeps repeating itself, and strangely, there are always two Assassins within the King's Guard. Press 'R' to restart… and trust no one!",
	"trap": "You managed to stop the Assassins from killing the King... by doing it yourself. \n \n \nHistory keeps repeating itself-maybe next time, you won’t be the one to slay the King. Press 'R' to retry... and perhaps find a safer path!"
}
