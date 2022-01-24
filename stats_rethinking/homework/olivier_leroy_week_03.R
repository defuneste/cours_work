# Date january 2022
# Olivier Leroy
# Homework week 3 Statistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week03.pdf


# Loading data =================================================================


library(rethinking)
data(foxes)
str(foxes)

                                        # 1

# Influence of A on F
# step 1 identify all path from treatment A to outcome F
# A ---> F
# step 2 identify backdoor
# None
# step 3 closing backdoor
# not needed
# Effect of increasing area of a territory on the ammount of food ?
# I assume increasing the area will increase the amount of food available.
# The rate of increase will depend of the spatial distribution of foods,
# insight we do not have.
# we can atleast check the data

plot(foxes$area, foxes$avgfood,
     xlab = "Area", ylab = "Avg Food",
     col = 2)

                                        # 2
