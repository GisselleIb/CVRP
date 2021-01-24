import instance
import graph
import ant
import antColony
import tables

when isMainModule:
  var
    g:Graph[32]
    c:AntColony
    best:Ant

  new(g)
  (c,g)=readInstance("Vrp-Set-A/A/A-n32-k5.vrp",g,5)
  best=c.antSystem(g,50)
  #echo $g
  echo $best
  #  for t in a.trucks.values:
  #    echo t.route
