import generator
import std/terminal
import random

randomize()

const
    tH = 11 # Terminal Height (Actually the height of the menu.txt file)
    tW = 24 # Terminal Width (Actually the width of the menu.txt file)
    windowSize = 9 # Size of the window where the map will be drawn on
var
    menuReset: array[tH, array[tW, char]] # Array used to assign the menu back to its original state
    menu = menuReset # Actual menu
    temp: int
 
for line in lines("menu.txt"): # Building the menuReset array from the menu.txt file
    for i in 0..<tW:
        menuReset[temp][i] = line[i]
    temp += 1

#-----------------------------------------------------------#

var 
    world = generateWorld() # World array
    camPos, playerPos, previousPos: tuple[x, y: int] # Self explanatory
    running = true # Game running
    hp, mp = 10 # Self explanatory
    floorCoordinates: seq[tuple[x,y:int]] # Used to choose a spawn point
    steps = 0 # Self explanatory

for y in 0..<world.len(): # Building the floorCoordinates
    for x in 0..<world.len():
        if world[y][x] == '.':
            floorCoordinates.add((x,y))

playerPos = floorCoordinates[rand(floorCoordinates.len()-1)] # Chooses spawn point
previousPos = playerPos 
camPos = (playerPos.x-int(windowSize/2), playerPos.y-int(windowSize/2))

proc resetMenu() = # Resets the menu back to its original state
    menu = menuReset

proc drawScreen() = # Draws to the terminal
    camPos = (playerPos.x-int(windowSize/2), playerPos.y-int(windowSize/2)) # Top left corner of the game window 
    if camPos.x < 0:                                #
        camPos = (0,camPos.y)                       #
    if camPos.y < 0:                                #
        camPos = (camPos.x,0)                       #
    if camPos.x > world.len()-windowSize:           # > Basically ensures that the camera isn't outside of the map when it follows the player
        camPos = (world.len()-windowSize,camPos.y)  #
    if camPos.y > world.len()-windowSize:           #
        camPos = (camPos.x,world.len()-windowSize)  #
    var 
        output: string # Output string of the whole function
        hps = $hp
        mps = $mp
        stepss = $steps
    if hps.len() == 1: # Decides if it needs to add a 0 to a single digit number
        hps = "0" & hps
    if mps.len() == 1: # Same as above
        mps = "0" & mps
    for i in 0..<(6-stepss.len()): # Same as above pretty much
        stepss = "0" & stepss
    menu[1][tW-10] = hps[0] # 
    menu[1][tW-9] = hps[1]  # > Draws the HP and MP values to the menu array
    menu[1][tW-3] = mps[0]  #
    menu[1][tW-2] = mps[1]  #
    for i in 1..6: # Draws the step value
        menu[3][tW-i-1] = stepss[6-i]
    for y in 0..<windowSize: # Draws the local map to the menu
        for x in 0..<windowSize:
            menu[y+1][x+1] = world[camPos.y+y][camPos.x+x]
    menu[int(windowSize/2)+1+(playerPos.y - camPos.y - int(windowSize/2))][int(windowSize/2)+1+(playerPos.x - camPos.x - int(windowSize/2))] = '@' # Draws the player to the menu
    setCursorPos(0,0)
    echo """+----------------------+
|       ~NimHack~      |"""
    for y in 0..<tH: # Writes to output
        for x in 0..<tW:
            output = output & menu[y][x]
        output = output & '\n'
    echo output # Outputs

proc collision() = # Checks collision between the player and map tiles
    if world[playerPos.y][playerPos.x] == '#':
        playerPos = previousPos

proc getInput() = # Self explanatory
    let input = getch()
    previousPos = playerPos
    case input
        of '8':
            playerPos.y -= 1
        of '2':
            playerPos.y += 1
        of '4':
            playerPos.x -= 1
        of '6':
            playerPos.x += 1
        of '7':
            playerPos.x -= 1
            playerPos.y -= 1
        of '9':
            playerPos.x += 1
            playerPos.y -= 1
        of '1':
            playerPos.x -= 1
            playerPos.y += 1
        of '3':
            playerPos.x += 1
            playerPos.y += 1
        of 'q':
            running = false
        else:
            echo "No action assigned to " & input
    steps += 1

#-----------------------------------------------------------#
hideCursor()
echo """
+-------------------------+
|                         |
|  ~Welcome to NimHack!~  |
|           -~-           |
|  Press any key to play  |
|       or Q to quit      |
+-------------------------+
"""
discard getch()
eraseScreen()
while running: # Game loop
    resetMenu()
    getInput()
    collision()
    drawScreen()