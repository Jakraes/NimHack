import generator
import std/terminal
import random

randomize()

const
    tH = 11
    tW = 24
    windowSize = 9
var
    menuReset: array[tH, array[tW, char]]
    menu = menuReset
    temp: int

for line in lines("menu.txt"):
    for i in 0..<tW:
        menuReset[temp][i] = line[i]
    temp += 1

#-----------------------------------------------------------#

var 
    world = generateWorld()
    camPos, playerPos, previousPos: tuple[x, y: int]
    running = true
    hp, mp = 10
    floorCoordinates: seq[tuple[x,y:int]]
    steps = 0

for y in 0..<world.len():
    for x in 0..<world.len():
        if world[y][x] == '.':
            floorCoordinates.add((x,y))

playerPos = floorCoordinates[rand(floorCoordinates.len()-1)]
previousPos = playerPos
camPos = (playerPos.x-3, playerPos.y-3)

proc resetMenu() =
    menu = menuReset

proc drawScreen() = 
    camPos = (playerPos.x-int(windowSize/2), playerPos.y-int(windowSize/2))
    if camPos.x < 0:
        camPos = (0,camPos.y)
    if camPos.y < 0:
        camPos = (camPos.x,0)
    if camPos.x > world.len()-windowSize:
        camPos = (world.len()-windowSize,camPos.y)
    if camPos.y > world.len()-windowSize:
        camPos = (camPos.x,world.len()-windowSize)
    var 
        output: string
        hps = $hp
        mps = $mp
        stepss = $steps
    if hps.len() == 1:
        hps = "0" & hps
    if mps.len() == 1:
        mps = "0" & mps
    for i in 0..<(6-stepss.len()):
        stepss = "0" & stepss
    menu[1][tW-10] = hps[0]
    menu[1][tW-9] = hps[1]
    menu[1][tW-3] = mps[0]
    menu[1][tW-2] = mps[1]
    for i in 1..6:
        menu[3][tW-i-1] = stepss[6-i]
    for y in 0..<windowSize:
        for x in 0..<windowSize:
            menu[y+1][x+1] = world[camPos.y+y][camPos.x+x]
    menu[int(windowSize/2)+1+(playerPos.y - camPos.y - int(windowSize/2))][int(windowSize/2)+1+(playerPos.x - camPos.x - int(windowSize/2))] = '@'
    eraseScreen()
    setCursorPos(0,0)
    echo """+----------------------+
|       ~NimHack~      |"""
    for y in 0..<tH:
        for x in 0..<tW:
            output = output & menu[y][x]
        output = output & '\n'
    echo output

proc collision() =
    if world[playerPos.y][playerPos.x] == '#':
        playerPos = previousPos

proc getInput() =
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
echo """
+-------------------------+
|                         |
|  ~Welcome to NimHack!~  |
|           -~-           |
|  Press any key to play  |
|       or Q to quit      |
+-------------------------+
"""
while running:
    resetMenu()
    getInput()
    collision()
    drawScreen()