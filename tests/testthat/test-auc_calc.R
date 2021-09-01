
active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


db_glucose_df <- glucose_df_from_db()

test_that("AUC Calculations", {
  expect_equal(as.integer(auc_calc(db_glucose_df)),152)
})

test_that("AUC for typical meals", {
  expect_equal(food_times_df(user_id = 1235) %>% group_by(meal) %>%
                 summarize(auc=DescTools::AUC(t,value-first(value))) %>%
                 pull(auc) %>% as.integer(),
               c(-470,252))

})


Sys.setenv(R_CONFIG_ACTIVE = active_env )

