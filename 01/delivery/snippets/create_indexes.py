import os
import shutil
import random


output_dir_og = './novels_subsets/'
numSubsets = 10

CREATE_INDEXES = False
RUN_INDEX_COMMAND = False

COUNT_WORDS = True

for i in range(numSubsets):
    num_subset = str(str(i + 1).zfill(2))
    index_name = "novels_ss_{}".format(num_subset)

    if(CREATE_INDEXES):
        path_ss = output_dir_og + num_subset
        command = "python2.7 ../IndexFiles.py --index {} --path  {}".format(index_name, path_ss)
        print("Creating index:")
        print(command)
        if(RUN_INDEX_COMMAND):
            os.system(command)
        print ('Finished creating indexes!')

    if(COUNT_WORDS):
        counterCsv = "out_ss_{}.csv".format(num_subset)
        command = "python2.7 ../CountWordsModified.py --index {} > {}".format(index_name, counterCsv)
        print(command)
        os.system(command)
        print ('Finished counting words per index!')


