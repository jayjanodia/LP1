#!/usr/bin/env python
# coding: utf-8

# # Imports
# Import pandas for data analysis of your data set <br>
# Import matplotlib to plot histogram and boxplot or any other graphs <br>
# Import seaborn for plotting graphs. It is an alternative to matplotlib meant for better visualization<br>
# Import numpy to perform advanced mathematical functions efficiently 

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


# # Importing the dataset

# In[2]:


dataset = pd.read_csv("IRIS.csv")
dataset


# # Check number of features 

# In[3]:


dataset.info()


# # Summary Statistics <br>
# Find the min, max, standard deviation, percentile, mean of all the features in the dataset

# In[4]:


dataset.describe()


# # Unique value count

# In[5]:


dataset.sepal_length.value_counts()


# # Individual summary statistics

# In[6]:


print('Sepal Length summary: ', dataset.sepal_length.describe(), '\n', sep = '\n')
print('\nSepal Width summary: ', dataset.sepal_width.describe(), '\n', sep = '\n')
print('\nPetal Length summary: ', dataset.petal_length.describe(), '\n', sep = '\n')
print('\nPetal Width summary: ', dataset.petal_width.describe(), sep = '\n')


# # Manual calculation of statistics

# In[7]:


min1 = dataset.sepal_length.min()
max1 = dataset.sepal_length.max()
sum1 = dataset.sepal_length.sum()
count1 = dataset.sepal_length.count()
mean = sum1/count1
mean1 = dataset.sepal_length.mean()
median1 = dataset.sepal_length.median()
mode1 = dataset.mode(axis = 0, numeric_only = False)
range1 = max1 = min1
standard_deviation = dataset.loc[:, 'sepal_length'].std()
variance = dataset.var()
percentile = dataset.sepal_length.quantile(0.25) # 25th percentile

print("Min: ", min1)
print("Max: ", max1)
print("Mean manual: ", mean)
print("Mean API: ", mean1)
print("Median API: ", median1)
print("Mode API: ", mode1)
print("Range: ", range1)
print("Standard Deviation API: ", standard_deviation)
print("Variance API: ", variance, sep = "\n")
print("Percentile API: ", percentile)


# # Data Visualization <br>
# Histogram plotting

# In[8]:


dataset.hist(xlabelsize= 10, ylabelsize= 10, figsize = (10,10))


# # Box Plot visualization <br>
# 1. Visual representation of numerical data through their quartiles. <br>
# 2. Used to detect outliers in dataset<br>
# 3. Summarizes data using 25th, 50th, and 75th percentile

# In[9]:


data = np.array(dataset)
for i in range(1, 4):
    plt.boxplot(np.array(data[:, i], dtype='float'))
    plt.show()


# In[10]:


sns.boxplot(data=dataset.ix[:, 1:5])


# In[11]:


sns.boxplot(x=dataset['species'], y=dataset['sepal_length'])

