# reading data utilities


active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


test_that("Notes file contains correct entries", {
  expect_equal(nrow(glucose_for_food_df(foodname = "blueberries")), 1)
  expect_equal(nrow(glucose_for_food_df(foodname = "avocado")), 2)

})

test_that("Max date is correct",{
  expect_equal(max_date_for_user(user_id=1234),
               as_datetime(1628618640))   # "2021-08-10 18:04:00 UTC"
})

test_that("Find correct glucose values after eating watermelon",{
  expect_equal(as.numeric(glucose_for_food_df(foodname = "watermelon")$Start[1]),
               1624714200) # equivalent to "2021-06-26 13:30:00 UTC"


})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
