DSS Capstone Project  typeRight : prediction app
========================================================
author: Karthik Arumugham
date: August 01, 2016
-
![alt text](typeRight.jpg)

Data Cleaning
========================================================

- I used the *English* files from the **HC Corpora** dataset, which contains ~4M lines of text from news articles, Twitter, and blogs
- ***Regular Expression*** was used to clean and tokenize the raw text,
    - replaced `_PHONE_`, `_URL_`, `_EMAIL_`, `_DATE_`, `_TIME_`, `_NUM_`, & `_VULGAR_`
    - removed repeated and other punctuation marks and spaces
- ***Preserved sentence structure*** by retaining a few characters,   
    - apostrophes like `I'm`, `America's`, etc
    - punctuation marks like `,` and `-`
    - upper case letters like `I`,`Obama`, etc
- Tried sentence boundary tags. But later dropped it due to performance issues.    


Data Analysis & Structure
========================================================

- Explored with `RWeka` and `ngram` packages to tokenize data and build ngrams. Also ***built from scratch*** a code for ngrams. However, `ngram` package offered the highest performance
- Used ***parallel processing*** with `foreach` and `snow` packages by splitting corpus into 6000 fragments
- ***Stored and Indexed*** the 5-gram table using `data.table` package for *fast retrieval due to indexing and binary search*
- Randomly sampled ~1% of all three of the blogs, news, and twitter dataset to test the code. Built the final algorithm using 100% of the corpus
- The final ngram table is pruned to limit to 93MB when loaded in memory to increase performance when hosted on shinyapps.io


Prediction Algorithm
========================================================
- The model cleans/tokenizes the input first, and are fed through two algorithms
    + **Autocomplete**: take the last group of letters from the input, look up words in the `unigram` table that start with the letters, and return the result with the highest frequency
    + **Prediction**: look up the last 4 words in `fivegram` table, last 4 words in the `fourgram`, etc in order, sorted by probability.
    + Tried **Maximum Likelihood Estimation (MLE)** on all four N-gram tables by setting weights by trail, but resulted only in marginal improvements in accuracy on all occasions.
<span style = "font-size: medium;">$$p =
0.4\frac{Count(w_{i−4},w_{i−3},w_{i−2},w_{i-1},w_i)}{Count(w_{i−3},w_{i−3},w_{i-2},,w_{i-1},w_i)} +
0.3\frac{Count(w_{i−3},w_{i−2},w_{i−1},w_i)}{Count(w_{i−2},w_{i−1},w_i)} + 0.2\frac{Count(w_{i−2},w_{i−1},w_i)}{Count(w_{i−1},w_i)} + 0.1\frac{Count(w_{i−1},w_i)}{Count(w_i)}$$</span>
- Got a overall top-3 score of 17.52 % in the [benchmark](https://github.com/jan-san/dsci-benchmark/) test for 28,464 predictions and 50% for the quiz questions.

Shinyapp & Instructions
========================================================
- The final product can be found [here](https://www.karthiaru.com/shiny/word-prediction/)
- The following are the features of the app
    - predicted autocomplete words will appear as you type
    - predicted next word will appear when you provide a space
    - click the words to add to your text
    - view optional *Tokenized Text*

