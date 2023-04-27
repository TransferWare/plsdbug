CREATE OR REPLACE PACKAGE "UT_PLSDBUG" authid definer as


/* The disabled test need a second session to respond: maybe later. */

--%suitepath(PLSDBUG)
--%suite

--%beforeall
procedure ut_setup;

--%afterall
procedure ut_teardown;

--%test
--%disabled
procedure ut_plsdbug_init;

--%test
--%disabled
procedure ut_plsdbug_done;

--%test
procedure ut_plsdbug_enter;

--%test
procedure ut_plsdbug_leave;

--%test
procedure ut_plsdbug_print1;

--%test
procedure ut_plsdbug_print2;

--%test
procedure ut_plsdbug_print3;

--%test
procedure ut_plsdbug_print4;

--%test
procedure ut_plsdbug_print5;

--%test
--%disabled
procedure ut_strerror;

end ut_plsdbug;
/

