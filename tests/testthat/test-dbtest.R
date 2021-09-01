

# set the active configuration globally via Renviron.site or Rprofile.site
# Sys.setenv(R_CONFIG_ACTIVE = "localtest")  # save to local postgres

active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")

db_glucose_df <- glucose_df_from_db(from_date="2021-06-01")

test_that("Glucose Database", {
  expect_equal(nrow(db_glucose_df), 3311)
  expect_equal(as.Date(db_glucose_df[1,1]$time),
               as.Date("2021-06-11"))
})

test_that("Max date for user", {
  expect_equal(as.Date(max_date_for_user(user_id=1234)),
               as.Date("2021-08-10 18:04:00 UTC"))
  expect_equal(max_date_for_user(user_id=0000),
               NA)
})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
