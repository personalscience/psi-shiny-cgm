
active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


db_glucose_df <- glucose_df_from_db()

test_that("AUC Calculations", {
  expect_equal(as.integer(auc_calc(db_glucose_df)),134)
})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
