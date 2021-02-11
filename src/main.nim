import instance
import strutils
import sequtils
import graph
import ant
import antColony
import os

## The main module, given a the file name of an instance and
## a seed, constructs the Ant Colony and runs the algorithm.
when isMainModule:
  var
    params:seq[string]=commandLineParams()
    sds:seq[string]
    seeds:seq[int]
    numAnts,it:int
    g:Graph[60]
    best:Ant
    c:AntColony

  sds=split(strip(params[1],chars={'[',']',' '}),',')
  seeds=map(sds,parseInt)

  new(g)
  if params[0] == "data/A-n32-k5.vrp":
    numAnts=20
    it=3000
  elif params[0] == "data/A-n44-k6.vrp":
    numAnts=30
    it=7000
  elif params[0] == "data/A-n60-k9.vrp":
    numAnts=35
    it=9000

  for seed in seeds:
    (c,g)=readInstance(params[0],g,seed,numAnts)
    best=c.antSystem(g,it)
    echo $best
    g.resetGraph()
