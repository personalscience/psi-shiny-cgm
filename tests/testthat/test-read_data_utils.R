# reading data utilities


active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


test_that("Notes file contains correct entries", {
  expect_equal(nrow(psiCGM:::glucose_for_food_df(foodname = "blueberries")), 1)
  expect_equal(nrow(psiCGM:::glucose_for_food_df(foodname = "avocado")), 2)

})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
