import graph
import tables
import random
import truck

type
  Solution* = ref object
    numTrucks*:int
    trucks*:Table[int,Truck]
    capacity*:float
    cst*:float


proc initSolution(numT:int,capacity:float,trucks:Table[int,Truck],demands:seq[tuple[id:int,cp:float]],g:Graph):Solution=
  var
    s:Solution
    demands=demands
    id:int

  new(s)
  s.numTrucks=numT
  s.capacity=capacity
  s.trucks=getTrucks(numT,capacity)

  while demands != @[]:
    id=rand(1..s.numTrucks)
    s.trucks[id].addClientRoute(demands[0],g)
    demands.delete(0)

  #for t in trucks:
  #  t.cst=t.cst+g.clients[1][t.last]

  s.cst=s.cost(g)

  return s

proc cost*(s:Solution,g:Graph):float=
  for t in s.trucks:
    s.cst=s.cst+t.cst+g.clients[1][t.last]

  return s.cst
