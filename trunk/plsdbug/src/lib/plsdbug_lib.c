#ifndef HAVE_CONFIG_H
#define HAVE_CONFIG_H 1
#endif

#if HAVE_CONFIG_H
#include <config.h>
#endif

#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#if HAVE_ASSERT_H
#include <assert.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <dbug.h>

typedef union {
  long  lval;
  void   *pval;
} t_mapping;

static
long
ptr2long( void *pval )
{
  t_mapping mapping;

  assert( sizeof(long) >= sizeof(void*) );
  mapping.lval = 0L;
  mapping.pval = pval;

  return mapping.lval;
}

static
void *
long2ptr( long lval )
{
  t_mapping mapping;

  assert( sizeof(long) >= sizeof(void*) );
  mapping.lval = lval;

  return mapping.pval;
}

int
plsdbug_init( char* i_options,
          long* o_dbug_ctx )
{
  dbug_ctx_t dbug_ctx;
  int status;

  status = dbug_init_ctx( i_options, NULL, &dbug_ctx );
  *o_dbug_ctx = ptr2long( dbug_ctx );

  return status;
}

int
plsdbug_done( long* io_dbug_ctx )
{
  dbug_ctx_t dbug_ctx;
  int status;

  dbug_ctx = long2ptr( *io_dbug_ctx );
  status = dbug_done_ctx( &dbug_ctx );  
  *io_dbug_ctx = ptr2long( dbug_ctx );

  return status;
}

void
plsdbug_enter( long i_dbug_ctx,
           char* i_function )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_enter_ctx( dbug_ctx, __FILE__, i_function, __LINE__, NULL );    
}

void
plsdbug_leave( long i_dbug_ctx )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_leave_ctx( dbug_ctx, __LINE__, NULL );  
}

void
plsdbug_print1( long i_dbug_ctx,
            char* i_break_point,
            char* i_fmt,
            char* i_arg1 )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_print_ctx( dbug_ctx, __LINE__, i_break_point, i_fmt, i_arg1 );  
}

void
plsdbug_print2( long i_dbug_ctx,
            char* i_break_point,
            char* i_fmt,
            char* i_arg1,
            char *i_arg2 )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_print_ctx( dbug_ctx, __LINE__, i_break_point, i_fmt, i_arg1, i_arg2 );
}

void
plsdbug_print3( long i_dbug_ctx,
            char* i_break_point,
            char* i_fmt,
            char* i_arg1,
            char* i_arg2,
            char* i_arg3 )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_print_ctx( dbug_ctx, __LINE__, i_break_point, i_fmt, i_arg1, i_arg2, i_arg3 );
}

void
plsdbug_print4( long i_dbug_ctx,
            char* i_break_point,
            char* i_fmt,
            char* i_arg1,
            char* i_arg2,
            char* i_arg3,
            char* i_arg4 )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_print_ctx( dbug_ctx, __LINE__, i_break_point, i_fmt, i_arg1, i_arg2, i_arg3, i_arg4 );
}

void
plsdbug_print5( long i_dbug_ctx,
            char* i_break_point,
            char* i_fmt,
            char* i_arg1,
            char* i_arg2,
            char* i_arg3,
            char* i_arg4,
            char* i_arg5 )
{
  dbug_ctx_t dbug_ctx;

  dbug_ctx = long2ptr( i_dbug_ctx );
  (void) dbug_print_ctx( dbug_ctx, __LINE__, i_break_point, i_fmt, i_arg1, i_arg2, i_arg3, i_arg4, i_arg5 );
}
