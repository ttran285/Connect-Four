% Tiffany Tran
% ConnectFour.t
% Ms. Dyke
% May 20th, 2015
% This program allows two players to play a regular game of connect four. A
% player wins when they get four consecutive chips of the same colour in a row
% vertically, horizontally, or diagonally. Upon starting the program, the
% players will pass through an introduction screen which includes an animation. From
% there, players can proceed to the main menu. At the main menu, there are three
% options: start game, instructions, and exit. Choosing start game will lead
% players to the game screen where they can begin playing and choosing the
% instructions option will take players to an instructions screen. From there,
% players can learn the rules of the game and return to the main menu using the
% button. If the players press the exit button on the menu screen, they would
% be lead to a goodbye screen and that screen will close shortly upon opening.

%Screen set up.
import GUI
setscreen ("offscreenonly")
setscreen ("graphics")

%Declaration section - List of all the Global Variables
var mainWin := Window.Open ("graphics:1000;640") %Opens and sets the size of the main window.
var font : int %The type of font I want my words to be.
var menuButton, startButton, instructButton, exitButton, newGame : int %GUI buttons used to maneuver through the game.
var playerCounter, player : int %Keeps track of whose turn it is.
var currentX, currentY, inputX, inputY : int %Keeps track of the chip's coordinates.
var rangeX, rangeY : int %Keeps track of which column the players click.
var redChip, yellowChip : array 1 .. 7, 1 .. 6 of boolean %A 2-d array keeping track of the X and Y location of a red or yellow chip.
var anyChip : array 1 .. 7, 1 .. 6 of boolean %A 2-d array keeping track of the X and Y location of any spot.
var buttonNumber, buttonUpDown : int %Parameters of the Mouse.ButtonWait function.
var winX, winY : array 1 .. 4 of int %Keeps track of the location of the winning chips - used to make the winning chips flash.
var winCounter : int := 0 %Keeps track of the number of winning chips in a row.

%Allows the procedures to be used throughout the program no matter where they are.
forward procedure mainMenu
forward procedure gameScreen

%The music that plays during the introduction.
process introMusic
    Music.PlayFile ("introMusic.wav")
end introMusic

%The music that plays throughout the game.
process gameMusic
    loop
	Music.PlayFile ("backgroundMusic.mp3")
    end loop
end gameMusic

%The soundEffect that plays when players click outside of the connect four board.
process soundEffect
    Music.PlayFile ("soundEffect.wav")
end soundEffect

%Outputs the title and clears the screen.
procedure title
    cls
    font := Font.New ("Eras Bold ITC:50")
    Font.Draw ("CONNECT FOUR", 230, 580, font, 12)
    for x : 0 .. 550 by 30
	drawfilloval (240 + x, 560, 10, 10, 100 - x div 15)
    end for
end title

%Program introduction - Introduction animation and menu button.
procedure introduction
    fork introMusic
    %Triangles at the corners of the pages.
    for x : 0 .. 99
	for y : 0 .. 850 by 8
	    drawline (900, 0, 999, x, 100 - y div 10)
	    drawline (0, x, 99, 0, 100 - y div 10)
	    drawline (0, 541 + x, 99, 640, 100 - y div 10)
	    drawline (900, 640, 999, 541 + x, 100 - y div 10)
	end for
    end for
    for x : 0 .. 250
	font := Font.New ("Eras Bold ITC:60")
	drawfillbox (280, 695 - x, 695, 635 - x, 0)
	Font.Draw ("CONNECT", 280, 640 - x, font, 12)
	View.Update
	delay (5)
    end for
    %Moving circles.
    for x : 0 .. 400
	drawfilloval (-91 + x, 300, 30, 30, 0)
	drawfilloval (430, -101 + x, 30, 30, 0)
	drawfilloval (550, -101 + x, 30, 30, 0)
	drawfilloval (1071 - x, 300, 30, 30, 0)
	drawfilloval (-90 + x, 300, 30, 30, black)
	drawfilloval (430, -100 + x, 30, 30, black)
	drawfilloval (550, -100 + x, 30, 30, black)
	drawfilloval (1070 - x, 300, 30, 30, black)
	font := Font.New ("Eras Bold ITC:35")
	Font.Draw ("F", -105 + x, 285, font, 12)
	Font.Draw ("O", 410, -115 + x, font, 12)
	Font.Draw ("U", 530, -115 + x, font, 12)
	Font.Draw ("R", 1055 - x, 285, font, 12)
	View.Update
	delay (5)
    end for
    menuButton := GUI.CreateButton (390, 100, 200, "Main Menu", mainMenu)
end introduction

%Displays the instructions of the game.
procedure instructions
    title
    font := Font.New ("Agency FB:20")
    Font.Draw ("Instructions:", 1, 500, font, black)
    drawfillbox (1, 492, 100, 495, black)
    Font.Draw ("~ This is a two player game.", 1, 450, font, black)
    Font.Draw ("~ Each player takes turns inserting red or yellow chips into the 6 x 7 game board.", 1, 400, font, black)
    Font.Draw ("~ The first player to get four same coloured chips in a horizontal, vertical, or diagonal line wins!", 1, 350, font, black)
    Font.Draw ("~ Player 1 =", 1, 300, font, black)
    Font.Draw ("~ Player 2 =", 1, 250, font, black)
    Font.Draw ("HAVE FUN!!", 458, 150, font, black)
    Font.Free (font)
    drawfilloval (125, 260, 15, 15, 44)
    drawfilloval (125, 310, 15, 15, 40)
    menuButton := GUI.CreateButton (400, 100, 200, "Main Menu", mainMenu)
end instructions

%Sets all the chip arrays to false.
procedure initialize
    for i : 1 .. 6
	for j : 1 .. 7
	    anyChip (j, i) := false
	end for
	yellowChip := anyChip
	redChip := anyChip
    end for
end initialize

%Finds the row available for where the new chip will be placed based on userInput (column that user choses).
procedure findX
    var found : boolean := false %Used to indicate empty spots for chips.
    for x : 1 .. 6
	if anyChip (inputY, 6) = true then
	    fork soundEffect %Sounds when a player tries to place a chip in an already full column.
	end if
	if anyChip (inputY, x) = false then
	    found := true
	    inputX := x
	    if player = 1 then
		redChip (inputY, inputX) := true
		drawfilloval (500 + (inputY - 1) * 60, 120 + (inputX - 1) * 60, 25, 25, 12)
	    else
		yellowChip (inputY, inputX) := true
		drawfilloval (500 + (inputY - 1) * 60, 120 + (inputX - 1) * 60, 25, 25, yellow)
	    end if
	    anyChip (inputY, inputX) := true
	    playerCounter := playerCounter + 1
	    exit when found
	end if
    end for
end findX

%Goes back to the input location when checking for a four in a row.
procedure reset
    currentY := inputY
    currentX := inputX
end reset

%Restarts the check for a four in a row starting at userInput.
procedure resetSearch
    winCounter := 1
    currentX := inputX
    currentY := inputY
    winX (winCounter) := currentX
    winY (winCounter) := currentY
end resetSearch

% Keeps track of the winning chip location.
procedure setWin
    winCounter := winCounter + 1
    winX (winCounter) := currentX
    winY (winCounter) := currentY
end setWin

%Causes player one's winning chips to flash.
procedure redWin
    %Causes red chips to flash.
    for i : 1 .. 4
	drawfilloval (500 + (winY (i) - 1) * 60, 120 + (winX (i) - 1) * 60, 25, 25, 12)
	delay (200)
	drawfilloval (500 + (winY (i) - 1) * 60, 120 + (winX (i) - 1) * 60, 25, 25, white)
	delay (200)
	drawfilloval (500 + (winY (i) - 1) * 60, 120 + (winX (i) - 1) * 60, 25, 25, 12)
	delay (200)
    end for
end redWin

%Causes player two's winning chips to flash.
procedure yellowWin
    for i : 1 .. 4
	%Causes yellow chips to flash.
	drawfilloval (500 + (winY (i) - 1) * 60, 120 + (winX (i) - 1) * 60, 25, 25, yellow)
	delay (200)
	drawfilloval (500 + (winY (i) - 1) * 60, 120 + (winX (i) - 1) * 60, 25, 25, white)
	delay (200)
	drawfilloval (500 + (winY (i) - 1) * 60, 120 + (winX (i) - 1) * 60, 25, 25, yellow)
	delay (200)
    end for
end yellowWin

%Window pops up and announces who wins.
procedure displayWinner
    var winnerWin := Window.Open ("position:200;300, graphics:600;200") %Opens and sets the size of the winner window.
    Window.Hide (mainWin)
    Window.Show (winnerWin)
    Window.SetActive (winnerWin)
    font := Font.New ("Agency FB:25")
    %Outputs a message if there are four of the same coloured chip in a row.
    if winCounter = 4 then
	Font.Draw ("Congratulations!", 1, 170, font, black)
	Font.Draw ("has won the game!", 70, 120, font, black)
	Font.Draw ("Press any key to return to the game screen....", 1, 50, font, black)
	%Shows either a red or yellow chip depending on which player wins.
	if player = 1 then
	    drawfilloval (35, 130, 23, 23, 12)
	else
	    drawfilloval (35, 130, 23, 23, yellow)
	end if
    end if
    loop
	exit when hasch
    end loop
    Window.Show (mainWin)
    Window.SetActive (mainWin)
    Window.Close (winnerWin)
end displayWinner

%Checks downwards from the inputted chip for a four in a row.
procedure checkBelow
    if currentX > 3 then
	loop
	    currentX := currentX - 1
	    if player = 1 then
		exit when currentX < 1 or not redChip (currentY, currentX) or winCounter = 4
	    else
		exit when currentX < 1 or not yellowChip (currentY, currentX) or winCounter = 4
	    end if
	    setWin
	end loop
    end if
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkBelow

%Checks right from the inputted chip for a four in a row.
procedure checkRight
    loop
	currentY := currentY + 1
	if player = 1 then
	    exit when currentY > 7 or not redChip (currentY, currentX) or winCounter = 4
	else
	    exit when currentY > 7 or not yellowChip (currentY, currentX) or winCounter = 4
	end if
	setWin
    end loop
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkRight

%Checks left from the inputted chip for a four in a row.
procedure checkLeft
    loop
	currentY := currentY - 1
	if player = 1 then
	    exit when currentY < 1 or not redChip (currentY, currentX) or winCounter = 4
	else
	    exit when currentY < 1 or not yellowChip (currentY, currentX) or winCounter = 4
	end if
	setWin
    end loop
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkLeft

%Checks NE from the inputted chip for a four in a row.
procedure checkNE
    loop
	currentX := currentX + 1
	currentY := currentY + 1
	if player = 1 then
	    exit when currentY > 7 or currentX > 6 or not redChip (currentY, currentX) or winCounter = 4
	else
	    exit when currentY > 7 or currentX > 6 or not yellowChip (currentY, currentX) or winCounter = 4
	end if
	setWin
    end loop
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkNE

%Checks SW from the inputted chip for a four in a row.
procedure checkSW
    loop
	currentX := currentX - 1
	currentY := currentY - 1
	if player = 1 then
	    exit when currentY < 1 or currentX < 1 or not redChip (currentY, currentX) or winCounter = 4
	else
	    exit when currentY < 1 or currentX < 1 or not yellowChip (currentY, currentX) or winCounter = 4
	end if
	setWin
    end loop
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkSW

%Checks SE from the inputted chip for a four in a row.
procedure checkSE
    loop
	currentX := currentX - 1
	currentY := currentY + 1
	if player = 1 then
	    exit when currentY > 7 or currentX < 1 or not redChip (currentY, currentX) or winCounter = 4
	else
	    exit when currentY > 7 or currentX < 1 or not yellowChip (currentY, currentX) or winCounter = 4
	end if
	setWin
    end loop
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkSE

%Checks NW from the inputted chip for a four in a row.
procedure checkNW
    loop
	currentX := currentX + 1
	currentY := currentY - 1
	if player = 1 then
	    exit when currentY < 1 or currentX > 6 or not redChip (currentY, currentX) or winCounter = 4
	else
	    exit when currentY < 1 or currentX > 6 or not yellowChip (currentY, currentX) or winCounter = 4
	end if
	setWin
    end loop
    if winCounter = 4 then
	if player = 1 then
	    redWin
	else
	    yellowWin
	end if
	displayWinner
    end if
end checkNW

%Window pops up when the whole board is filled but there is no winner.
procedure noWinner
    var noWin := Window.Open ("position:200;300, graphics:600;200") %Opens and sets the size of the display window.
    Window.Hide (mainWin)
    Window.Show (noWin)
    Window.SetActive (noWin)
    font := Font.New ("Agency FB:25")
    Font.Draw ("It's a tie!", 1, 170, font, black)
    Font.Draw ("Press any key to return to the game screen....", 1, 90, font, black)
    loop
	exit when hasch
    end loop
    Window.Show (mainWin)
    Window.SetActive (mainWin)
    Window.Close (noWin)
end noWinner

%User Input - Allows player to choose which column they want their chip to be placed.
procedure userInput
    menuButton := GUI.CreateButton (150, 280, 200, "Main Menu", mainMenu)
    newGame := GUI.CreateButton (150, 230, 200, "Restart", gameScreen)
    loop
	var newInput : boolean  %Keeps track of where the players click in the gameboard area.
	if playerCounter mod 2 = 0 then
	    player := 2
	    drawfilloval (260, 420, 25, 25, yellow)
	else
	    player := 1
	    drawfilloval (260, 420, 25, 25, 12)
	end if
	if playerCounter = 43 then
	    noWinner
	end if
	Mouse.ButtonWait ("down", rangeX, rangeY, buttonNumber, buttonUpDown)
	%Exits the loop when there are four chips are in a row.
	exit when winCounter = 4 and (rangeX >= 530 and rangeX <= 890) and (rangeY >= 90 and rangeY <= 450)
	%Checks which column the player clicks.
	if buttonUpDown = 1 then
	    delay (200)
	    newInput := true
	    if (rangeX >= 470 and rangeX <= 530) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 1
	    elsif (rangeX >= 530 and rangeX <= 590) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 2
	    elsif (rangeX >= 590 and rangeX <= 650) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 3
	    elsif (rangeX >= 650 and rangeX <= 710) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 4
	    elsif (rangeX >= 710 and rangeX <= 770) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 5
	    elsif (rangeX >= 770 and rangeX <= 830) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 6
	    elsif (rangeX >= 830 and rangeX <= 890) and (rangeY >= 90 and rangeY <= 450) then
		inputY := 7
	    else
		%Shows that mouse click is outside the game board area.
		fork soundEffect
		newInput := false
		exit when (rangeX >= 150 and rangeX <= 350) and (rangeY >= 280 and rangeY <= 303) or (rangeX >= 150 and rangeX <= 350) and (rangeY >= 230 and rangeY <= 253)
	    end if
	    %Checking to see if there are four of the same coloured chips in a horizontal, vertical, or diagonal row.
	    if newInput then
		findX
		resetSearch
		checkBelow
		if winCounter < 4 then
		    resetSearch
		    checkLeft
		    if winCounter < 4 then
			reset
			checkRight
		    end if
		end if
		if winCounter < 4 then
		    resetSearch
		    checkSW
		    if winCounter < 4 then
			reset
			checkNE
		    end if
		end if
		if winCounter < 4 then
		    resetSearch
		    checkSE
		    if winCounter < 4 then
			reset
			checkNW
		    end if
		end if
	    end if
	end if
    end loop
    if (rangeX >= 150 and rangeX <= 350) and (rangeY >= 280 and rangeY <= 303) then
	GUI.Hide (newGame)
	mainMenu
    end if
    if (rangeX >= 150 and rangeX <= 350) and (rangeY >= 230 and rangeY <= 253) then
	gameScreen
	if winCounter = 4 then
	    winCounter := 1
	    gameScreen
	end if
    end if
end userInput

%Main game screen of the program - Includes game board with chips placed by the player.
body procedure gameScreen
    GUI.Hide (startButton)
    GUI.Hide (instructButton)
    GUI.Hide (exitButton)
    initialize
    title
    drawbox (50, 500, 950, 50, 1)
    drawbox (45, 495, 955, 55, 1)
    drawfillbox (470, 450, 890, 90, 1)
    for y : 0 .. 350 by 60
	for x : 0 .. 400 by 60
	    drawfilloval (500 + x, 420 - y, 25, 25, 0)
	end for
    end for
    fork gameMusic
    font := Font.New ("Agency FB:35")
    Font.Draw ("It's player", 80, 400, font, black)
    Font.Draw ("'s turn.", 300, 400, font, black)
    playerCounter := 1
    userInput
end gameScreen

%End Screen - Includes name of programmer and goodbye statement.
procedure goodbye
    title
    font := Font.New ("Bradley Hand ITC:30")
    Font.Draw ("This game was created by Tiffany Tran.", 160, 360, font, 9)
    Font.Draw ("Thank you for playing!", 290, 280, font, 9)
    Font.Free (font)
    delay (5000)
    Window.Close (mainWin)
end goodbye

%Main menu of the program - the only place the user and exit the program.
body procedure mainMenu
    GUI.Hide (menuButton)
    title
    font := Font.New ("Times New Roman:30")
    Font.Draw ("MAIN MENU", 380, 460, font, 108)
    drawfillbox (380, 455, 613, 452, 108)
    startButton := GUI.CreateButton (400, 350, 200, "Start Game", gameScreen)
    instructButton := GUI.CreateButton (400, 300, 200, "Instructions", instructions)
    exitButton := GUI.CreateButton (400, 250, 200, "Exit", goodbye)
end mainMenu

%Main Program
introduction
loop
    exit when GUI.ProcessEvent
end loop
goodbye
%End Program


