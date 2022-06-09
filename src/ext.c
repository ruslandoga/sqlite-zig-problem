#include <stddef.h>

#include "../deps/exqlite/c_src/sqlite3ext.h"
SQLITE_EXTENSION_INIT1

static void sum_step(sqlite3_context *ctx, int argc, sqlite3_value **argv) {
  double *total = (double *)sqlite3_aggregate_context(ctx, sizeof(double));
  if (total == NULL) return sqlite3_result_error_nomem(ctx);
  *total += sqlite3_value_double(argv[0]);
}

static void sum_final(sqlite3_context *ctx) {
  double *total = (double *)sqlite3_aggregate_context(ctx, sizeof(double));
  sqlite3_result_double(ctx, *total);
}

int sqlite3_extc_init(sqlite3 *db, char **pzErrMsg,
                      const sqlite3_api_routines *pApi) {
  SQLITE_EXTENSION_INIT2(pApi);
  sqlite3_create_function(db, "sumc", 1, SQLITE_UTF8, NULL, NULL, sum_step,
                          sum_final);
  return SQLITE_OK;
}
