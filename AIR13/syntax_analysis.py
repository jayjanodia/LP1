# -*- coding: utf-8 -*-
"""
Created on Mon Oct 21 16:04:02 2019

@author: jayja
"""
#TOKENIZATION
from nltk.tokenize import word_tokenize, sent_tokenize
#from nltk.tokenize import PunktSentenceTokenizer
sentence = "Hello Mr. Human, how are you today? The weather is great and python is awesome. I am running like the wind"
sentence_token = sent_tokenize(sentence)
word_token = word_tokenize(sentence)

#STOP WORDS
from nltk.corpus import stopwords
stop_words = set(stopwords.words('english'))
print(stop_words)

filtered_sentence = []

for w in word_token:
        if w not in stop_words:
            filtered_sentence.append(w)
        
#filtered_sentence = [w for w in word_token if not w in stop_words]
print(filtered_sentence)

#STEMMING
from nltk.stem import PorterStemmer
ps = PorterStemmer() 
stemmed_sentence = []
for w in filtered_sentence:
    stemmed_words = (ps.stem(w))
    stemmed_sentence.append(stemmed_words)
    

#LEMMATIZATION
from nltk.stem import WordNetLemmatizer
lemmatizer = WordNetLemmatizer()

lemmatized_sentence = []
for w in filtered_sentence:
    lemmatized_words = lemmatizer.lemmatize(w)
    lemmatized_sentence.append(lemmatized_words)
    

#PARTS OF SPEECH
from nltk import pos_tag    
pos_word = pos_tag(filtered_sentence)
    
#word_token = []

#for w in sentence_token:
#    word = word_tokenize(w)
 #   word_token.append(word)
    
#PARTS OF SPEECH
    
#from nltk import pos_tag
#pos_list = []
#for w in word_token:
#    pos_word = pos_tag(w)
#    pos_list.append(pos_word)
    
#print(pos_list)


#from nltk.parse.corenlp import CoreNLPParser
#parser = CoreNLPParser()
#next(parser.raw_parse("What is the longest river in the world?"))