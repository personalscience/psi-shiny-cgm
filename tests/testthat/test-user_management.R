
active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")


test_that("Correct usernames", {
  expect_equal(username_for_id(1234), "Richard Sprague")
})

Sys.setenv(R_CONFIG_ACTIVE = active_env )
