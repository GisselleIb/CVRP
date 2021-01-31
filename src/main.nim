import instance
import graph
import ant
import truck
import antColony
import tables

when isMainModule:
  var
    g:Graph[32]
    cost:float
    last:int
    c:AntColony
    best:Ant

  new(g)
  (c,g)=readInstance("Vrp-Set-A/A/A-n32-k5.vrp",g,5 )
  best=c.antSystem(g,2000)
  #echo $g
  echo $best

  for t in best.trucks.values:
    last=1
    for i in t.route:
      cost=cost+g.clients[last][i].distance
      last=i

    cost=cost+g.clients[last][1].distance



  echo cost
  echo best.cost(g)
