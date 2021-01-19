import graph
import tables

type
  Truck* = object
    route*:seq[int]
    leftCapacity*:float
    numClienst*:int
    last*:int
    excess*:bool
    cst*:float


proc initTruck*(capacity:float):Truck=
  var
    t:Truck

  t.leftCapacity=capacity
  t.cst=0.0
  t.excess=false


proc getTrucks*(numTrucks:int,capacity:float):Table[int,Truck]=
  var
    trucks:Table[int,Truck]

  for i in countup(1,numTrucks):
    trucks[i]=initTruck(capacity)

  return trucks


proc cost*(t:var Truck,g:Graph)=
  var
    i,j:int

  for k in countup(0,len(t.route)-2):
    i=t.route[k]
    j=t.route[k+1]
    t.cst=t.cst+g.clients[i][j]


proc addClientRoute*(t:var Truck,c:tuple[id:int,cp:float],g:Graph)=
  t.route.add(c.id)
  t.leftCapacity=t.leftCapacity-c.cp
  t.numClients=t.numClients+1
  t.cst=t.cst+g.clients[t.last][c.id].distance
  t.last=c.id

  if t.leftCapacity < 0:
    t.excess=true
