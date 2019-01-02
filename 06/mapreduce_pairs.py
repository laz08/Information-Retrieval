from pymongo import MongoClient
from bson.code import Code
from os import path
from codecs import encode, decode
from threshold import *

FILENAME = "groceries.csv"

def dropPreviousDatabase(db):
    db.corpus.drop()
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


def main():
    conn = MongoClient()
    db = conn.foo

    dropPreviousDatabase(db)
    totalTransactions = insertDatabaseData(db, FILENAME)
    mapReduceCounters(db)

    print("Total items: {}".format(totalTransactions))

    print("Confidence (soda, chocolate): {}".format(confidence("soda","chocolate")))
    print("Support (soda, chocolate): {}".format(support("soda","chocolate", totalTransactions)))

    conf, supp = computeAllConfidenceAndSupport(db, totalTransactions)
    print(conf)

if __name__ == '__main__':
    main()