# Date january 2022
# Olivier Leroy
# Homework week 1 Statistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week01.pdf

# utility stuff

plot_my_posterior <- function(my_posterior, x_value = p_grid)
{
  plot(x = x_value
     , y =  my_posterior
     , type = "l"
     , xlab = "Proportion of water"
     , ylab = "Posterior probability" )
}

# 1

W <- 4
W_L <- 4 + 11

p_grid <- seq(from = 0, to = 1, length.out = 1000)
prior <- rep(1, 1000)
prob_data <- dbinom(W, W_L, prob = p_grid) # 4 W + 11 L
posterior <- prob_data * prior
posterior <- posterior / sum(posterior)

plot_my_posterior(posterior)

#2
W <- 4
W_L <- 4 + 2

prior_2 <- ifelse(p_grid < 0.5, 0, 1) # O below p = 0.5
prob_data <- dbinom(W, W_L, prob = p_grid)
posterior <- prob_data * prior_2
posterior <- posterior / sum(posterior)

plot_my_posterior(posterior)

# 3

library("rethinking")

samples <- sample(p_grid, prob = posterior, size = 1e4, replace = TRUE )

eighty_nine_quantile <- quantile(samples, c( 0.055, 0.945))
eighty_nine_HDPI <- rethinking::HPDI(samples, c(0.89))

plot_my_posterior(posterior)
abline(v = eighty_nine_quantile, col = "red")
abline(v = eighty_nine_HDPI, col = "blue")

diff(eighty_nine_quantile) > diff(eighty_nine_HDPI)

# The Percentil Interval take more values on the right side of the distribution.
# It is also wider by definition: HDPI target the narrowest interval to include the most probable paramater values.
# If I just had the information from intervals, I could have assume a symetrical shape for the distribution
# and fail to remember that we can't have less than 50% of water.
