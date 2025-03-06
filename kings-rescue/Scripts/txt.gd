extends Node

var party_end = {
	"flee": "The King hath fled, the traitors dangle, and order is restored. Dost thou sleep soundly now, oh righteous one? \n \n \nHistory keeps repeating itself - but do not despair. A safe haven awaits you somewhere… or perhaps only deeper misery.",
	"starvation": "Your food stores are depleted. The soldiers begin to fall one by one - and soon, the king does as well. If you only listened to my instructions... \n \n \nYou can find Food Rations in the Shop or use Soldiers to collect your favorite Food.",
	"assasination": "Without cautious eyes watching, the assassins were able to kill the King. Your mission failed, the King is dead. Long live the King! \n \n \nBut fear not—we never seem to run out of monarchs. Strangely, the same goes for Assassins. Best keep a watchful eye on their every move!",
	"trap": "You managed to stop the Assassins from killing the King... by doing it yourself. \n \n \nWe disregard any legal consequences - after all, someone must lead the Kings Guard. Although we cannot deny having employed better personnel in the past."
}

var ingame = {
	"start": ["An assassination plot has been uncovered! Click to select a Soldier and move them. Soldiers can push the King to escort him safely from the board-but beware, if an Assassin gets close, only a Soldier standing next to them can stop the deadly strike."],
	"food": ["You gathered some Food. Running out of supplies leads to starvation, so this was a wise choice. If only it weren’t an apple..."],
	"mercenary_flee": ["A mercenary fled. They value gold higher than loyalty, but even the best King’s Guard has two of them.", "Your mercenary has vanished. Whether they left for better prospects or just didn’t feel like working for free remains unknown.", "Your sword-for-hire has fled. In their defense, ‘unpaid volunteer’ wasn’t part of the original contract.", "Your hired blade has left, presumably in pursuit of an employer who understands the concept of ‘payment.’"],
	"mercenary_not_flee": ["A mercenary resisted the lure of gold. Experts suspect this may be linked to the large sum you gave them earlier. More research is needed.", "The mercenaries remain at your side, proving that while loyalty is rare these days, a paying job with healthcare and a retirement fund is even rarer.", "Against all expectations, your mercenary has not betrayed you. It could be out of respect - but far more likely, they just haven’t found a better offer yet.", "Your hired sword hasn’t fled—let’s just hope they’re not sticking around in anticipation of a year-end bonus."],
	"dead_body": ["He's dead, Jim.", "You cannot move dead bodies. That´s another game.", "Pretty sure he is just sleeping."],
	"soldier_leaving": [" left. Hope they bring some help. Godspeed.", " is going to buy cigarettes. Won´t be long.", " glitched through the map and is now fighting the end boss alone.", ": 'Look to my coming on the first light of the fifth day, at dawn look to the east.'"],
	"dismantle_trap": ["Looks like aimlessly fummbling with the mechanism for a bit, helped dismantling the trap.", "A few random twists and turns, and somehow the trap’s dismantled. Don’t ask how.", "With zero finesse, you managed to disarm the trap by sheer luck. Looks like the training paid off."],
	"soldier_trap_death": ["The suspiciously placed floor tile was easy to step over - unfortunately, the ceiling trap waiting right above it was not as considerate.", "Your strategy is... unique, I’ll give you that.", "The sign reading 'Not a trap, trust me' was obviously a lie.", "The suspicious tile was clearly a trap - so you stepped around it, triggering the even more suspicious tile right next to it.", "Instead of checking for traps, you decide speed is the best defense. Did it work?", "You’re not playing blindfolded, are you?", "I’m guessing you skipped the instructions... again."],
	"shop_collect": ["A treasure chest! You heroically pry it open... only to realize all you’ve done is give the shopkeeper more stuff to overcharge you for.", "You discovered a treasure chest! Naturally, instead of keeping its contents, you’ve unlocked the privilege of buying them.", "You found a treasure chest! It’s full of fantastic items you might be able to afford someday.", "You crack open a treasure chest! The shopkeeper immediately updates their inventory. It’s almost like they knew it was there all along...", "You open a chest, filled with wonders! The shopkeeper thanks you for your contribution to the economy.", "You found a chest! And just like that, your loot is now part of a 'scarcity-driven' market - where the only thing rarer than treasure is reasonable pricing.", "You found treasure! But it’s already been ‘capitalized’ - expect a 30% markup for 'market fluctuations' and 'brand premium.'"],
	"Hourglass": ["\n\nYour Hourglass shattered - such a shame. That was a family heirloom. But hey, at least it teleported you back to a time before you failed so miserably."],
	"door": ["Your dimensional key accidentally falls into the 11th-dimensional space. You've been teleported into a parallel universe where everything is exactly the same - except that kings are much harder to save here. Difficulty increased!"]
}

var shop = {
	"no_money": ["You not only look poor.", "Echo? \n \n ECHO! \n \nThat's how empty your wallet is.", "Your coin pouch is looking even emptier than the king’s promises of prosperity.", "You’ve got just enough Coins for some quality window shopping."],
	"bought": ["Thanks for thy gold, wise shopper! May your deals be plenty and your coin never empty!", "Thanks for your coin, noble spender! May your new possession bring you the happiness it promised in the brochure.", "Ah, a successful purchase! Now you can look forward to the existential dread of wondering if it was really worth it.", "Ah, the joy of consumerism!", "There you go. You’ve made your purchase. May it serve you well until the return policy expires."],
	"Pay Mercenaries": "Pay the mercenaries now, or they'll form a union - demanding dental plans and a 40-hour work week.",
	"Trap Specialists": "Unlock thriving life expectancy by learning to dismantle traps before they dismantle you. Sometimes...",
	"Food Ration": "Starving? Desperate? Barely clinging to life? Worry not - introducing the Overpriced Apple! A single bite costs a fortune, but hey, it’s still cheaper than famine!",
	"Hourglass": "The Hourglass shatters upon the king’s death, yet somehow flings you back in time. Not that you’ll save him next time either…",
	"Life Insurance": "Having life insurance on eight people sounds like fraud waiting to happen - but what else would you expect in a kingdom where assassinating the monarch is practically a national pastime?",
	"Dimensional Key": "A key crafted by the realm's top quantum scientists to boost both mortality rates and fun—simultaneously. Fitting doors sold separately."
}

var assassin_manuals = ["This one is a cooking recipe. No information about assassins.", 
"A note about knife sharpening techniques.",
"A page from human anatomy book.",
"King is an assassin.",
"There are no traps on this level.",
"If you run out of food, only traitors die.",
"*shreds the paper*",
"Bring this letter to the king, make sure he's alone.",
"On this level you win if the king dies.",
"Just a love letter to apples."
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
