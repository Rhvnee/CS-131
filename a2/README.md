Automates the download and summary generation of CSV datasets given a dataset through URL. Shows min max mean standard for numerical values.

How to use:
Run(without quotation marks) ./datacollector1.sh
Input URL to dataset
Input index rows to print out summaries to

Look in summary.md to see the results.

Example:

$ ./datacollector1.sh

Enter the URL of the CSV or ZIP file: https://archive.ics.uci.edu/static/public/186/wine+quality.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 91353    0 91353    0     0   428k      0 --:--:-- --:--:-- --:--:--  426k
Archive:  wine+quality.zip
  inflating: winequality-red.csv     
  inflating: winequality-white.csv   
  inflating: winequality.names       
Index | Feature
------|--------
0 | fixed acidity
1 | volatile acidity
2 | citric acid
3 | residual sugar
4 | chlorides
5 | free sulfur dioxide
6 | total sulfur dioxide
7 | density
8 | pH
9 | sulphates
10 | alcohol
11 | quality
Enter comma-separated indices of numerical columns (e.g., 0,1,2): 1,2,3,5,6,7,10

Summary written to: summary.md

# Summary for winequality-red.csv

## Feature Index and Names
0. fixed acidity
1. volatile acidity
2. citric acid
3. residual sugar
4. chlorides
5. free sulfur dioxide
6. total sulfur dioxide
7. density
8. pH
9. sulphates
10. alcohol
11. quality

## Statistics (Numerical Features)
| Index | Feature | Min | Max | Mean | StdDev |
|-------|---------|-----|-----|------|--------|
| 1 | volatile acidity | 0.12 | 1.58 | 0.528 | 0.179 |
| 2 | citric acid | 0.00 | 1.00 | 0.271 | 0.195 |
| 3 | residual sugar | 0.90 | 15.50 | 2.539 | 1.409 |
| 5 | free sulfur dioxide | 1.00 | 72.00 | 15.875 | 10.457 |
| 6 | total sulfur dioxide | 6.00 | 289.00 | 46.468 | 32.885 |
| 7 | density | 0.99 | 1.00 | 0.997 | 0.002 |
| 10 | alcohol | 8.40 | 14.90 | 10.423 | 1.065 |
