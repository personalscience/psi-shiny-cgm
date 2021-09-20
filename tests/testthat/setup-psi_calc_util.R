
active_env <- Sys.getenv("R_CONFIG_ACTIVE")
Sys.setenv(R_CONFIG_ACTIVE = "localtest")

db_glucose_df <- glucose_df_from_db()

# from Table 5
auc_example <- tibble(
  time = c(0	 ,
        15,
        30,
        45,
        60,
        90,
        120),

  value = c( 3.67,
               6.11,
               6.06,
               4.44,
               3.17,
               3.61,
               4)
)

Sys.setenv(R_CONFIG_ACTIVE = active_env )

