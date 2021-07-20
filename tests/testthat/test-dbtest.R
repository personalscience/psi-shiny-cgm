

# set the active configuration globally via Renviron.site or Rprofile.site
# Sys.setenv(R_CONFIG_ACTIVE = "localtest")  # save to local postgres

db_glucose_df <- glucose_df_from_db()

test_that("Glucose Database", {
  expect_equal(nrow(db_glucose_df), 11138)
})

test_that("Max date for user", {
  expect_equal(as.Date(psiCGM:::max_date_for_user(user_id=1234)),
               as.Date("2021-06-25 06:46:00 UTC"))
})
