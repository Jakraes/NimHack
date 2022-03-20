import std/random
import math

randomize()

const 
    RoomAmount = 6
    RoomSizeMin = 3
    RoomSizeMax = 6
    MaxDist = 15 # Max distance between rooms for corridors to be created
    MapSize = 25

var
    world: array[MapSize, array[MapSize, char]]
    roomCoordinates: array[RoomAmount, tuple[y: int, x: int]]

proc `^`(x, y: int): int = # Exponent function
    result = 1
    for i in 0..<y:
        result = result * x

proc distance (p1, p2: tuple[y: int, x: int]): float = # Calculates distance between two points in the world array
    result = float(((p2.x-p1.x)^2 + (p2.y-p1.y)^2)).sqrt()

proc generate(): array[MapSize, array[MapSize, char]] =

    for y in 0..<MapSize: # Fills the world array with the # character (wall)
        for x in 0..<MapSize:
            world[y][x] = '#'

    for i in 0..<RoomAmount: # Creates the rooms in the world array
        let
            w = rand(RoomSizeMin..RoomSizeMax) # / Width and height of the room
            h = rand(RoomSizeMin..RoomSizeMax) #/
            px = rand(0..<MapSize) # / Top left coordinates of the room 
            py = rand(0..<MapSize) #/
        
        for y in 0..<h: # Draws the room tiles to the world array
            for x in 0..<w:
                try:
                    world[y+py][x+px] = '.' 
                except:
                    continue
        var
            y = py + int(h/2) # / Center coordinates of the room
            x = px + int(w/2) #/
        
        if y >= MapSize: # Verifies if the coordinates do not exceed the world size to not cause exceptions
            y = MapSize - 1
        if x >= MapSize:
            x = MapSize - 1
        roomCoordinates[i] = (y: y, x: x) # Adds the center coordinates to the room array

    for i in 0..<RoomAmount: # Adds the corridors that connect the rooms in the world array
        for j in i+1..<RoomAmount:
            if distance(roomCoordinates[i], roomCoordinates[j]) <= MaxDist: # Verifies if the distance between rooms is short enough to create a corridor
                var xx, yy = 0
                if rand(1) == 0: # Chooses if the corridor starts vertically or horizontally
                    if roomCoordinates[j].y - roomCoordinates[i].y >= 0: # Checks if the delta is negative or not
                        for y in 0..(roomCoordinates[j].y - roomCoordinates[i].y):
                            world[roomCoordinates[i].y + y][roomCoordinates[i].x] = '.'
                            yy = roomCoordinates[i].y + y
                    else:
                        for y in countdown(0, roomCoordinates[j].y - roomCoordinates[i].y, 1): # Uses countdown because 0..(negative number) doesn't work
                            world[roomCoordinates[i].y + y][roomCoordinates[i].x] = '.'
                            yy = roomCoordinates[i].y + y

                    if roomCoordinates[j].x - roomCoordinates[i].x >= 0:
                        for x in 0..(roomCoordinates[j].x - roomCoordinates[i].x):
                            world[yy][roomCoordinates[i].x + x] = '.'
                    else:
                        for x in countdown(0, roomCoordinates[j].x - roomCoordinates[i].x, 1):
                            world[yy][roomCoordinates[i].x + x] = '.'

                else:
                    if roomCoordinates[j].x - roomCoordinates[i].x >= 0:
                        for x in 0..(roomCoordinates[j].x - roomCoordinates[i].x):
                            world[roomCoordinates[i].y][roomCoordinates[i].x + x] = '.' 
                            xx = roomCoordinates[i].x + x
                    else:
                        for x in countdown(0, roomCoordinates[j].x - roomCoordinates[i].x, 1):
                            world[roomCoordinates[i].y][roomCoordinates[i].x + x] = '.' 
                            xx = roomCoordinates[i].x + x

                    if roomCoordinates[j].y - roomCoordinates[i].y >= 0:
                        for y in 0..(roomCoordinates[j].y - roomCoordinates[i].y):
                            world[roomCoordinates[i].y + y][xx] = '.'
                    else:
                        for y in countdown(0, roomCoordinates[j].y - roomCoordinates[i].y, 1):
                            world[roomCoordinates[i].y + y][xx] = '.'
    
    for y in 0..<MapSize:
        for x in 0..<MapSize:
            if y == 0 or y == MapSize-1 or x == 0 or x == MapSize-1:
                world[y][x] = '#'
    return world

proc generateWorld*(): array[MapSize, array[MapSize, char]] =
    var count = 0
    while count <= int((MapSize*MapSize)/3):
        count = 0
        for y in 0..<MapSize:
            for x in 0..<MapSize:
                world[y][x] = '#' 
        world = generate()
        for y in 0..<MapSize:
            for x in 0..<MapSize: 
                if world[y][x] == '.':
                    count += 1
    return world