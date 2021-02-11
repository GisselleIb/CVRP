import ant
import graph
import truck
import tables
import algorithm

## Module that defines the behavior of the heuristic. Models the colony and
## constructs a pheromone model by each iteration
type AntColony* =ref object
  size:int
  ants* :seq[Ant]
  q0:float
  phi*:float
  demands*:seq[tuple[id:int,cp:float]]
  numTrucks*:int
  best*:Ant



proc construction*(colony:var AntColony,g:Graph):(float,float)=
  ## Sends all the ants to construct a solution using the model of pheromones
  ## in the graph, obtains then minimum and maximum cost in the colony.
  var
    demands=colony.demands
    max,min:float

  max=0.0
  min=high(BiggestFloat)

  for i in countup(0,colony.size-1):
    if colony.ants[i].cst != colony.best.cst:
      colony.ants[i].resetRoute()
      colony.ants[i].constructSolution(colony.q0,demands,g)

    if colony.ants[i].cst < min:
      min=colony.ants[i].cst
      if min < colony.best.cst :
        echo min," ", colony.best.cst
        colony.best=colony.ants[i]
    if colony.ants[i].cst > max:
      max=colony.ants[i].cst

  return (min,max)


proc antQuality(colony:var AntColony,min,max:float)=
  ## Gets the quality of each solution constructed by the ants, given the best
  ## and worst solution constructed in the iteration.
  for i in countup(0,colony.size-1):
    colony.ants[i].solutionQuality(min,max)


proc pheromoneUpdate*(colony:AntColony,g:var Graph)=
  ## Evaporates a certain amount of pheromones in all the edges of the graph
  ## and sends all the ants to update the pheromones of the solution they
  ## constructed
  for i in countup(1,g.dim-1):
    for j in countup(i+1,g.dim):
      g.clients[i][j].pheromone=colony.phi*g.clients[i][j].pheromone
      g.clients[j][i].pheromone=g.clients[i][j].pheromone


  for a in colony.ants:
    a.routePheromone(g,0.95)


proc initColony*(size,numTrucks:int,capacity,q0,phi:float,g:var Graph,d:seq[tuple[id:int,cp:float]]):AntColony=
  ## Initializes the colony, creates the ants and initializes them randomly for
  ## for the first iteration.
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
  ## Runs the heuristic. In each iteration, all the ants construct a solution and
  ## then updates the pheromone levels in the edges of the graph.
  ## This process repeats itself for a number of iterations.
  var
    min,max:float

  for i in countup(1,iterations):
    (min,max)=colony.construction(g)
    colony.antQuality(min,max)
    colony.pheromoneUpdate(g)

    #echo min
  return colony.best
