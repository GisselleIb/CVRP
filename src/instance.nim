import os
import strutils
import tables
import graph
import random
import antColony

proc readInstance*(instance:string,g:Graph,seed:int):(AntColony,Graph)=
  var
    graph=g
    c:AntColony
    dim,numT:int
    capacity:float
    l:seq[string]
    clients:seq[tuple[x:float,y:float]]
    demands:seq[tuple[id:int,cp:float]]
    nodeCoord:bool=false
    demandsect:bool=false

  new(graph)
  let file=open(instance)

  for line in file.lines:

    if line.startsWith("DEPOT_SECTION"):
        demandsect=false
    elif line.startsWith("DEMAND_SECTION"):
      demandsect=true
      nodeCoord=false
    elif nodeCoord :
      l=line.split(" ")
      clients.add((parseFloat(l[2]),parseFloat(l[3])))
    elif demandsect :
      if line.startsWith("1"):
        continue
      l=line.split(" ")
      demands.add((parseInt(l[0]),parseFloat(l[1])))
    elif line.startsWith("DIMENSION"):
      dim=parseInt(line.split(" ")[2])
    elif line.startsWith("CAPACITY"):
      capacity=parseFloat(line.split(" ")[2])
    elif line.startsWith("NODE_COORD_SECTION"):
      nodeCoord=true
    elif line.startsWith("NAME"):
      continue
    elif line.startsWith("COMMENT"):
      l=line.split(" ")
      for i in countup(3,len(l)-1):
        if l[i] == "trucks:":
          numT=parseInt(strip(l[i+1], chars={','}))
    elif line.startsWith("EDGE_WEIGHT_TYPE"):
      continue
    elif line.startsWith("EOF"):
      continue

  file.close()

  randomize(seed)
  graph.initGraph(dim,clients)
  c=initColony(15,numT,capacity,0.6,0.5,graph,demands)

#  s=initAnt(numT,capacity,trucks,demands,graph)
  #echo "Solution:",s.cst
  #for t in s.trucks.values:
  #  echo t.route, t.leftCapacity
  #s.quality=0.4
  #echo s.ws
  #for i in countup(1,graph.dim-1):
  #  for j in countup(i+1,graph.dim):
  #    graph.clients[i][j].pheromone=(1-0.7)*graph.clients[i][j].pheromone
  #    graph.clients[j][i].pheromone=graph.clients[i][j].pheromone
#  #s.routePheromone(graph,0.7)
  #.resetRoute()
  #for i in countup(1,graph.dim-1):
  #  for j in countup(i+1,graph.dim):
  #    echo graph.clients[i][j]
  #s.constructSolution(0.5,demands,graph)
  #echo "Solution:",s.cst
  #for t in s.trucks.values:
  #  echo t.route, t.leftCapacity


  return (c,graph)
