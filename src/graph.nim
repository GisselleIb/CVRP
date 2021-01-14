import strutils
import math

type

  Graph*[size:static[int]]=ref object
    dim* : int
    clients* :array[1..size,array[1..size,tuple[distance:float,pheromone:float]]]

proc initGraph*(g:var Graph,size:int,clients:seq[tuple[x:float,y:float]])=
  var
    n:int=len(clients)
    d:float

  g.dim=n

  for i in countup(0,n-2):
    for j in countup(i+1,n-1):
      d=sqrt((clients[j].x-clients[i].x)^2 + (clients[j].y-clients[i].y)^2)
      g.clients[i+1][j+1]=(d,0.0)
      echo "Distance: ", d
