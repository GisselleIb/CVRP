import graph
import tables

## Module that defines the behavior and attributes of a vehicle in CVRP.
type
  ## Definition of the class that models the vehicle that deliver packages to
  ## customers. All the vehicles are initialize with the same capacity.
  ## The route that a vehicle follows is defined with a sequence of the ids of
  ## the clients, it does not include the id of the depot.
  Truck* = object
    route*: seq[int]
    leftCapacity*:float
    numClients*:int
    last*:int
    excess*:bool
    cst*:float


proc initTruck*(capacity:float):Truck=
  ## Initializes a truck with its leftCapacity intact, without a route and the
  ## cost in 0.0.
  var
    t:Truck

  t.leftCapacity=capacity
  t.numClients=0
  t.cst=0.0
  t.excess=false
  t.last=1
  return t


proc getTrucks*(numTrucks:int,capacity:float):Table[int,Truck]=
  ## Creates a hash table with the values being empty trucks, and the keys the ids of
  ## the trucks
  var
    trucks:Table[int,Truck]

  for i in countup(1,numTrucks):
    trucks[i]=initTruck(capacity)

  return trucks


proc cost*(t:var Truck,g:Graph)=
  var
    i,j:int
  t.cst=0
  for k in countup(0,len(t.route)-2):
    i=t.route[k]
    j=t.route[k+1]
    t.cst=t.cst+g.clients[i][j].distance
    #echo i, " ", j, " ", g.clients[i][j].distance

  t.cst=t.cst+g.clients[1][t.route[0]].distance+g.clients[1][t.route[len(t.route)-1]].distance
  echo t.cst


proc addClientRoute*(t:var Truck,c:tuple[id:int,cp:float],g:Graph)=
  ## Adds the id of a client to the route of the truck and updates its
  ## ``leftCapacity``, if it is less than 0 then ``excess`` is updated to true.
  t.route.add(c.id)
  t.leftCapacity=t.leftCapacity-c.cp
  t.numClients=t.numClients+1
  t.cst=t.cst+g.clients[t.last][c.id].distance
  t.last=c.id

  if t.leftCapacity < 0:
    t.excess=true

proc resetTruck*(t:var Truck,capacity:float)=
  ## Resets the truck and returns its values to default.
  t.route= @[]
  t.leftCapacity=capacity
  t.numClients=0
  t.last=1
  t.excess=false
  t.cst=0.0

proc `$`*(t:Truck):string=
  ## Gets the representation of the truck into a string.
  var st:string
  st="TRUCK\n" & "Route: " & $t.route & "\nLeft Capacity: " & $t.leftCapacity & "\nCost Truck: " & $t.cst
  return st
