import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit
import os


numSubsets = 10

def compute_d_N(df):
    lastRow = df.tail(1)['i']
    lastRow = str(lastRow).split(" ")
    totalNumWords = int(lastRow[4])
    #print(lastRow)
    #print(totalNumWords)

    df = df[:-1]  # Delete last row (contains total number of words)
    df = df.drop(df.columns[2], axis=1)

    totalDiffWords = len(df)
    return totalDiffWords, totalNumWords

def heaps_law(N, k, Beta):
    # d = k * N ** Beta
    return (k * (N ** Beta))

def main():

    d = []
    N = []
    for i in range(numSubsets):
        num_subset = (str(i + 1).zfill(2))
        counterCsv = "../files/out_ss_{}.csv".format(num_subset)
        ds, Ns = compute_d_N(pd.read_csv(counterCsv))
        d.append(ds)
        N.append(Ns)

    ##### CURVE FITTING #####
    xdata = N
    ydata = d
    print(xdata)
    print(ydata)

    popt, pcov = curve_fit(heaps_law, xdata, ydata)

    xdata = np.log(xdata)
    fit = np.log(heaps_law(xdata, *popt))

    
    print("OPT: {}".format(popt))

    ##### LOG. PLOT #######
    plt.plot(xdata, fit, 'r-', label='')
    plt.legend(loc='lower right')
    plt.ylabel("Num. of diff words (d)")
    plt.xlabel("Total num. of words (N)")
    plt.title("Heaps law log-log plot")

    plt.show()

    ##### NON-LOG. PLOT #######
    fit2 = (heaps_law(xdata, *popt))

    plt.plot(N, fit2, 'r-', label='')
    plt.legend(loc='lower right')
    plt.ylabel("Num. of diff words (d)")
    plt.xlabel("Total num. of words (N)")
    plt.title("Heaps law plot")

    plt.show()


if __name__ == '__main__':
    main()