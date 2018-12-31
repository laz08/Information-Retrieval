from pymongo import MongoClient

conn = MongoClient()
db = conn.foo

total = None

def confidence(pair1, pair2):
    key = pair1 + "+" + pair2
    return(db.counts.find_one({"_id":key})['value']/db.counts.find_one({"_id":pair1})['value'])

def support(pair1, pair2):
    key = pair1 + "+" + pair2
    return(db.counts.find_one({"_id":key})['value']/total)

def countTotal():
    t = 0
    docs = db.counts.find()
    for doc in docs:
        if(doc['_id'].find('+') != -1):
            t = t + 1

    return(t)

total = countTotal()

print(confidence("soda","chocolate"))
print(support("soda","chocolate"))

#TODO: find all pairs that respect thresholds. !!!NOTE!!! pairs are counted twice, meaning that both (bread, soda) and (soda, bread) exist!