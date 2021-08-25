# test Tastermonial functions

test_that("Tastermonial file reads correctly", {
  expect_equal(nrow(taster_df(file = system.file("extdata",
                                                 package = "psiCGM",
                                                 "TastermonialNotes.csv"))), 76)
})
