#!/usr/bin/python
# -*- coding: UTF-8 -*-

"""
.. module:: CountWords

CountWords
*************

:Description: CountWords

    Generates a list with the counts and the words in the 'text' field of the documents in an index

:Authors: bejar
    

:Version: 

:Created on: 04/07/2017 11:58 

"""

from __future__ import print_function
from elasticsearch import Elasticsearch
from elasticsearch.helpers import scan
from elasticsearch.exceptions import NotFoundError

import argparse
import re

# Src: https://gist.github.com/sebleier/554280
ENGLISH_STOPWORDS = ["i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now"]

def isURL(word):
    return bool(re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\), ]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', word))
    #if(url.trim() is "" or url.trim() == ""):
    #    return False
    #return True

def isBadWord(word):
    if(isURL(word)):
        return True

    if(word in ["http", "www", "com"]):
        return True

    return (not word.isalpha())


__author__ = 'bejarAndLaura'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--index', default=None, required=True, help='Index to search')
    parser.add_argument('--alpha', action='store_true', default=False, help='Sort words alphabetically')
    args = parser.parse_args()

    index = args.index

    try:
        client = Elasticsearch()
        voc = {}
        sc = scan(client, index=index, doc_type='document', query={"query" : {"match_all": {}}})
        for s in sc:
            tv = client.termvectors(index=index, doc_type='document', id=s['_id'], fields=['text'])
            if 'text' in tv['term_vectors']:
                for t in tv['term_vectors']['text']['terms']:
                    if t in voc:
                        voc[t] += tv['term_vectors']['text']['terms'][t]['term_freq']
                    else:
                        voc[t] = tv['term_vectors']['text']['terms'][t]['term_freq']
        lpal = []

        for v in voc:
            lpal.append((v.encode("utf8", "ignore"), voc[v]))
        x = 1
        totalSum = 0
        print("i,counter,word")
        for pal, cnt in sorted(lpal, key=lambda x: x[1], reverse=True):
            
            #if(not isBadWord(pal) and (pal not in ENGLISH_STOPWORDS)):
            if(not isBadWord(pal)): # and (pal not in ENGLISH_STOPWORDS)):
                print('%d, %d, %s' % (x, cnt, pal))
                x = x + 1
                totalSum = totalSum + cnt
        print('%s Words' % totalSum)
    except NotFoundError:
        print('Index %s does not exists' % index)