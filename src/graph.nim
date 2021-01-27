import math

type

  Graph*[size:static[int]]=ref object
    dim* : int
    clients*:array[1..size,array[1..size,tuple[distance:float,pheromone:float]]]

proc initGraph*(g:var Graph,size:int,clients:seq[tuple[x:float,y:float]])=
  var
    n:int=len(clients)
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

proc `$`*(g:Graph):string=
  var st:string
  for i in countup(1,g.dim):
    for j in countup(i,g.dim):
      st=st & $i & " " & $j & " " & $g.clients[i][j] & "\n"

  return st
