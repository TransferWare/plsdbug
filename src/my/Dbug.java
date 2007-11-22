package my;

import java.sql.Connection;
import java.sql.CallableStatement;

/**
 * This class enables debugging using the Oracle dbug package.
 * The following dbug package methods are supported.<br />
 * 1) enter()<br />
 * 2) leave()<br />
 * 3) print()<br />
 * <br />
 *
 * @author G.J. Paulissen &lt;gpaulissen&#64;transfer-solutions.com&gt;
 * @version $Revision: 927 $
 */
public final class Dbug {
    /** The attached connection. Will not be close by Dbug. */
    private static Connection c = null;

    /** Entry for dbug.enter */
    private static final int DBUG_ENTER = 0;

    /** Entry for dbug.leave */
    private static final int DBUG_LEAVE = 1;

    /** Entry for dbug.print without format string */
    private static final int DBUG_PRINT0 = 2;

    /** Entry for dbug.print with format string and 1 argument */
    private static final int DBUG_PRINT1 = 3;

    /** Entry for dbug.print with format string and 2 arguments */
    private static final int DBUG_PRINT2 = 4;

    /** Entry for dbug.print with format string and 3 arguments */
    private static final int DBUG_PRINT3 = 5;

    /** Entry for dbug.print with format string and 4 arguments */
    private static final int DBUG_PRINT4 = 6;

    /** Entry for dbug.print with format string and 5 arguments */
    private static final int DBUG_PRINT5 = 7;

    /** An array of callable statements */
    private static CallableStatement[] cs;

    /**
     * Private constructor.
     *
     * NOTE: the constructor is private because checkstyle reports this error:
     * Utility classes should not have a public or default constructor.
     */
    private void dbug() {
    }

    /**
     * This method attaches to a connection. Must be called prior to
     * calling enter, leave and print methods.
     *
     * @param conn The connection to attach to
     */
    public static void attach(final Connection conn) {
        c = conn;

        try {
            cs = new CallableStatement[DBUG_PRINT5 + 1];

            cs[DBUG_ENTER] = c.prepareCall("{ call dbug.enter(?) }");
            cs[DBUG_LEAVE] = c.prepareCall("{ call dbug.leave }");
            cs[DBUG_PRINT0] = c.prepareCall("{ call dbug.print(?, ?) }");
            cs[DBUG_PRINT1] = c.prepareCall("{ call dbug.print(?, ?, ?) }");
            cs[DBUG_PRINT2] = c.prepareCall("{ call dbug.print(?, ?, ?, ?) }");
            cs[DBUG_PRINT3] =
                c.prepareCall("{ call dbug.print(?, ?, ?, ?, ?) }");
            cs[DBUG_PRINT4] =
                c.prepareCall("{ call dbug.print(?, ?, ?, ?, ?, ?) }");
            cs[DBUG_PRINT5] =
                c.prepareCall("{ call dbug.print(?, ?, ?, ?, ?, ?, ?) }");
        } catch (java.sql.SQLException e) {
            c = null;
        }

    }

    /**
     * This method detaches from a connection. May be called before
     * connection is closed.
     */
    public static void detach() {
        if (cs != null) {
            for (int i = 0; i < cs.length; i++) {
                if (cs[i] != null) {
                    try {
                        cs[i].close();
                    } catch (java.sql.SQLException e) {
                        ;
                    } finally {
                        cs[i] = null;
                    }
                }
            }
            cs = null;
        }
        c = null;
    }

    /**
     * This method calls dbug.enter
     *
     * @param module The module to enter.
     */
    public static void enter(final String module) {
        try {
            cs[DBUG_ENTER].setString(1, module);
            cs[DBUG_ENTER].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.leave
     */
    public static void leave() {
        try {
            cs[DBUG_LEAVE].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param str         The string to print
     */
    public static void print(final String breakPoint, final String str) {
        try {
            cs[DBUG_PRINT0].setString(1, breakPoint);
            cs[DBUG_PRINT0].setString(2, str);
            cs[DBUG_PRINT0].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param fmt         The printf format string
     * @param arg1        The first string argument
     */
    public static void print(final String breakPoint,
                             final String fmt,
                             final String arg1) {
        try {
            int nr = 1;

            cs[DBUG_PRINT1].setString(nr++, breakPoint);
            cs[DBUG_PRINT1].setString(nr++, fmt);
            cs[DBUG_PRINT1].setString(nr++, arg1);
            cs[DBUG_PRINT1].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param fmt         The printf format string
     * @param arg1        The first string argument
     */
    public static void print(final String breakPoint,
                             final String fmt,
                             final Boolean arg1) {
        try {
            String arg1Str;

            if (arg1 == null) {
                arg1Str = "NULL";
            } else if (arg1 == java.lang.Boolean.TRUE) {
                arg1Str = "TRUE";
            } else {
                arg1Str = "FALSE";
            }

            int nr = 1;

            cs[DBUG_PRINT1].setString(nr++, breakPoint);
            cs[DBUG_PRINT1].setString(nr++, fmt);
            cs[DBUG_PRINT1].setString(nr++, arg1Str);
            cs[DBUG_PRINT1].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param fmt         The printf format string
     * @param arg1        The first string argument
     * @param arg2        The second string argument
     */
    public static void print(final String breakPoint,
                             final String fmt,
                             final String arg1,
                             final String arg2) {
        try {
            int nr = 1;

            cs[DBUG_PRINT2].setString(nr++, breakPoint);
            cs[DBUG_PRINT2].setString(nr++, fmt);
            cs[DBUG_PRINT2].setString(nr++, arg1);
            cs[DBUG_PRINT2].setString(nr++, arg2);
            cs[DBUG_PRINT2].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param fmt         The printf format string
     * @param arg1        The first string argument
     * @param arg2        The second string argument
     * @param arg3        The third string argument
     */
    public static void print(final String breakPoint,
                             final String fmt,
                             final String arg1,
                             final String arg2,
                             final String arg3) {
        try {
            int nr = 1;

            cs[DBUG_PRINT3].setString(nr++, breakPoint);
            cs[DBUG_PRINT3].setString(nr++, fmt);
            cs[DBUG_PRINT3].setString(nr++, arg1);
            cs[DBUG_PRINT3].setString(nr++, arg2);
            cs[DBUG_PRINT3].setString(nr++, arg3);
            cs[DBUG_PRINT3].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param fmt         The printf format string
     * @param arg1        The first string argument
     * @param arg2        The second string argument
     * @param arg3        The third string argument
     * @param arg4        The fourth string argument
     */
    public static void print(final String breakPoint,
                             final String fmt,
                             final String arg1,
                             final String arg2,
                             final String arg3,
                             final String arg4) {
        try {
            int nr = 1;

            cs[DBUG_PRINT4].setString(nr++, breakPoint);
            cs[DBUG_PRINT4].setString(nr++, fmt);
            cs[DBUG_PRINT4].setString(nr++, arg1);
            cs[DBUG_PRINT4].setString(nr++, arg2);
            cs[DBUG_PRINT4].setString(nr++, arg3);
            cs[DBUG_PRINT4].setString(nr++, arg4);
            cs[DBUG_PRINT4].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint  The break point
     * @param fmt         The printf format string
     * @param arg1        The first string argument
     * @param arg2        The second string argument
     * @param arg3        The third string argument
     * @param arg4        The fourth string argument
     * @param arg5        The fifth string argument
     */
    public static void print(final String breakPoint,
                             final String fmt,
                             final String arg1,
                             final String arg2,
                             final String arg3,
                             final String arg4,
                             final String arg5) {
        try {
            int nr = 1;

            cs[DBUG_PRINT5].setString(nr++, breakPoint);
            cs[DBUG_PRINT5].setString(nr++, fmt);
            cs[DBUG_PRINT5].setString(nr++, arg1);
            cs[DBUG_PRINT5].setString(nr++, arg2);
            cs[DBUG_PRINT5].setString(nr++, arg3);
            cs[DBUG_PRINT5].setString(nr++, arg4);
            cs[DBUG_PRINT5].setString(nr++, arg5);
            cs[DBUG_PRINT5].executeUpdate();
        } catch (java.sql.SQLException e) {
            ;
        }
    }
}

