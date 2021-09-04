

# from project directory, type
# testthat::auto_test("./R", "./tests/testthat")
# Sys.setenv(R_CONFIG_ACTIVE = "localtest")

active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")

ft_df0 <- food_times_df(prefixLength = 0)

# 2 user_id and
ft_df1 <- food_times_df(prefixLength = 20, foodname = "blueberries")


mealnames_blu <-
  as_tibble_col(c("RSprague-7/31-blueberries",
                  "RSprague-8/2-blueberries",
                  "MSprague-6/5-blueberries"), column_name = "meal")



test_that("food_times_df holds correct mealnames",{
  expect_equal(ft_df1 %>% distinct(meal), mealnames_blu)
})


test_that("food_times_df holds correct start time",{
  expect_equal(ft_df1 %>%
                 group_by(meal) %>%
                 arrange(meal,t) %>%
                 ungroup() %>%
                 slice(2) %>% pull(value), 64)
})

test_that("food_times_df holds correct start time: prefixLength = 0 ",{
  expect_equal(ft_df0 %>%
                 group_by(meal) %>%
                 arrange(meal,t) %>%
                 ungroup() %>%
                 slice(2) %>% pull(value), 81)
})

test_that("food_times_df holds correct start time: prefixLength = 0 ",{
  expect_equal(ft_df0 %>%
                 group_by(meal) %>%
                 arrange(meal,t) %>%
                 ungroup() %>%
                 slice(2) %>% pull(value), 81)
})

test_that("normalize_value() works for prefixLength = 0 ",{
expect_equal(ft_df0 %>% normalize_value() %>% group_by(meal) %>% slice(5) %>% pull(value),
             c(-2,6,16))
})

test_that("normalize_value() works for prefixLength = 20 ",{
  expect_equal(ft_df1 %>% normalize_value() %>% group_by(meal) %>% slice(5) %>% pull(value),
               c(8,  -51,   3))
})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
