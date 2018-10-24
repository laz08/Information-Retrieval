"""
:Authors:
    Laura and Alex

:Version: 

:Date:  10/10/2018
"""
from __future__ import print_function, division
from elasticsearch import Elasticsearch
from elasticsearch.exceptions import NotFoundError
from elasticsearch.client import CatClient
from elasticsearch_dsl import Search
from elasticsearch_dsl.query import Q
import math
import operator
from TFIDFViewer import toTFIDF

import argparse

import numpy as np

__author__ = 'LauraAlex'

def printMostRelevant(response):
    for r in response:  # only returns a specific number of results
        print('ID= %s SCORE=%s' % (r.meta.id,  r.meta.score))
        print('PATH= %s' % r.path)
        print('TEXT: %s' % r.text[:50])
        print('-----------------------------------------------------------------')


def addToGlobalDic(globalDic, r):
    r = dict(r)
    for term in r:
        if(term in globalDic.keys()):
            globalDic[term] =  globalDic[term] + r[term]
        else:
            globalDic[term] = r[term]

    return globalDic

def queryToDictionary(query):
    queryDic = dict()
    for el in query:
        elVec = el.split('^')
        term = elVec[0]
        w = 1   # Default

        if(len(elVec) > 1):     # Exists weighting in the query
            w = elVec[1]
        
        queryDic[term] = float(w)
    return queryDic


def computeNewQuery(query, response_tfidf, alpha, beta, R, k):

    globalDic = dict()
    for r in response_tfidf:
        globalDic = addToGlobalDic(globalDic, r)

    sorted_dic = globalDic
    #sorted_dic = sorted(globalDic.items(), key=operator.itemgetter(1), reverse=True)
    #print(sorted_dic)
    #mostImportant = sorted_dic[:R]
   
    queryAsDic = queryToDictionary(query)
    newQuery = dict()

    # A VERY LONG LIST
    if(False):
        print("###################################")
        print(sorted_dic)
        print("**********************************")

    ## ADDING WORDS FROM queryAsDic
    for term in queryAsDic.keys():
        newQuery[term] = (alpha * queryAsDic[term]) 

    for term in sorted_dic.keys():
        newQuery[term] = beta * sorted_dic[term]/k

    if(False):
        print("###################################")
        print(newQuery)
        print("**********************************")

    sortedNewQuery = sorted(newQuery.items(), key=operator.itemgetter(1), reverse=True)
    sortedNewQuery = sortedNewQuery[:R]
    if(False):
        print("###################################")
        print(sortedNewQuery)
        print("************************************")
    return sortedNewQuery


def convertQueryToString(newQueryAsDic):
    newQuery = []
    for el in newQueryAsDic:
        term = str(el[0])
        weight = round(el[1], 2)
        newQuery.append("%s^%f" % (term, weight))
    #print(newQuery)
    return newQuery


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--index', default=None, required=True, help='Index to search')
    parser.add_argument('--query', default=None, nargs=argparse.REMAINDER, help='List of words to search')
   
    args = parser.parse_args()

    index = args.index
    query = args.query      # ask for a set of words to use as query
    
    ######################################
    k = 5
    nrounds = 10
    ######################################
    alpha = 1
    beta = 1  
    R = 3
    ######################################

    try:
        client = Elasticsearch()
        s = Search(using=client, index=index)

        if query is not None:

            print("Query: {}".format(query))
            #For a number of times (nrounds):
            for i in range(nrounds):

                q = Q('query_string',query=query[0])
                for i in range(1, len(query)):
                    q &= Q('query_string',query=query[i])

                s = s[0:k].query(q)
                # Obtain the k more relevant documents
                response = s[0:k].execute()
                print("Response: {}".format(response))
                response_tfidf = []
                for r in response:
                    tfidf = toTFIDF(client, index, r.meta.id)
                    response_tfidf.append(tfidf)
            
                newQueryAsDic = computeNewQuery(query, response_tfidf, alpha, beta, R, k)
                query = convertQueryToString(newQueryAsDic)
                print("Query: {}".format(query))
            
            ### End of loop of nrounds.
            printMostRelevant(response)

        else:
            print('No query parameters passed')

        print ('%d Documents'% response.hits.total)
        


    except NotFoundError:
        print('Index %s does not exists' % index)



