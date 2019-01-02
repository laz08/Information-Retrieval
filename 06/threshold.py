from pymongo import MongoClient

conn = MongoClient()
db = conn.foo

# Standalone, deprecated
def confidence(pair1, pair2):
    key = pair1 + "+" + pair2
    return(db.pair_counts.find_one({"_id":key})['value']/db.single_counts.find_one({"_id":pair1})['value'])

def support(pair1, pair2, total):
    key = pair1 + "+" + pair2
    return(db.pair_counts.find_one({"_id":key})['value']/total)


# New, faster version
def confidenceFromPair(pair):
    pairName = pair['_id']
    pairOccurrences = pair['value']
    
    items = pairName.split('+')
    item1 = items[0]
    # item2 = items[1]

    firstTermOccurrences = db.single_counts.find_one({"_id":item1})['value']
    return(pairOccurrences/firstTermOccurrences)

def supportFromPair(pair, total):
    return((pair['value']/total) * 100)

def computeAllConfidenceAndSupport(db, total):
    allPairs = db.pair_counts.find()

    print(allPairs[1])

    confidence = {}
    support = {}

    for pair in allPairs:
        pairName = pair['_id']
        items = pairName.split('+')
        print("items {}".format(items))
        item1 = items[0]
        item2 = items[1]

        confidence[pairName] = confidenceFromPair(pair)
        support[pairName] = supportFromPair(pair, total)

    return(confidence, support)