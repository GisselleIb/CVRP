import graph
import tables

type
  Truck* = object
    route*: seq[int]
    leftCapacity*:float
    numClients*:int
    last*:int
    excess*:bool
    cst*:float


proc initTruck*(capacity:float):Truck=
  var
    t:Truck

  t.leftCapacity=capacity
  t.numClients=0
  t.cst=0.0
  t.excess=false
  t.last=1
  return t


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

proc resetTruck*(t:var Truck,capacity:float)=
  t.route= @[]
  t.leftCapacity=capacity
  t.numClients=0
  t.last=1
  t.excess=false
  t.cst=0.0

proc `$`*(t:Truck):string=
  var st:string
  st="TRUCK\n" & "Route: " & $t.route & "\nLeft Capacity: " & $t.leftCapacity & "\nCost Truck: " & $t.cst
  return st
