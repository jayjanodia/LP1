#!/usr/bin/env python
# coding: utf-8

# # Importing the Libraries

# In[1]:


import pandas as pd
import numpy as np


# # Importing the dataset

# In[2]:


dataset = pd.read_csv('diabetes.csv')
print('dataset size: ', dataset.shape)
dataset.head(5)


# # Missing data <br> 
# Check for missing data

# In[3]:


print(dataset.isnull().any())


# In[4]:


dataset.describe()


# In[5]:


x = dataset.iloc[:, :-1].values
y = dataset.iloc[:, -1].values
print('x size: ',x.shape, 'data type of x: ', type(x))
print('y size: ',y.shape, 'data type of y: ', type(y))


# # Splitting the dataset into Training and Test set

# In[6]:


from sklearn.model_selection import train_test_split
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.33, random_state = 0)


# # Feature Scaling<br>
# Normalizing data 

# In[7]:


#Feature Scaling in this case reduced the accuracy of SVM and Logistic Regression, but increased the accuracy of NB
#from sklearn.preprocessing import StandardScaler
#sc = StandardScaler()
#x_train = sc.fit_transform(x_train)
#x_test = sc.transform(x_test)
#pd.DataFrame(x_test).head()


# # Applying various classification algorithms to predict result

# # Logistic Regression

# In[8]:


from sklearn.linear_model import LogisticRegression
lr = LogisticRegression(random_state = 0)
lr.fit(x_train, y_train)
y_pred_lr = lr.predict(x_test)


# # Naive-Bayes Classification

# In[9]:


from sklearn.naive_bayes import GaussianNB
gnb = GaussianNB()
gnb.fit(x_train, y_train)
y_pred_nb = gnb.predict(x_test)


# # Support Vector Machine Classification

# In[10]:


from sklearn.svm import SVC
classifier = SVC(kernel = 'linear', random_state=0)
classifier.fit(x_train, y_train)
y_pred_svm = classifier.predict(x_test)


# # Confusion Matrices and Accuracy of each classification algorithm

# In[11]:


from sklearn.metrics import confusion_matrix, accuracy_score, f1_score
cm_lr = confusion_matrix(y_test, y_pred_lr)
print('Confusion matrix of Logistic regression: ', cm_lr, sep = "\n")
cm_nb = confusion_matrix(y_test, y_pred_nb)
print('Confusion matrix of Naive Bayes: ', cm_nb, sep = "\n")
cm_svm = confusion_matrix(y_test, y_pred_svm)
print('Confusion matrix of Support Vector Machine: ', cm_svm, sep = "\n")


# In[12]:


accuracy_lr = accuracy_score(y_test, y_pred_lr)
fscore_lr = f1_score(y_test, y_pred_lr)
print('Logistic Regression\nAccuracy: ', accuracy_lr, '\nF-score', fscore_lr)
accuracy_nb = accuracy_score(y_test, y_pred_nb)
fscore_nb = f1_score(y_test, y_pred_nb)
print('Naive Bayes\nAccuracy: ', accuracy_nb, '\nF-score', fscore_nb)
accuracy_svm = accuracy_score(y_test, y_pred_svm)
fscore_svm = f1_score(y_test, y_pred_svm)
print('Support Vector Machine\nAccuracy: ', accuracy_svm, '\nF-score', fscore_svm)

