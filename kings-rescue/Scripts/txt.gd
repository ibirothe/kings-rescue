extends Node

var party_end = {
	"flee": "The King hath fled, the traitors dangle, and order is restored. Dost thou sleep soundly now, oh righteous one? \n \n \nHistory keeps repeating itself, and saving just one King per century won’t break the cycle. Increase your win streak to unlock more misery!",
	"starvation": "Your food stores are depleted. The soldiers begin to fall one by one-and soon, the king does as well. If you only listened to my instructions... \n \n \nHistory keeps repeating itself! Next time try to keep an eye on your Food Rations, maybe?",
	"assasination": "Without cautious eyes watching, the assassins were able to kill the King. Your mission failed, the King is dead. Long live the King! \n \n \nHistory keeps repeating itself, and strangely, there are always two Assassins within the King's Guard… and trust no one!",
	"trap": "You managed to stop the Assassins from killing the King... by doing it yourself. \n \n \nHistory keeps repeating itself-maybe next time, you won’t be the one to slay the King. Let me take care of your Coins so they don´t distract you from finding a safer path!",
	"Hourglass": "\n\nYour hourglass shattered - what a shame. That was a family heirloom for generations..."
}

var ingame = {
	"start": ["An assassination plot has been uncovered! Click to select a Soldier and move them. Soldiers can push the King to escort him safely from the board-but beware, if an Assassin gets close, only a Soldier standing next to them can stop the deadly strike."],
	"food": ["You gathered some Food. Running out of supplies leads to starvation, so this was a wise choice. If only it weren’t an apple..."],
	"mercenary_flee": ["A mercenary fled. They value gold higher than loyalty, but even the best King’s Guard has two of them."],
	"mercenary_not_flee": ["You paid. not flee. Good text."],
	"dead_body": ["He's dead, Jim.", "You cannot move dead bodies. That´s another game.", "Pretty sure he is just sleeping."],
	"soldier_leaving": [" left. Hope they bring some help. Godspeed.", " is going to buy cigarettes. Won´t be long.", " glitched through the map and is now fighting the end boss alone.", ": 'Look to my coming on the first light of the fifth day, at dawn look to the east.'"],
	"dismantle_trap": ["Trap dismatling text goes here"],
	"soldier_trap_death": ["Soldier dead in trap text"],
	"shop_collect": ["You collected stuff for shop blablablablablabla"],
	"Hourglass": ["\n\nYour hourglass shattered - what a shame. That was a family heirloom for generations..."],
	"door": ["Your dimensional key accidentally falls into the 11th-dimensional space. You've been teleported into a parallel universe where everything is exactly the same - except that kings are much harder to save here. Difficulty increased!"]
}

var shop = {
	"no_money": ["You not only look poor."],
	"bought": ["Thanks for thy gold, wise shopper! May your deals be plenty and your coin never empty!"],
	"Pay Mercenaries": "Blablabla, much they will form a trade union.",
	"Trap Specialists": "Dismantle not die blablalba",
	"Food Ration": "Let the game guess your favorite food, then add 10 apples to your food storage!",
	"Hourglass": "The hourglass shatters when the king dies, yet somehow flings you back in time. Stranger still, the hourglass never existed in the past, but your win streak does.",
	"Life Insurance": "Having life insurance on eight people sounds like fraud waiting to happen - but what else would you expect in a kingdom where assassinating the monarch is practically a national pastime?",
	"Dimensional Key": "A key to elevate the difficulty level. Don´t expect us to sell the door seperately."
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
