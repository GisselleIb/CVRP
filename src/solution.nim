import graph
import tables
import random

type
  Solution* = object
    numTrucks*:int
    trucks*:Table[int,Truck]
    capacity*:float
    cst*:float

  Truck* = object
    route*:seq[int]
    leftCapacity*:float
    cst*:float

proc addClientRoute(t:var Truck,c:tuple[id:int,cp:float])=
  t.route.add(c.id)
  t.leftCapacity=t.leftCapacity-c.cp


proc initSolution(numT:int,capacity:float,trucks:Table[int,Truck],demands:seq[tuple[id:int,cp:float]]):Solution=
  var
    s:Solution
    demands=demands
    id:int

  s.numTrucks=numT
  s.capacity=capacity
  s.trucks=trucks

  while demands != @[]:
    id=rand(1..s.numTrucks)
    s.trucks[id].addClientRoute(demands[0])
    demands.delete(0)

  return s

proc cost*(s:Solution,g:Graph):float=
  for t in s.trucks:
    g
