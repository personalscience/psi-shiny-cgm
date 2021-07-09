
db_glucose_df <- glucose_df_from_db()

test_that("AUC Calculations", {
  expect_equal(as.integer(auc_calc(db_glucose_df)),134)
})
