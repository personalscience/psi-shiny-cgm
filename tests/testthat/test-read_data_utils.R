# reading data utilities


active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


test_that("Notes file contains correct entries", {
  expect_equal(nrow(psiCGM:::glucose_for_food_df(foodname = "blueberries")), 1)
  expect_equal(nrow(psiCGM:::glucose_for_food_df(foodname = "avocado")), 2)

})

test_that("Max date is correct",{
  expect_equal(psiCGM:::max_date_for_user(user_id=1234),
               as_datetime(1624603560)) ## TODO must change to correct time zone.
               #lubridate::as_datetime("2021-06-25 13:46:00 UTC"))
})

test_that("Find correct glucose values after eating watermelon",{
  expect_equal(as.numeric(glucose_for_food_df(foodname = "watermelon")$Start[1]),
               1624714200) # equivalent to "2021-06-26 13:30:00 UTC"


})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
