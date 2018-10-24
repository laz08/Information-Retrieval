import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

file = "./out.csv"
file = "./out3_without_stopword.csv"

def powerlaw_function(i, a, c):
    b = 1   # Fixed as postulated by Zipf himself
    return (c * ((i + b)**(-a)))

def main():
    df = pd.read_csv(file)
    df = df[:-1]  # Delete last row (contains total number of words)
    
    df = df.drop(df.columns[2], axis=1)
    df['i'] = df['i'].astype(int) # Convert it to int
    df['counter'] = df['counter'].astype(int) # Convert it to int

    ndf = df.copy(deep = True)

    if(True):
	    df.counter = np.log(df.counter)
	    df.i = np.log(df.i)
	    df.plot(x = 'i', y = 'counter')
	    plt.ylabel("Log (Num. of frequencies)")
	    plt.xlabel("Log (i)")
	    plt.title("Zipf's law log-log plot")
	    #plt.show()


    ##### CURVE FITTING #####
    xdata = ndf.i
    ydata = ndf.counter

    popt, pcov = curve_fit(powerlaw_function, xdata, ydata)

    freq = np.log(xdata)
    fit = np.log(powerlaw_function(xdata, *popt))
    
    plt.plot(freq, fit, 'r-', label='fit')
    plt.legend(loc='upper right')
    plt.show()

    print("OPT: {}".format(popt))



if __name__ == '__main__':
    main()