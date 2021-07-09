

# set the active configuration globally via Renviron.site or Rprofile.site
# Sys.setenv(R_CONFIG_ACTIVE = "localtest")  # save to local postgres

db_glucose_df <- glucose_df_from_db()

test_that("Glucose Database", {
  expect_equal(nrow(db_glucose_df), 11138)
})
