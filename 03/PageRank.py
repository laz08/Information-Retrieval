#!/usr/bin/python

from collections import namedtuple
import argparse
import time
import sys
import cProfile
class Edge:
    def __init__ (self, origin=None, dest=None):
        self.origin = origin
        self.dest = dest
        self.weight = 1

    def __repr__(self):
        return "edge: {0} {1} {2}".format(self.origin, self.dest, self.weight)
      
class Airport:
    def __init__ (self, iden=None, name=None):
        self.code = iden
        self.name = name
        self.routes = []
        self.routeHash = dict()
        self.outweight = 0   # write appropriate value
        self.pageIndex = 0

    def __repr__(self):
        return "Code: {0}\t PageIdx:{2}\t Name: {1}".format(self.code, self.name, self.pageIndex)

edgeHash = dict() # hash of edge to ease the match
airportList = [] # list of Airport
airportHash = dict() # hash key IATA code -> Airport
#P = []       # Initial PageRank vector

def readAirports(fd):
    print("Reading Airport file from {0}".format(fd))
    airportsTxt = open(fd, "r", encoding="utf8")
    cont = 0
    noncount = 0
    for line in airportsTxt.readlines():
        a = Airport()
        try:
            temp = line.split(',')
            if len(temp[4]) != 5 :
                raise Exception('not an IATA code')
            a.name=temp[1][1:-1] + ", " + temp[3][1:-1]
            a.code=temp[4][1:-1]
        except Exception as inst:
            noncount +=1
            pass
        else:
            # see comment below about this check
            if a.code in airportHash.keys():
                """
                print(a.code)
                    BFT
                    ZYA
                """
                continue
            cont += 1
            airportList.append(a)
            airportHash[a.code] = a
    airportsTxt.close()
    print("There were {0} Airports with IATA code".format(cont))
    print("There were {0} Airports records with non an IATA code".format(noncount))
    print("Length of airportHash  {0} ".format(len(airportHash)))
    print("Length of airportList  {0} ".format(len(airportList)))
    """
    from the statistics below we can see that that 2 records appear twice
    after adding the condition to exclude IATA we find those 2 records that appear twice.
    There were 5740 Airports with IATA code
    There were 1923 Airports records with non an IATA code
    Length of airportHash  5738
    Length of airportList  5740
    """

def readRoutes(fd):
    print("Reading Routes file from {0}".format(fd))
    routesTxt = open(fd, "r");
    counter = 0
    for line in routesTxt.readlines():
        temp = line.split(',')
        if len(temp) < 4:
            continue
        e = Edge()
        e.origin = temp[2]
        e.dest = temp[4]
        # Check we have these airports
        if((airportHash.get(e.origin) is None) 
            or (airportHash.get(e.dest) is None)):
            continue

        airportHash[e.origin].outweight += 1
            
        hashKey = e.origin + e.dest
        existingEdge = edgeHash.get(hashKey)
        if(existingEdge is not None): 
            existingEdge.weight += 1
        else:
            edgeHash[hashKey] = e
            counter += 1

            # Add route to airport of destination
            airportHash[e.dest].routes.append(e)

       
    routesTxt.close()
    print("There were {0} routes with IATA code".format(counter))


def computeSumDestVert(P, n, i):
    overallSum = 0

    # Iterate through routes that have i as destination
    for e in airportList[i].routes:
        j_code = e.origin
        w_j_i  = e.weight
        airport_j = airportHash.get(j_code)
        j = airportList.index(airport_j)
        #print("j_code = {0}, wji = {1}, airport_j = {2} , j= {3}, airport_j.outweight = {4}".format(j_code, w_j_i, airport_j, j, airport_j.outweight))
        overallSum += P[j] * w_j_i / airport_j.outweight
        #print("overallSum = {0}".format(overallSum))


    return overallSum

def computePageRanks():

    n = len(airportList)
    L = 0.85        # Damping factor
    P = [1/n] * n

    aOutdegreeZero = filter(lambda a: a.outweight == 0, airportList)
    aOutdegreeZero = len(list(aOutdegreeZero))
    print("Outdegree zero: {}".format(aOutdegreeZero))
    pageRankNoOutDegrees = (L * aOutdegreeZero/ n)

    p_no_outdegree = 1/n
    it = 1
    totalIt = 10
    while(it <= totalIt):  # TODO: Change this
        print("Progress iterations: {0}/{1}".format(it, totalIt))
        print("{}{}{}".format('#'*it, ' ' * (totalIt - it), "||"))
        Q = [0] * n
        for i in range(0, n):
            Q[i] = (L * computeSumDestVert(P, n, i)) + ((1 - L)/n) + (pageRankNoOutDegrees * p_no_outdegree)

        diff = 0
        #print("P = {}".format(P[:10]))
        #print("Q = {}".format(Q[:10]))
        for i in range(0, n):
            diff = diff + (Q[i] - P[i])**2
        print("Converge factor - sum((Q[i] - P[i])**2): {}".format(diff))
        
        p_no_outdegree = (pageRankNoOutDegrees * p_no_outdegree) + ((1 - L)/n)
        P = Q
        it += 1


    
    # Assign pageranks
    for i in range(0, n):
        airportList[i].pageIndex = P[i]

    return it

def outputPageRanks():
    totalPR = 0
    for a in airportList:
        print(a)
        totalPR += a.pageIndex
    print("total PR = {0}".format(totalPR))


def normalizeWeights():
    for e in list(edgeHash.values()):
        a = airportHash[e.origin]
        e.weight = e.weight / a.outweight

def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('--test', default=False, action='store_true', help='run test case')
    parser.add_argument('--print', default=False, action='store_true', help='Print pageRank results')

    args = parser.parse_args()

    time1 = time.time()
    if args.test:
        readAirports("airports_test.txt")
        readRoutes("routes_test.txt")
    else:
        readAirports("airports.txt")
        readRoutes("routes.txt")

    time2 = time.time()
    print("Time of reading airports and routes:", time2-time1)

    #normalizeWeights()
    
    print("Computing pageRanks")
    time1 = time.time()
    iterations = computePageRanks()
    time2 = time.time()
    if args.print:
        outputPageRanks()
    
    print("#Iterations:", iterations)
    print("Time of computePageRanks():", time2-time1)


if __name__ == "__main__":
    #cProfile.run("main()")
    sys.exit(main())
