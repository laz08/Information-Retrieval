import os
import shutil
import random

root_dir = './novels'
output_dir_og = './novels_subsets/'

totalNumFiles = 33
totalDirs = 10
totalNumArray = [2, 5, 7, 9, 13, 16, 19, 22, 27, 32]



for i in range(totalDirs):
    taken = 0
    totalNum = totalNumArray[i]
    output_dir = output_dir_og + str(str(i + 1).zfill(2))
    for root, dirs, files in os.walk(root_dir):
        for f in range(totalNum):
            chosen_one = random.choice(os.listdir(root))
            file_in_track = root
            file_to_copy = file_in_track + '/' + chosen_one
            if os.path.isfile(file_to_copy):
                taken = taken + 1
                shutil.copy(file_to_copy,output_dir)
                print (file_to_copy)
        

print("Finished shuffling!" )