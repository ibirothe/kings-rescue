# **Game Design Document: Rescue the King**  

## **Overview**  
*Rescue the King* is a turn-based strategy game played on an **11x11 grid**. The player controls **8 soldiers** whose mission is to **push the King off the map to safety**. However, hidden threats lurk among the soldiers and the battlefield, requiring careful planning and resource management.  

## **Game Objective**  
Move the **King** off the grid by pushing him while managing limited resources and avoiding dangers such as **assassins, traps, and starvation**.  

## **Game Elements**  

### **King**  
- Starts at the center of the grid (5,5).  
- **Cannot move on his own**, only pushed by soldiers.  
- If pushed out of bounds, the player wins.  

### **Soldiers (0-7)**  
- Start **adjacent** to the King in a set formation.  
- Move **one tile per turn** in any cardinal direction (WASD).  
- If they push the **King**, he moves one tile in the same direction.  
- Can step on **food** to collect it.  

### **Assassins (2 total, hidden)**  
- Two soldiers are secretly assassins.  
- If an **assassin** is adjacent to the King and **no other soldier is touching the assassin**, the assassin **kills the King**, resulting in a **game over**.  

### **Merchants (2 total, hidden)**  
- Two soldiers are secretly **merchants**.  
- If a **merchant** is adjacent to a **gold coin**, they automatically grab it and **disappear from the game**.  

### **Traps (10 total, hidden)**  
- Placed randomly on the grid.  
- If the **King** or a **soldier** steps on a trap, they **die immediately** and are removed from the game.  

### **Gold Coins (8 total, visible)**  
- Placed randomly on the grid.  
- If a **merchant** soldier is adjacent to a gold coin, they **pick it up and disappear**.  

### **Food (energy resource)**  
- The **player starts with 10 food**.  
- **Every turn**, **1 food** is consumed.  
- If **a soldier steps on a food tile**, **+10 food** is added to the total.  
- If food reaches **0**, the player **loses one random soldier per round** until food is replenished.  

### **Informant (2 total, visible)**  
- Placed randomly on the grid.  
- If a soldier steps onto an **informant** tile, the tile is removed and a random text information is displayed to the player. **information** can be:
- *"Rupert is a merchant."*
- *"Assasins are on white."*
- *"Thoralf is no assasin."*

## **Win & Loss Conditions**  

### **Win Condition:**  
- The **King is successfully pushed off the grid**.  

### **Loss Conditions:**  
- **An assassin kills the King.**  
- **The King steps on a trap.**  
- **All soldiers die due to starvation.**  

---

## **User Input and Output**

A user can click on any entity on the map and will get a text field response with mechanical and lore information.

E.g. **food item**: "You can pick up with a soldier to avoid starvation."

If you click on a soldie you will openup an arrow interface including all possible directions a soldier can walk towards. Clicking one of the arrows will trigger the movement and complete the turn.

E.g. **soldier description**: "This is Rupert - he's already been condidered old, when he served the kings father. Seems harmless, right?"

If a special event like assasination, merchant fleeing, etc take place, the camera zooms in by 5 before the animations happen and it zooms back out.

After a turn is completed the food counter is decreased and the text field will be updated according to the actions that took place:
- A merchant fled with the gold.
- A soldier stepped onto a trap.
- The informants information.
