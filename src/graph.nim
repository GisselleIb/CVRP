import math

## Module that defines the class and procedures needed for modeling the graph
## that the ants will be using.

type
  ## Definition of the graph, it is modeled like an adjacency matrix and it
  ## keeps track of the pheromone levels in all the edges.
  Graph*[size:static[int]]=ref object
    dim* : int
    clients*:array[1..size,array[1..size,tuple[distance:float,pheromone:float]]]


proc initGraph*(g:var Graph,size:int,clients:seq[tuple[x:float,y:float]])=
  ## Constructs a graph, given a number of clients and their coordinates.
  ## The graph is complete and the distances are Euclidian.
  var
    n:int=size
    d:float

  g.dim=n

  for i in countup(1,n):
    for j in countup(i,n):
      if i == j:
        g.clients[i][j]=(0.0,0.0)
      else:
        d=sqrt((clients[j-1].x-clients[i-1].x)^2 + (clients[j-1].y-clients[i-1].y)^2)
        g.clients[i][j]=(d,100.0)
        g.clients[j][i]=(d,100.0)


proc resetGraph*(g:var Graph)=
  ## Resets the graph to its default values
  for i in countup(1,g.dim):
    for j in countup(i,g.dim):
      if i != j:
        g.clients[i][j].pheromone=100.0
        g.clients[j][i].pheromone=100.0


proc `$`*(g:Graph):string=
  ## Method to string, shows the representation of the graph as a string
  var st:string
  for i in countup(1,g.dim):
    for j in countup(i,g.dim):
      st=st & $i & " " & $j & " " & $g.clients[i][j] & "\n"

  return st
