Abstract. The goal of our project is to utilize factor models to explain returns and optimize the Sharpe
ratio to create a portfolio that outperforms the S&P 500. After rening our data we have a universe of
335 stock in which we can invest. We rebalance our portfolio quarterly and incorporate factor models
and Sharpe ratio optimization through cone programming to form the portfolio. 
The paper is organized as follows: Section 1 is a short introduction ot our paper, Section 2 gives a brief idea of
the data available and what kind of choices we made to reach the nal universe of stocks, Section 3
gives an idea of the general methodoloy used in the paper, Section 4 describes thre results that we have
reached, section 5 presents the signicance test we performed, Section 6 presents the resulsts of dierent
sensitivity analysis and Section 7 summarizes the project and gives suggestions for further research.


fear_and_greed.m and fg_matrix.m are used to compute the fear and greed indicator using the high, low and close values
final_factor_code takes up the complete data and creates factor models and uses them to predict the future returns 
conprog.m is a cvx based program that runs the optimization that produces the weights for each of the stock in the given universe.


Note: This was a course project for a course in Optimization modeling and was carried out in a team. Please open the Final report for more information. There are a bunch of aspects that need to be explored before such a strategy can actually be put to work and this project helped us realize how vast the gap is between theory and practice!
