import os
import strutils
import tables
import graph
import random
import antColony

## Module used to read the cvrp instances
proc readInstance*(instance:string,g:Graph,seed,numAnts:int):(AntColony,Graph)=
  ## Reads the instance passed as string if it exists, and creates the
  ## graph of the problem and the colony of ants .
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
      if line.startsWith("1 "):
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

  graph.initGraph(dim,clients)

  randomize(seed)
  c=initColony(numAnts,numT,capacity,0.6,0.75,graph,demands) #0.5 0.75

  return (c,graph)
