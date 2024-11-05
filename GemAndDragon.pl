:- dynamic at/2, i_am_at/1, alive/1, coins/1, has_ruby/0.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)), retractall(coins(_)), retractall(has_ruby).

% Define the initial player location and coins.
i_am_at(forest).
coins(0).

% Define the pathways between game locations.
path(forest, n, village).
path(village, s, forest).
path(village, e, castle).
path(castle, w, village).
path(forest, e, cave).
path(cave, w, forest).
path(forest, w, river).
path(river, e, forest).
path(forest, s, campsite).
path(campsite, n, forest).
path(cave, e, dungeon).
path(dungeon, w, cave).

% Define the locations of objects and enemies.
at(key, castle).
at(shield, cave).
at(torch, campsite).
at(ruby, dungeon).
alive(dragon).

take(X) :- 
    at(X, in_hand),
    write('You''re already holding it!'), nl, !.
take(sword) :- 
    write('You need to buy the sword from the blacksmith first.'), nl, !.
take(X) :- 
    i_am_at(Place),
    at(X, Place),
    retract(at(X, Place)),
    assert(at(X, in_hand)),
    write('You took the '), write(X), write('.'), nl, !.
take(_) :- 
    write('I don''t see it here.'), nl.

drop(X) :-
    at(X, in_hand),
    i_am_at(Place),
    retract(at(X, in_hand)),
    assert(at(X, Place)),
    write('You dropped the '), write(X), write('.'), nl, !.
drop(_) :- 
    write('You aren''t holding it!'), nl.

n :- go(n).
s :- go(s).
e :- go(e).
w :- go(w).

go(Direction) :-
    i_am_at(Here),
    path(Here, Direction, There),
    (There = dungeon -> enter_dungeon ; move_to(There)), !.
go(_) :- write('You can''t go that way.'), nl.

move_to(There) :-
    retract(i_am_at(_)),
    assert(i_am_at(There)),
    look.

% Logic for entering the dungeon. This is a separate predicate because it has special rules.
enter_dungeon :-
    at(key, in_hand),
    write('You used the key to unlock the dungeon door and entered.'), nl,
    assert(has_ruby),
    move_to(dungeon), !.
enter_dungeon :-
    write('The dungeon door is locked. You need a key to enter.'), nl.

look :- 
    i_am_at(Place),
    describe(Place), nl,
    notice_objects_at(Place), nl.

% Logic for noticing objects at a location.
notice_objects_at(Place) :- 
    at(X, Place), 
    write('There is a '), write(X), write(' here.'), nl, fail.
notice_objects_at(_).

% Define the logic for killing enemies.
kill :-
    i_am_at(castle),
    write('Oh no! You have been captured by the guards.'), nl, die.
kill :-
    i_am_at(cave),
    write('The dragon is too strong to defeat here!'), nl.
kill :-
    i_am_at(forest),
    at(sword, in_hand),
    at(shield, in_hand),
    has_ruby,
    retract(alive(dragon)),
    write('It was a tough battle...'), nl,
    wait(1), nl,
    write('You defeated the dragon! Congratulations, you won the game!'), nl, !.
kill :-
    i_am_at(forest),
    write('You are no match for the dragon without the ruby, sword, and shield!'), nl, die.
kill :- 
    write('There is nothing to fight here.'), nl.

die :- finish.

finish :- 
    nl, write('Game over. Enter halt to quit.'), nl, !.

% Define the instructions for the game.
instructions :- 
    nl,
    write('Available commands are:'), nl,
    write('start.                   -- to start the game.'), nl,
    write('n.  s.  e.  w.   -- to go in that direction.'), nl,
    write('take(Object).            -- to pick up an object.'), nl,
    write('drop(Object).            -- to put down an object.'), nl,
    write('kill.                    -- to attack an enemy.'), nl,
    write('look.                    -- to look around you again.'), nl,
    write('instructions.            -- to see this message again.'), nl,
    write('halt.                    -- to end the game and quit.'), nl,
    write('map.                     -- to see the map of the game.'), nl,
    write('fish.                    -- to catch fish for coins.'), nl,
    write('buy(Object).             -- to buy something from the blacksmith.'), nl, nl.

start :- 
    instructions,
    look.

% Define the descriptions for each location.
describe(forest) :- 
    alive(dragon),
    write('You are in a dense forest. A path leads north to a village, east to a cave, and west to a river.'), nl,
    write('Your mission is to recover the stolen ruby and defeat the dragon.'), nl,
    write('There is a fierce dragon in the deep forest!'), nl.
    
describe(village) :- 
    write('You are in a small village. A path leads south to the forest and east to a castle.'), nl,
    write('You see a blacksmith selling weapons, there is an amazing sword costing 5 coins.'), nl.

describe(castle) :- 
    write('You are in front of a castle. Guards are patrolling the area. The path leads west to the village.'), nl.

describe(cave) :- 
    at(torch, in_hand),
    write('You are in a dark cave. You see a shiny object on the ground. A path leads west to the forest and east to a dungeon.'), nl.

describe(cave) :- 
    write('It''s too dark to enter the cave without a torch!'), nl.

describe(river) :- 
    write('You are by a river. The water looks deep and dangerous, but there might be fish here. A path leads east to the forest.'), nl.

describe(campsite) :- 
    write('You are at a campsite. You can find a torch here.'), nl.

describe(dungeon) :- 
    write('You are in the dungeon. A ruby gleams in the darkness, adding to your strength for the final battle.'), nl.

describe(dragon) :- 
    alive(dragon),
    write('You encounter a fierce dragon! It breathes fire at you.'), nl.
describe(dragon) :- 
    write('The dragon lies defeated on the ground.'), nl.

help :- instructions.

% Player can use this command to see the map of the game.
map :- 
    write('Map of the game:'), nl,
    write('            village---castle'), nl,
    write('                  |'), nl,
    write('river---forest---cave---dungeon'), nl,
    write('                  |'), nl,
    write('            campsite'), nl.

% The logic for fishing. Player can catch fish for coins.
fish :- 
    i_am_at(river),
    random(0, 2, Result),
    (Result = 0 -> 
        write('You caught a fish!'), nl,
        coins(CurrentCoins),
        NewCoins is CurrentCoins + 1,
        retract(coins(CurrentCoins)), 
        assert(coins(NewCoins)),
        write('You now have '), write(NewCoins), write(' coins.'), nl;
        write('You didn''t catch anything this time.'), nl).

% The logic for buying items from the blacksmith.
buy(Object) :- 
    Object = sword,
    i_am_at(village),
    coins(CurrentCoins),
    (CurrentCoins >= 5 -> 
        NewCoins is CurrentCoins - 5,
        retract(coins(CurrentCoins)), 
        assert(coins(NewCoins)),
        write('You bought a sword from the blacksmith!'), nl,
        assert(at(sword, in_hand));
        write('You don''t have enough coins to buy a sword!'), nl).
