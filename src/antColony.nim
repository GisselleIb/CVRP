import ant
import graph
import truck
import tables
import algorithm

type AntColony* =ref object
  size:int
  ants* :seq[Ant]
  q0:float
  phi*:float
  demands*:seq[tuple[id:int,cp:float]]
  numTrucks*:int
  best*:Ant



proc construction*(colony:var AntColony,g:Graph):(float,float)=
  var
    demands=colony.demands
    max,min:float

  max=0.0
  min=high(BiggestFloat)

  for i in countup(0,colony.size-1):
    colony.ants[i].resetRoute()
    colony.ants[i].constructSolution(colony.q0,demands,g)

    if colony.ants[i].cst < min:
      min=colony.ants[i].cst
      colony.best=colony.ants[i]
    if colony.ants[i].cst > max:
      max=colony.ants[i].cst

  return (min,max)


proc antQuality(colony:var AntColony,min,max:float)=
  for i in countup(0,colony.size-1):
    colony.ants[i].solutionQuality(min,max)


proc pheromoneUpdate*(colony:AntColony,g:var Graph)=
  for i in countup(1,g.dim-1):
    for j in countup(i+1,g.dim):
      g.clients[i][j].pheromone=(1-colony.phi)*g.clients[i][j].pheromone
      g.clients[j][i].pheromone=g.clients[i][j].pheromone

  #colony.ants=colony.ants.sortedByIt(it.cst)
  #echo "nvsknvsdknvdsknvdsnvsdjknvsdkjnvdsknvsd", colony.ants

  for a in colony.ants:
    a.routePheromone(g,colony.phi)


proc initColony*(size,numTrucks:int,capacity,q0,phi:float,g:var Graph,d:seq[tuple[id:int,cp:float]]):AntColony=
  var
    colony:AntColony
    trucks:Table[int,Truck]=getTrucks(numTrucks,capacity)
    max,min:float

  new(colony)
  colony.size=size
  colony.numTrucks=numTrucks
  colony.demands=d
  colony.phi=phi
  colony.q0= q0

  max=0.0
  min=high(BiggestFloat)

  for i in countup(1,size):
    colony.ants.add(initAnt(numTrucks,capacity,trucks,d,g))

    if colony.ants[i-1].cst < min:
      min=colony.ants[i-1].cst
      colony.best=colony.ants[i-1]

    if colony.ants[i-1].cst > max:
      max=colony.ants[i-1].cst

  colony.antQuality(min,max)
  colony.pheromoneUpdate(g)

  return colony


proc antSystem*(colony:var AntColony,g:var Graph,iterations:int):Ant=
  var
    min,max:float

  #echo $g
  for i in countup(1,iterations):
    (min,max)=colony.construction(g)
    colony.antQuality(min,max)
    colony.pheromoneUpdate(g)
    echo colony.best.cst

  return colony.best
