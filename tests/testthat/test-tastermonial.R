# test Tastermonial functions

test_that("Tastermonial file reads correctly", {
  expect_equal(nrow(taster_df()), 27)
})
