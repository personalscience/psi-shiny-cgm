active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")

nutrisense_file <- file.path("sample_nutrisense.csv")

test_that("Nutrisense reads correct number of rows", {
  expect_equal(nrow(glucose_df_from_nutrisense(filepath = nutrisense_file)), 90)
})


Sys.setenv(R_CONFIG_ACTIVE = active_env )
