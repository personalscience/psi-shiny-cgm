
# conn_args <- config::get("dataconnection")
# conn_args

#' List all objects in the current PSI database
#' @import DBI config
psi_list_objects <-
  function(conn_args = config::get("dataconnection")) {
    con <- DBI::dbConnect(
      drv = conn_args$driver,
      user = conn_args$user,
      host = conn_args$host,
      port = conn_args$port,
      dbname = conn_args$dbname,
      password = conn_args$password
    )

    dbName <- conn_args$dbname
    dbHost <- conn_args$host

    objects <- DBI::dbListObjects(con)
    tables <- DBI::dbListTables(con)

    DBI::dbDisconnect(con)
    return(list(dbName=dbName, dbHost=dbHost, objects=objects, tables=tables))

  }


test_that("Glucose Record table exists in database", {
  expect_equal("glucose_records" %in% psi_list_objects()$tables, TRUE)
})
