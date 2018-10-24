from elasticsearch import Elasticsearch

numSubsets = 10
es = Elasticsearch()

for i in range(numSubsets):
    num_subset = str(str(i + 1).zfill(2))
    index_name = "novels_ss_{}".format(num_subset)
    es.indices.delete(index=index_name, ignore=[400, 404])

