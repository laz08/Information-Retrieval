#!/usr/bin/python

from collections import namedtuple
import time
import sys

class Edge:
    def __init__ (self, origin=None, dest=None, hashKey=None):
        self.origin = origin
        self.dest = dest
        self.hashKey = hashKey
        self.weight = 0 # write appropriate value

    def __repr__(self):
        return "edge: {0} {1} {2}".format(self.origin, self.dest, self.weight)
      
class Airport:
    def __init__ (self, iden=None, name=None):
        self.code = iden
        self.name = name
        self.routes = []
        self.routeHash = dict()
        self.outweight = 0   # write appropriate value

    def __repr__(self):
        return "{0}\t{2}\t{1}".format(self.code, self.name, self.pageIndex)

edgeList = [] # list of Edge
edgeHash = dict() # hash of edge to ease the match
airportList = [] # list of Airport
airportHash = dict() # hash key IATA code -> Airport

def readAirports(fd):
    print "Reading Airport file from {0}".format(fd)
    airportsTxt = open(fd, "r");
    cont = 0
    for line in airportsTxt.readlines():
        a = Airport()
        try:
            temp = line.split(',')
            if len(temp[4]) != 5 :
                raise Exception('not an IATA code')
            a.name=temp[1][1:-1] + ", " + temp[3][1:-1]
            a.code=temp[4][1:-1]
        except Exception as inst:
            pass
        else:
            cont += 1
            airportList.append(a)
            airportHash[a.code] = a
    airportsTxt.close()
    print "There were {0} Airports with IATA code".format(cont)


def readRoutes(fd):
    print "Reading Routes file from {0}".format(fd)
    routesTxt = open(fd, "r");
    cont = 0
    testCount = 0
    for line in routesTxt.readlines():
        e = Edge()
        testCount = testCount + 1
        try:
            temp = line.split(',')
            #if(testCount < 2):
            #    print("Word: {}, Length: {}".format(temp[2], len(temp[2])))
            if (len(temp[2]) != 3 or len(temp[4]) != 3) :
                raise Exception('One of the routes does not contain an IATA code')
            
            e.origin = temp[2]
            e.dest = temp[4]

            hashKey = e.origin + e.dest

            if(hashKey in edgeHash.keys()): 
            # If there already exists an edge from orig to dest
                #oldEdge = edgeHash[hashKey]
                #edgeList.remove(oldEdge) # TODO: Check this

                e = edgeHash[hashKey]
                e.weight = e.weight + 1

                # Reassign it and rewrite the obj. It is passed by value, not ref.
                edgeHash[hashKey] = e
                edgeList.append(e)


            else:
                # Not in edges list!
                e.hashKey = hashKey
                e.weight = 1

                # Add it
                edgeHash[hashKey] = e
                #edgeList.append(e)
                cont += 1

        except Exception as inst:
            pass
       
    routesTxt.close()
    for key, value in edgeHash.iteritems():
        edgeList.append(value)

    print "There were {0} routes with IATA code".format(cont)
    #print edgeHash
    print edgeList


def computePageRanks():
    print(1)
    # write your code

def outputPageRanks():
    print(1)
    # write your code

def main(argv=None):
    readAirports("airports.txt")
    readRoutes("routes.txt")
    if(False):
        time1 = time.time()
        iterations = computePageRanks()
        time2 = time.time()
        outputPageRanks()
        print "#Iterations:", iterations
        print "Time of computePageRanks():", time2-time1


if __name__ == "__main__":
    sys.exit(main())
