from pymongo import MongoClient
from bson.code import Code
from os import path
from codecs import encode, decode
from threshold import *

FILENAME = "groceries.csv"

def dropPreviousDatabase(db):
    db.corpus.drop()
    db.pair_counts.drop()
    db.single_counts.drop()
    print("Previous database dropped.")

def insertDatabaseData(db, filename):
    totalTransactions = 0
    with open(filename) as f:
      for line in f:
        totalTransactions += 1
        text = []    
        for word in line.strip().split(','):
          word = decode(word.strip(),'latin2','ignore')
          text.append(word)
        d = {}
        d['content'] = text
        db.corpus.insert(d)

    print("Finished inserting data.") 
    return(totalTransactions)

def mapReduceCounters(db):
    pairs_mapper = Code("""
    function() {
        for (var i = 0; i < this.content.length; i++) {
            if(this.content.length > 1){
              for (var j = i + 1; j < this.content.length; j++) {
                    k = this.content[i] + "+" + this.content[j];
                    k2 = this.content[j] + "+" + this.content[i];
                    emit(k, 1);
                    emit(k2, 1);
              }
            }
        }
    }
                  """)


    single_mapper = Code("""
    function() {
        for (var i = 0; i < this.content.length; i++) {
            emit(this.content[i], 1);
        }
    }
                  """)

    reducer = Code("""
    function(key,values) {
        var total = 0;
        for (var i = 0; i < values.length; i++) {
            total += values[i];
            }
            return total;
    }
                   """)  

    r = db.corpus.map_reduce(pairs_mapper, reducer, "pair_counts")
    r2 = db.corpus.map_reduce(single_mapper, reducer, "single_counts")

def printThresholdTable(confidence, support, rowsToPrint):
    
  tableRowsSupConf = [(0.01, 0.01),
                        (0.01, 0.25),
                        (0.01, 0.50),
                        (0.01, 0.75),
                        (0.05, 0.25),
                        (0.07, 0.25),
                        (0.20, 0.25),
                        (0.50, 0.25)]

  keys = confidence.keys()

  print("Nr. Association rules found: {}".format(len(keys)))
  rowCtr = 0
  for supMin, confMin in tableRowsSupConf:
    
    rowCtr += 1       # Counter to keep track of the rows to print.
    
    ctr = 0           # Nr. of elements that comply with the rules
    rowElements = []  # Elements that comply with the rules
    for pair in keys:
      if(confidence[pair] >= confMin and support[pair] >= supMin):
        ctr += 1
        if(rowCtr in rowsToPrint):
          rowElements.append(pair)
          

    rulesStr = "Row {}, Sup. {}, Conf. {}, Nr. Rules {}, elements: {}".format(rowCtr, supMin, confMin, ctr, rowElements)
    print(rulesStr)

def main():
    conn = MongoClient()
    db = conn.foo

    dropPreviousDatabase(db)
    totalTransactions = insertDatabaseData(db, FILENAME)
    mapReduceCounters(db)

    print("Total items: {}".format(totalTransactions))

    conf, supp = computeAllConfidenceAndSupport(db, totalTransactions)

    rowElementsToPrint = [4, 5, 6]
    printThresholdTable(conf, supp, rowElementsToPrint)



if __name__ == '__main__':
    main()