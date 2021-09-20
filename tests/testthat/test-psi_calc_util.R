
test_that("AUC Calculations", {
  expect_equal(as.integer(auc_calc_old(db_glucose_df[1:5,])),86)
})

test_that("AUC for typical meals", {
  expect_equal(food_times_df(user_id = 1235) %>% group_by(meal) %>%
                 summarize(auc=DescTools::AUC(t,value-first(value))) %>%
                 pull(auc) %>% as.integer(),
               c(-484,228))

})

test_that("Components of AUC values are correct", {
  expect_equal(auc_calc_components(auc_example, timelength = 120),c(18.3, 36.23,23.70,3.50, 0, 4.19),
               tolerance = .1)
})

test_that("Full incremental AUC values are correct", {
  expect_equal(auc_calc(auc_example, timelength = 120),85.914,
               tolerance = .1)
})

