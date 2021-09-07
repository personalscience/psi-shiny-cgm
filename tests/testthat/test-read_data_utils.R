# reading data utilities


active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


test_that("Notes records in test database are correct", {
  expect_equal(nrow(notes_df_from_notes_table()), 78)
  expect_equal(nrow(notes_df_from_notes_table(user_id=c(1234,1235)) %>% distinct(user_id)), 2)

})

test_that("Max date is correct",{
  expect_equal(max_date_for_user(user_id=1234),
               as_datetime(1628618640))   # "2021-08-10 18:04:00 UTC"
})

test_that("Correct number of meals eating watermelon",{
  expect_equal(nrow(food_times_df() %>% distinct(meal)), 3)
  expect_equal(nrow(food_times_df(prefixLength=40)),33)


})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
