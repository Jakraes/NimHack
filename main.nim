import os, illwill, generator, system, math
include entities

#--------------------------------\\--------------------------------#

const
    terminalHeight = 13
    terminalWidth = 24
    windowSize = 9
    enemyAmount = 8

var 
    running = true
    worldOriginal = generateWorld()
    world = worldOriginal
    player = Player(species: '@', att: 3, def: 3, acc: 3, hp: 10, mp: 10)
    camPos: tuple[x,y:int]
    entitySeq: seq[Entity]

player.pos = chooseSpawn(world)
player.ppos = player.pos
entitySeq.add(player)

for i in 0..<enemyAmount:
    var temp = Enemy()
    deepCopy(temp, Enemies[0])
    temp.pos = chooseSpawn(world)
    temp.ppos = temp.pos
    temp.path = temp.pos
    entitySeq.add(temp)

#--------------------------------\\--------------------------------#

proc normalize(x: float|int): int = 
    if x < 0:
        return -1
    elif x > 0:
        return 1
    else:
        return 0

proc distance(e: Entity): float =
    result = sqrt(float((e.pos.x - player.pos.x)^2 + (e.pos.y - player.pos.y)^2))
#--------------------------------\\--------------------------------#

proc drawToTerminal() = 
    var 
        tb = newTerminalBuffer(terminalWidth(), terminalHeight())
        bb = newBoxBuffer(terminalWidth, terminalHeight)
    bb = newBoxBuffer(terminalWidth, terminalHeight)
    bb.drawRect(0,0,terminalWidth-1,2, doubleStyle=true)
    bb.drawRect(0,2,terminalWidth-1, terminalHeight-1, doubleStyle=true)
    bb.drawVertLine(windowSize+1, 2, terminalHeight)
    bb.drawHorizLine(windowSize+1, terminalWidth, 4)
    tb.write(7,1,"~NimHack~")
    for tY in 3..windowSize+2:
        for tX in 1..windowSize:
            tb.write(tX, tY, $(world[camPos.y+tY-3][camPos.x+tX-1]))
    tb.write(bb)
    tb.display()

    sleep(50)

proc getInput() = 
    var key = getKey()
    player.ppos = player.pos
    case key
        of Key.Eight:
            player.pos.y -= 1
        of Key.Two:
            player.pos.y += 1
        of Key.Four:
            player.pos.x -= 1
        of Key.Six:
            player.pos.x += 1
        of Key.Q:
            running = false
        else:
            discard

proc reset() =
    world = worldOriginal

proc pathing(e: Entity) =
    if distance(e) < 5:
        e.path = player.pos
    if e.pos != e.path:
        if rand(5) == 0:
            let
                xd = normalize(e.path.x - e.pos.x)
                yd = normalize(e.path.y - e.pos.y)
            if rand(2) == 0:
                e.pos.x += xd
            if rand(2) == 0:
                e.pos.y += yd
    else:
        e.path = chooseSpawn(world)

proc dealCollision(e: Entity, index: int) =
    if world[e.pos.y][e.pos.x] == '#':
        e.pos = e.ppos
    else:
        for i in 0..<entitySeq.len():
            if i != index:
                if entitySeq[i].pos == e.pos:
                    e.pos = e.ppos


proc dealEnemies() =
    for i in 1..<entitySeq.len():
        entitySeq[i].ppos = entitySeq[i].pos
        pathing(entitySeq[i])

proc update() =
    dealEnemies()
    for i in 0..<entitySeq.len():
        dealCollision(entitySeq[i], i)
        world[entitySeq[i].pos.y][entitySeq[i].pos.x] = entitySeq[i].species
    camPos = (player.pos.x-4, player.pos.y-4)
    if camPos.x < 0:
        camPos.x = 0
    elif camPos.x > MapSize - windowSize:
        camPos.x = MapSize - windowSize
    if camPos.y < 0:
        camPos.y = 0
    elif camPos.y > MapSize - windowSize:
        camPos.y = MapSize - windowSize


#--------------------------------\\--------------------------------#

proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0)

proc main() =
    illwillInit(fullscreen=true)
    setControlCHook(exitProc)
    hideCursor()

    while running:
        reset()
        getInput()
        update()
        drawToTerminal()

    exitProc()

main()
