extends Node2D
@onready var infoText: Label = $CanvasLayer/Text
@onready var questionText: Label = $CanvasLayer/Question
@onready var inputLine: Label = $CanvasLayer/InputLine
@onready var inventroy: HBoxContainer = $CanvasLayer/Inventroy
@onready var roomDiscription: Label = $CanvasLayer/RoomDiscription

var inputAnswer = ""
var currentScene = 0
var currentLevel = 0
var sceneChangeWait = 0
var sceneHold = -1
var levelHold = -1
var playerName = ""
var eventList = []
var HP = 6
var hasTutorialFight = false

#Words reference list:
#65: What is   66: True or False   67: Your Name   68: Above   69: Below   70: To The Left   71: To The Right   72: Rock   73: Fire   74:    75:    76:    77:    78:    79:   
#80:    81:    82:    83:    84:    85:    86:    87:    88:    89:    90:    91:

func _ready() -> void:
	refreshEventList()
	changeScene()

func _physics_process(delta: float) -> void:
	if infoText.visible_ratio != 1.0:
		infoText.visible_characters += 80 * delta
	elif questionText.visible_ratio != 1.0:
		questionText.visible_characters += 100 * delta
	
	if Input.is_anything_pressed():
		if Input.is_action_just_pressed("press Backspace"):
			changeAnswer("<-")
		if Input.is_action_just_pressed("press Space"):
			changeAnswer(" ")
		for i in range(25):
			if Input.is_action_just_pressed("press "+ char(65+i)):
				changeAnswer(char(65+i))
		for i in range(9):
			if Input.is_action_just_pressed("press "+ char(49+i)):
				changeAnswer(char(49+i))
	if Input.is_action_just_pressed("press Enter"):
		if !inventroy.visible:
			delaySceneChange(-1, -1, -1)
			if roomDiscription.visible:
				roomDiscription.visible = false
				roomDiscription.text = ""
				questionText.visible = true
				infoText.visible = true
				inputLine.visible = true
			if infoText.visible_ratio == 1.0 and questionText.visible_ratio == 1.0:
				inputAnswer = inputLine.text
				answerEntered(inputAnswer)
				currentScene+=1
				changeScene()
			else:
				infoText.visible_ratio = 1.0
				questionText.visible_ratio = 1.0

func changeAnswer(letter):
	if !inventroy.visible:
		if letter == "<-":
			var length = len(inputLine.text)
			var temString = inputLine.text
			inputLine.text = ""
			for c in range(length-1):
				inputLine.text+=temString[c]
		else:
			inputLine.text += letter

func answerEntered(answer):
	if answer == "INV" or answer == "INVENTORY":
		inventroy.visible = true
		questionText.visible = false
		infoText.visible = false
		inputLine.visible = false
		roomDiscription.visible = false
		currentScene-=1
	if answer == "LOOK AROUND" or answer == "LOOK" and eventList[currentLevel][currentScene][2] == "battle":
		if !roomDiscription.visible:
			roomDiscription.visible = true
			roomDiscription.text = eventList[currentLevel][currentScene][4]
			questionText.visible = false
			infoText.visible = false
			inputLine.visible = false
			currentScene-=2
		else:
			currentScene-=1
	if eventList[currentLevel][currentScene][2] == "battle":
		if answer == eventList[currentLevel][currentScene][3]:
			delaySceneChange(1, 3, 1)
		else:
			HP-= 1
			
		
	if typeof(eventList[currentLevel][currentScene]) == TYPE_ARRAY:
		if eventList[currentLevel][currentScene][2].substr(0,7) == "special":
			if eventList[currentLevel][currentScene][2].substr(7) == "1":
				playerName = answer
				refreshEventList()
			if eventList[currentLevel][currentScene][2].substr(7) == "2":
				if answer == "Y" or answer == "YES" or answer ==  "TRUE" or answer ==  "T":
					pass
				else:
					currentScene-=2
					changeScene()
		if eventList[currentLevel][currentScene][2].substr(0,3) == "path":
			if eventList[currentLevel][currentScene][2].substr(3) == "1":
				if answer == "N" or answer == "NORTH":
					pass
			if eventList[currentLevel][currentScene][2].substr(3) == "1":
				if answer == "CD" or answer == "CLOSEST DOOR":
					if !eventList[currentLevel][currentScene][5]:
						eventList[currentLevel][currentScene][5] = true
					else:
						currentLevel = 4
						currentScene = 5
						delaySceneChange(1, 3, 1)

func changeScene():
	inputLine.text = ""
	if currentScene> len(eventList[currentLevel])-1:
		currentLevel+=1
		currentScene = 0
	if typeof(eventList[currentLevel][currentScene]) == TYPE_ARRAY:
		if !hasTutorialFight and eventList[currentLevel][currentScene][2] == "battle":
			hasTutorialFight = true
			delaySceneChange(4, currentScene, currentLevel)
			currentScene = 0
			currentLevel = 4
			changeScene()
			return
		infoText.text = eventList[currentLevel][currentScene][0]
		questionText.text = eventList[currentLevel][currentScene][1]
	else:
		infoText.text = eventList[currentLevel][currentScene]
		questionText.text = ""
	infoText.visible_ratio = 0
	questionText.visible_ratio = 0

func delaySceneChange(delay, newScene, newLevel):
	if newScene < 0 or delay < 0 or newLevel < 0:
		if sceneChangeWait>0:
			sceneChangeWait-=1
			print(sceneChangeWait," ",sceneHold," ",levelHold)
		if sceneChangeWait == 0 and sceneHold >= 0 and levelHold >= 0:
			currentScene = sceneHold
			currentLevel = levelHold
			sceneHold = -1
			levelHold = -1
	else:
		sceneChangeWait = delay
		sceneHold = newScene-1
		levelHold = newLevel

func refreshEventList():
	eventList = [
#level 0 into and name.
["You stand in a dark room, you know there is a floor, but you don't see it. The only thing you can see is two glowing orange eyes looking at you through the blackness", 
["\"What is your name?\" the eyes say in a raspy voice, The words echo around you.", "A C", "special1"], 
["\""+playerName+" is your name? true(T)/ false(F)\"", "B", "special2"], 
"\"Well it is wonderful to meet you "+playerName+"\" The voice hisses", 
"\"I mustn't keep you waiting you have a job you must do.\" the eyes say and while you can't see it you feel a smile across its face widden",
"And on queue you are blinded by a bright light above you and you are suddently standing in the sun."],

["You find your self in an open feild, you are standing in a stone circle with 4 cement walk ways stretching out in what you assume to be North, South, East, and West, each leading to a building, two cream colored, a brick, and a glass one respectfully.",
["Which way do you go? north(N), south(S), east(E), west(W)", " ", "path1"],
"You walk up to this cream colored building, It is two stories tall and yet it towers over you, up a couple stairs you see a double door. You walk inside (why not?).",
"Inside there is white tile, the building cold and is made into single long hall with doors across it on the wall closer to you, across is one larger door. To your left you see stairs up into the second floor",
["Which way do you go? Leave/ Closest Door/ Large Door/ Stairs", " ", "path2"],
"You step into the closest door, in the center there is a cultist who looks at you stands up from where it was sitting and runs at you with a blade, you unsheeth your sword, it is time to fight.",
["You are in a large room, a cultist runs at you with a blade, what do you do?", "a d c", "battle", "DAGGER", "The room you are in is very simple the Cultist stands in the middle, its mask is perfectly white. On the back wall you see something wrote in the brick, it says '"+playerName+"' and above it stuck into the wall is a dagger, it must be how whoever ingraved your name into it.", false, "INCORRECT: The Cultest shoots a bolt of magic at you. you take 1 damage"],
"CORRECT: You grab the dagger out from the wall and thrust it into the Cultist, he falls to the floor as a pile of robes and a mask, you he the glint of a key with the number 1 on it. You take it, it might be useful."
],
[""],
[""],
["You feel as a voice begins to speak in your head... it is the same as the one in the dark room... the one with the eyes\"Let me explain how this will work, A fight is like a puzzle, but with the adrenaline how are you supposed to know what to do, thats why I help you out and give you the answer,",
"\"But where is the fun in that, you must be thinking\" it continues\" well I like the way you think and I agree, I cant just tell you so I ask you a question in my language, the answer is how you survive\"",
"\"But you are my best friend of course so I will start easy on you. In fact if you type INV you can find a list of symbols I will use. You will have to fill out the rest but I gave you the first two.\"",
"\"But how do you solve them well just look around my friend everything you are looking for is around you all you need to type is LOOK\"",
"\"Good luck\" it says and you mind is your own again.",
"You have cleared this room. There is nothing here."]]
