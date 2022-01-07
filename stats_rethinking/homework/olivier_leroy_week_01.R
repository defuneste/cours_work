# Date january 2022
# Olivier Leroy
# Homework week 1 Statistical Rethinking
# https://github.com/rmcelreath/stat_rethinking_2022/blob/main/homework/week01.pdf

# utility stuff

plot_my_posterior <- function(my_posterior, x_value = p_grid)
{
  plot(x = xaxis
     , y =  my_posterior
     , type = "l"
     , xlab = "Probability of water"
     , ylab = "Posterior probability" )
}

# 1

p_grid <- seq(from = 0, to = 1, length.out = 1000)
prior <- rep(1, 1000)
prob_data <- dbinom(4, 15, prob = p_grid) # 4 W + 11 L
posterior <- prob_data * prior
posterior <- posterior / sum(posterior)

plot_my_posterior(posterior)

#2

prior_2 <- ifelse(p_grid < 0.5, 0, 1) # O below p = 0.5
prob_data <- dbinom(4, 6, prob = p_grid)
posterior <- prob_data * prior_2
posterior <- posterior / sum(posterior)

plot_my_posterior(posterior)
