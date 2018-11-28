import re
import urllib.request as UrlReq
from bs4 import BeautifulSoup as BS
import time

ENGLISH_STOPWORDS = ["i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself", "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself", "it", "its", "itself", "they", "them", "their", "theirs", "themselves", "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "having", "do", "does", "did", "doing", "a", "an", "the", "and", "but", "if", "or", "because", "as", "until", "while", "of", "at", "by", "for", "with", "about", "against", "between", "into", "through", "during", "before", "after", "above", "below", "to", "from", "up", "down", "in", "out", "on", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "s", "t", "can", "will", "just", "don", "should", "now"]

def getLyrics(artist,songTitle, treatment = True ): #when treatment works make it true
    """Given the artist and the song you will get the Lyrics of the song

    Args: Artist, Song Title

    Return: Song Lyric
    """
    notWanted = ['the','a','an','and','it','to','for','in','on','of','at','as', 'is', 'are'] #articles, prepositions -> words that are not usable in the analysis (Reconsider the words used)
    toChange = ['ive','im','id','its','youre','youd','youll','shes','hes','itll', 'wasnt', 'wouldnt'] #words that are actually two ; I don't know if i want to create a loop for this
    toChanged = ['i have', 'i am','i would','it is', 'you are','you would','you will','she is', 'he is', 'it will', 'was not', 'would not']
    artist = artist.lower()
    songTitle = songTitle.lower()
    if artist.startswith("the "):
        artist = artist[3:]
    artist = re.sub('[^A-Za-z0-9]+', "", artist)
    songTitle = re.sub('[^A-Za-z0-9]+', "", songTitle)

    url = "http://azlyrics.com/lyrics/"+artist+"/"+songTitle+".html"
    print("Url queried: {} ".format(url))
    try:
        content = UrlReq.urlopen(url).read()
        soup = BS(content, 'html.parser')
        lyrics = str(soup)
        lyrics = lyrics.split('<!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->')[1]
        lyrics = lyrics.split('<!-- MxM banner -->')[0]
        lyrics = lyrics.replace('<br>','').replace('</br>','').replace('</div>','').strip()
        if('<i>' in lyrics):
            lyrics = lyrics.replace('<i>','').replace('</i>','').strip()
        lyrics = lyrics.lower()
        lyrics = re.sub('[^a-z\n ]+', "", lyrics)
        
        if(treatment == True):
            for i, word in enumerate(toChange):
                lyrics = re.sub(r"\b%s\b"%word, toChanged[i], lyrics)
            for y in notWanted:
                lyrics = re.sub(r"\b%s\b"%y,'',lyrics)

        return lyrics
    except Exception as e:
        return "Exception occurred \n" + str(e)


def getBandSongs(artist):
    """Given the Artist you will get all the songs from all the albums and EPs

    Args: Artist

    Return: A List with all the songs
    """
    artist = artist.lower()
    if artist.startswith("the "):
        artist = artist[3:]

    artist = re.sub('[^A-Za-z0-9]+', "", artist)


    url = "http://www.azlyrics.com/"+artist[0]+"/"+artist+".html"
    print(url)
    try:
        content = UrlReq.urlopen(url).read()
        soup = BS(content, 'html.parser')
        songs = []
        songsBackbone = str(soup)
        songsBackbone = songsBackbone.split('songlist')[1]
        songsBackbone = songsBackbone.split('var res')[0]
        for i in range(len(songsBackbone))[1::]:
            try:
                passValue = songsBackbone.split("s:")[i]
                passValue = passValue.split('", h:')[0]
                songs.append(passValue.split('"')[1])
            except IndexError:
                break
        return songs 
    except Exception as e:
        return "Exception occurred \n" + str(e)


def getAlbumSongs(band, album):
    """ Given the Artist and album you will get all songs from the album given

    Args: Band name and Album

    Return: a List of Songs from the Album
    """
    album = album.lower()
    band = band.lower()
    if band.startswith("the "):
        band = band[3:]

    band = re.sub('[^A-Za-z0-9]+',"", band)

    url = "http://www.azlyrics.com/"+band[0]+"/"+band+".html"

    try:
        content = UrlReq.urlopen(url).read()
        soup = BS(content, 'html.parser')
        songs = []
        backbone = str(soup).lower()
        backbone = backbone.split('<div id="listalbum">')[1]
        backbone = backbone.split('album: <b>"%s"</b>'%album)[1]
        backbone = backbone.split('</div>')[1]
        backbone = backbone.split('<a id=')[0]
        backbone = backbone.split('target="_blank">')[1:]
        for i in backbone:
            song = i.split('</a>')[0]
            songs.append(song)
            
        return songs
        
    except Exception as e:
        return "Exception occurred \n" + str(e)


def getAllBandLyrics(band):
    listlyr = []
    counter = 0
    try:
        songs = getBandSongs(band)
        for song in songs:
            counter = counter + 1
            time.sleep(1)
            print(song)
            if(counter%5 == 0):
                time.sleep(3)

            lyrics = getLyrics(band,song)
            listlyr.append(lyrics)
    except Exception as e:
        print(str(e))
        
    return listlyr


        
def writeToFile(fileOut, songsLyrics, bandname):

    outStr = ""
    for song in songsLyrics:
        song = song.replace("\n", " ")
        lyrics = song.split(" ")
        finalWords = ""
        for word in lyrics:
            if (not word in ENGLISH_STOPWORDS):
                finalWords = finalWords + word + " "

        outStr = outStr + bandname + "; "+ finalWords + "; \n"
    f = open(fileOut, 'w+')
    f.write(str(outStr))
    f.close()
    print ("Finished writing lyrics")

#Debugger
if __name__ == "__main__":

    band = 'pulp'
    outputfilename = band + '_songs.txt'

    songLyrics = getAllBandLyrics(band)
    
    writeToFile(outputfilename, songLyrics, band)
 