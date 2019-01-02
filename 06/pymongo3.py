from pymongo import MongoClient
from bson.code import Code
from os import path
from codecs import encode, decode

FILENAME = "groceries.csv"

def dropPreviousDatabase(db):
    db.corpus.drop()

def insertDatabaseData(db, filename):
    with open(filename) as f:
      for line in f:
        text = []    
        for word in line.strip().split(','):
          word = decode(word.strip(),'latin2','ignore')
          text.append(word)
        d = {}
        d['content'] = text
        db.corpus.insert(d)


def mapReduceCounters(db):
    pairs_mapper = Code("""
    function() {
        for (var i = 0; i < this.content.length; i++) {
            emit(this.content[i],1);
            for (var j = i + 1; j < this.content.length; j++) {
                    k = this.content[i] + "," + this.content[j];
                    k2 = this.content[j] + "," + this.content[i];
                    emit(k, 1);
                    emit(k2, 1);
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
    insertDatabaseData(db, FILENAME)
    mapReduceCounters(db)

if __name__ == '__main__':
    main()