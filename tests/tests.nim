import ../src/graph
import ../src/truck
import ../src/ant
import ../src/instance
import ../src/antColony
import tables
import unittest

when isMainModule:

  suite "Test Ant Colony":

    setup:
      var
        c:AntColony
        g:Graph[32]
        a:Ant
        i,j:int=1

      new(g)
      (c,g)=readInstance("Vrp-Set-A/A/A-n32-k5.vrp",g,2)
      a=initAnt(5,100.0,getTrucks(5,100),c.demands,g)
      a.cst=0
      a.trucks[1].route= @[27,8,14,18,20,32,22]
      a.trucks[1].cost(g)
      a.trucks[2].route= @[31,17,2,13]
      a.trucks[2].cost(g)
      a.trucks[3].route= @[28,25]
      a.trucks[3].cost(g)
      a.trucks[4].route= @[21,6,26,11,16,23,10,9,19,30]
      a.trucks[4].cost(g)
      a.trucks[5].route= @[15,29,12,5,24,4,3,7]
      a.trucks[5].cost(g)
      a.cst=a.cost(g)
      #echo s

    test "Construction Graph":
      check g.clients[i][j] == (0.0,0.0)
      i=7
      j=20
      check g.clients[i][j] == (44.2040722106006858,90.0)
      check g.clients[j][i] == (44.2040722106006858,90.0)
      i=10
      j=10
      check g.clients[i][j] == (0.0,0.0)
      i=31
      j=2
      check g.clients[i][j] == (19.4164878389476,90.66651721848525)
      check g.clients[j][i] == (19.4164878389476,90.66651721848525)

    test "Solution Cost":
      #check c.ants[0].cst == c.ants[0].cost(g)
      check a.cst == 787.8082774366646
