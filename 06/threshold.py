from pymongo import MongoClient

conn = MongoClient()
db = conn.foo

def confidenceFromPair(pair):
    pairName = pair['_id']
    pairOccurrences = pair['value']
    
    items = pairName.split('+')
    item1 = items[0]

    firstTermOccurrences = db.single_counts.find_one({"_id":item1})['value']
    return(pairOccurrences/firstTermOccurrences)

def supportFromPair(pair, total):
    return((pair['value']/total))

def computeAllConfidenceAndSupport(db, total):
    allPairs = db.pair_counts.find()

    confidence = {}
    support = {}

    for pair in allPairs:
        pairName = pair['_id']

        confidence[pairName] = confidenceFromPair(pair)
        support[pairName] = supportFromPair(pair, total)

    return(confidence, support)