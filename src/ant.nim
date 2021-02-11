import graph
import tables
import sets
import random
import truck
import algorithm
import sequtils

## Module that defines the behavior of an artifitial ant of the ant colony.

type
  ## Definition of the class that models the ants that construct solutions in
  ## the graph. The ant models a solution for the CVRP, so it keeps track of
  ## each ``truck`` in a hash table.
  ## The attribute ws indicates how many trucks have excess their capacity, if
  ## ws = 1, then no truck have an excess and the solution is feasible, if ws = 0
  ## then all the trucks have an excess and the solution is not feasible.
  Ant* = object
    numTrucks*:int
    trucks* :Table[int,Truck]
    capacity*:float
    cst*:float
    ws*:float
    quality*:float


proc delElem(s:var seq[tuple[id:int,cp:float]],e:tuple[id:int,cp:float])=
  ## Deletes a ``e`` demand from the list of client demands
  var
    j:int=0

  for i in s:
    if i == e:
      s.delete(j)
      break
    j=j+1


proc cost*(s:Ant,g:Graph):float=  #se puede optimizar en medio de la construcción de cada camión sumando cada costo?
  var cst:float
  for t in s.trucks.values:
    cst=cst+t.cst+g.clients[1][t.last].distance

  return cst


proc initAnt*(numT:int,capacity:float,trucks:Table[int,Truck],demands:seq[tuple[id:int,cp:float]],g:Graph):Ant=
  ## Initializes an ant, assigns each client randomly to a random truck and
  ## calculates the cost, ws and quality of the resulting solution.
  var
    s:Ant
    excess:HashSet[int]
    demands=demands
    c:(int,float)
    id:int

  s.numTrucks=numT
  s.capacity=capacity
  s.trucks=trucks

  while demands != @[]:
    id=rand(1..s.numTrucks)
    c=sample(demands)
    s.cst=s.cst-g.clients[s.trucks[id].last][1].distance+g.clients[s.trucks[id].last][c[0]].distance
    s.trucks[id].addClientRoute(c,g)
    s.cst=s.cst+g.clients[s.trucks[id].last][1].distance
    demands.delElem(c)

    if s.trucks[id].excess:
      excess.incl(id)

  s.ws=1-(excess.len()/s.numTrucks)

  return s


proc getProbabilities(tlast:int,d:seq[tuple[id:int,cp:float]],g:Graph):seq[(int,float)]=
  ## Gets the vector of probabilities of choosing each demand of the remaining
  ## ones, given the id of the last client in the route of the truck.
  var
    i:int=0
    pbs:seq[tuple[id:int,p:float]]
    T:float

  for c in d:
    T=T+g.clients[tlast][c.id].pheromone

  for c in d:
    pbs.add((i,g.clients[tlast][c.id].pheromone/T))  #sin alfa y Beta ni N(i,j)
    i=i+1

  return pbs


proc sampleTruck(a:Ant):int=
  ## Samples a truck from the hash table to add a new client. The trucks with
  ## less clients in their routes will have a greater probability than the ones
  ## with more clients.
  var
    pbsT:seq[float]
    qi,qj:float
    pT:float
    i:int=1

  for j in countup(1,a.numTrucks):
    if a.trucks[j].leftCapacity == 0:
      pbsT.add(0)
    else:
      pbsT.add(a.trucks[j].leftCapacity/a.capacity)

    pT=pT+pbsT[j-1]

  pbsT=map(pbsT, proc(x:float):float= return x/pT)
  qj=rand(1.0)

  for p in pbsT:
    if qi <= qj and qj < p+qi:
      break
    else:
      qi=qi+p
      i=i+1

  return i


proc constructSolution*(a:var Ant,q0:float,d:seq[(int,float)] ,g:Graph)=
  ## Construct a solution from zero, sampling each truck and sampling
  ## a new client demand using a distribution based in the pheromone model.
  var
    d=d
    t:int
    c:(int,float)
    l:int
    excess:HashSet[int]
    pbs:seq[tuple[id:int,p:float]]
    ri,rj,q:float

  while d != @[]:
    t=a.sampleTruck()
    #t=rand(1..a.numTrucks)
    pbs=getProbabilities(a.trucks[t].last,d,g)
    q=rand(1.0)
    #echo q, " ", q0
    if q <= q0:
      pbs=pbs.sortedByIt(it.p)
      c=d[pbs[len(pbs)-1].id]
      a.cst=a.cst-g.clients[a.trucks[t].last][1].distance+g.clients[a.trucks[t].last][c[0]].distance
      a.trucks[t].addClientRoute(c,g)
      a.cst=a.cst+g.clients[c[0]][1].distance
      d.delElem(c)

    else:
      ri=0.0
      rj=rand(1.0)

      for pid in pbs:
        if ri <= rj and rj < pid.p+ri:
          c=d[pid.id]
          a.cst=a.cst-g.clients[a.trucks[t].last][1].distance+g.clients[a.trucks[t].last][c[0]].distance
          a.trucks[t].addClientRoute(c,g)   #agrega la demanda a la ruta
          a.cst=a.cst+g.clients[c[0]][1].distance  #actualiza el costo
          d.delElem(c)
          break

        else:
          ri=ri+pid.p

    if a.trucks[t].excess:
      excess.incl(t)

  l=excess.len()
  a.ws=1-(l/a.numTrucks)

  if l > 0 :
    a.cst=a.cst*1.08


proc routePheromone*(a:Ant,g:var Graph,phi:float)=
  ## Updates the pheromones in the route constructed by the ant
  var
    i:int=1
    ti,tj:float

  tj=(phi*a.ws*a.quality)

  for t in a.trucks.values:
    for c in t.route:
      ti=g.clients[i][c].pheromone+tj #se actualiza la feromona de la arista
      g.clients[i][c].pheromone=ti
      g.clients[c][i].pheromone=ti
      i=c

    g.clients[i][1].pheromone=g.clients[i][1].pheromone+tj
    g.clients[1][i].pheromone=g.clients[i][1].pheromone


proc resetRoute*(a:var Ant)=
  ## Resets the ant to an empty solution with cost of zero and each truck with
  ## an empty route
  for i in countup(1,a.numTrucks):
    a.trucks[i].resetTruck(a.capacity)

  a.cst=0.0
  a.ws=0.0
  a.quality=0.0


proc solutionQuality*(a:var Ant,min,max:float)=
  ## Calculates the quality of the solution given the minimum and maximum cost
  ## obtain in the iteration.
  a.quality=1-((a.cst-min)/(max-min))


proc `$`*(a:Ant):string=
  ## Gets the representation of an ant as a string.
  var st:string
  st="ANT" & "\nNumTrucks:" & $a.numTrucks & "\nCost Solution: " & $a.cst
  for k,t in a.trucks.pairs:
    st=st & "\n" & $k & " " & $t

  return st
