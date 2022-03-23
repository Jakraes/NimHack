import generator, random

type
    Entity* = ref object of RootObj
        species: char
        ppos, pos, path: tuple[x,y:int]
    Enemy* = ref object of Entity
        att, def, acc, hp: int
    Player* = ref object of Entity
        att, def, acc, hp, mp, steps, xp: int
        inventory: array[7, string]
        spells: array[4, string] 


var
    Enemies* = [
        Enemy(species: 'S', att: 3, def: 3, acc: 3, hp: 3), 
        Enemy(species: 'T', att:5, def:6, acc:3, hp:10)
        ]

    #Items* = [
    #    object(name: "Health Potion")
    #]

proc chooseSpawn*(world: array[MapSize, array[MapSize, char]]): tuple[x,y:int] =
    var temp: seq[tuple[x,y:int]]
    for y in 0..<world.len():
        for x in 0..<world.len():
            if world[y][x] == '.':
                temp.add((x,y))
    result = temp[rand(temp.len()-1)]