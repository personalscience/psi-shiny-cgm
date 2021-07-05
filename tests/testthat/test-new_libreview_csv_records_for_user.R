
SAMPLE_NEW_CSV <- file.path("SamplePerson_glucose.csv")
FAKE_NEW_USER_ID <- -1234

test_that("can find all new records in a CSV file not in the databaes", {
  expect_equal(nrow(glucose_df_from_libreview_csv(file=SAMPLE_NEW_CSV,
                                                  user_id = FAKE_NEW_USER_ID)),
               14) # This file should have 14 rows in its dataframe.
})
