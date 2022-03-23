import os, generator, system, math, terminal, sequtils, times
include entities, illwill # I have no idea why but I need to include entities or their objects don't work, and illwill because colors won't work
 
#--------------------------------\\--------------------------------#

const
    terminalHeight = 13
    terminalWidth = 25
    windowSize = 9
    enemyAmount = 8

var 
    tb = newTerminalBuffer(terminalWidth(), terminalHeight())
    running = true
    worldOriginal = generateWorld()
    currentWorld = worldOriginal
    world = worldOriginal
    player = Player(species: '@', att: 3, def: 3, acc: 10, hp: 10, mp: 10)
    camPos: tuple[x,y:int]
    entitySeq: seq[Entity]
    menu = 0
    level = 1
    time = cpuTime()
    tempSeq: seq[int]

proc placeExit() =
  let exit = chooseSpawn currentWorld
  currentWorld[exit.y][exit.x] = '>'

proc placeEntities() =
    entitySeq = @[]
    placeExit()
    player.pos = chooseSpawn(currentWorld)
    player.ppos = player.pos
    entitySeq.add(player)

    for i in 0..<enemyAmount:
        var temp = Enemies[0]
        deepCopy(temp, Enemies[0])
        temp.pos = chooseSpawn(currentWorld)
        temp.ppos = temp.pos
        temp.path = temp.pos
        entitySeq.add(temp)

placeEntities()

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

proc drawInitialTerminal() = # Thanks Goat
    var
        bb = newBoxBuffer(terminalWidth, terminalHeight)
    bb = newBoxBuffer(terminalWidth, terminalHeight)
    bb.drawRect(0,0,terminalWidth-1,2, doubleStyle=true)
    bb.drawRect(0,2,terminalWidth-1, terminalHeight-1, doubleStyle=true)
    bb.drawVertLine(windowSize+1, 2, terminalHeight)
    bb.drawHorizLine(windowSize+1, terminalWidth, 4)
    tb.setForegroundColor(fgYellow)
    tb.write(8,1,"~NimHack~")
    tb.write(bb)

proc clearMenu() =
    for y in 5..11:
        for x in 11..23:
            tb.write(x, y, " ")

proc drawToTerminal() = 
    tb.setForegroundColor(fgRed)
    tb.write(12,3,"HP:" & $player.hp)
    tb.setForegroundColor(fgCyan)
    tb.write(18,3,"MP:" & $player.mp)
    tb.setForegroundColor(fgMagenta)
    tb.write(1,2,"Level: ",fgBlue, $level)
    tb.resetAttributes()
    for tY in 3..windowSize+2:
        for tX in 1..windowSize:
            if world[camPos.y+tY-3][camPos.x+tX-1] == 'S':
                tb.setForegroundColor(fgRed)
            elif world[camPos.y+tY-3][camPos.x+tX-1] == '@':
                tb.setForegroundColor(fgYellow)
            elif world[camPos.y+tY-3][camPos.x+tX-1] == '>':
                tb.setForegroundColor(fgGreen)
            tb.write(tX, tY, $(world[camPos.y+tY-3][camPos.x+tX-1]))
            tb.resetAttributes()
    clearMenu()
    case menu
        of 0:
            tb.write(14,5, "-MENU-")
            tb.write(11, 7, "•(I)nventory")
            tb.write(11, 8, "•(S)pells")
        of 1:
            tb.write(12, 5, "-INVENTORY-")
            try:
                tb.write(11, 6, "W: " & player.inventory[0].name)
                tb.write(11, 7, "A: " & player.inventory[1].name)
            except:
                discard
        of 2:
            tb.write(13, 5, "-SPELLS-")
            for i in 0..<4:
                tb.write(11, 7+i, "•" & player.spells[i])
        else:
            discard
    tb.display()

    sleep(50)

proc changeLevel(restart: bool = false) =
  # Changes the level. Restarts the level if used as
  # changeLevel(true) or changeLevel(restart = true)
    if restart:
        currentWorld = worldOriginal
    else:
        currentWorld = generateWorld()
    placeEntities()
    inc level
    tb.setForegroundColor(fgMagenta)

proc getInput() = 
    var key = getKey()
    player.ppos = player.pos
    case key
        of Key.Up:
            player.pos.y -= 1
        of Key.Down:
            player.pos.y += 1
        of Key.Left:
            player.pos.x -= 1
        of Key.Right:
            player.pos.x += 1
        of Key.Backspace:
            menu = 0
        of Key.R:
            level = 0
            changeLevel(restart = true)
        of Key.I:
            if menu == 0:
                menu = 1
        of Key.S:
            if menu == 0:
                menu = 2
        of Key.Q:
            running = false
        else:
            discard

proc reset() =
    world = currentWorld

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

proc combat(e, p: Entity, index: int) =
    var
        att = e.att
        def = p.def
        acc = e.acc
    
    if rand(acc) >= def:
        p.hp -= rand(att)
    if index == 0:
        tb.write(0, 30, $p.hp)

proc dealCollision(e: Entity, index: int) =
    if world[e.pos.y][e.pos.x] == '#':
        e.pos = e.ppos
    elif world[e.pos.y][e.pos.x] == '>' and e == player:
        changeLevel()
    else:
        for i in 0..<entitySeq.len():
            if i != index:
                if entitySeq[i].pos == e.pos:
                    e.pos = e.ppos
                    if e.species != entitySeq[i].species:
                        if time - e.la >= 1.5:
                            combat(e, entitySeq[i], i)
                            e.la = time
                            if entitySeq[i].hp <= 0:
                                tempSeq.add(i)

proc dealEnemies() =
    for i in 1..<entitySeq.len():
        entitySeq[i].ppos = entitySeq[i].pos
        pathing(entitySeq[i])

proc update() =
    for i in 0..<tempSeq.len():
        tempSeq.delete(0)
    time = cpuTime()
    dealEnemies()
    for i in 0..<entitySeq.len():
        dealCollision(entitySeq[i], i)
        world[entitySeq[i].pos.y][entitySeq[i].pos.x] = entitySeq[i].species
    for i in 0..<tempSeq.len():
        entitySeq.delete(tempSeq[i]-i)
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
    drawInitialTerminal()
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
