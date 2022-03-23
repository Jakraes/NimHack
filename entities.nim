import generator, random, times

type
    Item* = ref object of RootObj
        name, app: string
        att: int
    Entity* = ref object of RootObj
        species: char
        ppos, pos, path: tuple[x,y:int]
        att, def, acc, hp: int
        la: float
    Enemy* = ref object of Entity
        # Weird stuff going on here
    Player* = ref object of Entity
        mp, steps, xp: int
        wpn, arm: Item
        inventory*: array[7, Item]
        spells*: array[4, string] 


var
    Enemies* = [
        Enemy(species: 'S', att: 3, def: 3, acc: 10, hp: 3), 
        Enemy(species: 'T', att:5, def:6, acc:3, hp:10)
        ]

    Items* = [
        Item(name: "HP PT", app: "𝛿"),
        Item(name: "IRN SWRD", app: "⸸", att: 6),
        Item(name: "IRN ARMR", app: "T")
    ]

proc chooseSpawn*(world: array[MapSize, array[MapSize, char]]): tuple[x,y:int] =
    var temp: seq[tuple[x,y:int]]
    for y in 0..<world.len():
        for x in 0..<world.len():
            if world[y][x] == '.':
                temp.add((x,y))
    result = temp[rand(temp.len()-1)]