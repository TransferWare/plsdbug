package my;

import java.sql.DriverManager;
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
 * @version $Revision$
 */
public class dbug
  {
    // The attached connection.
    private static Connection _conn = null;

    /**
     * This method attaches to a connection. Must be called prior to 
     * calling enter, leave and print methods.
     *
     * @param conn The connection to attach to
     */
    public static void attach(Connection conn)
      {
          _conn = conn;
      }

    /**
     * This method detaches from a connection. May be called before
     * connection is closed.
     */
    public static void detach()
      {
          _conn = null;
      }

    /**
     * This method calls dbug.enter
     *
     * @param module The module to enter.
     */
    public static void enter(String module)
      {
          try
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.enter(?) }");

                  cs.setString(1, module);
                  cs.executeUpdate();
                  cs.close();
              }
          catch (java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.leave
     */
    public static void leave()
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.leave }");

                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param str
     */
    public static void print(String breakPoint, String str)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?) }");

                  cs.setString(1, breakPoint);
                  cs.setString(2, str);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param fmt
     * @param arg1
     */
    public static void print(String breakPoint, String fmt, String arg1)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?, ?) }");

                  cs.setString(1, breakPoint);
                  cs.setString(2, fmt);
                  cs.setString(3, arg1);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param fmt
     * @param arg1
     */
    public static void print(String breakPoint, String fmt, Boolean arg1)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?, ?) }");
                  String arg1_str = ( arg1 == null ? "NULL" : ( arg1 == java.lang.Boolean.TRUE ? "TRUE" : "FALSE" ) );

                  cs.setString(1, breakPoint);
                  cs.setString(2, fmt);
                  cs.setString(3, arg1_str);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param fmt
     * @param arg1
     * @param arg2
     */
      public static void print(String breakPoint, String fmt, String arg1, String arg2)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?, ?, ?) }");

                  cs.setString(1, breakPoint);
                  cs.setString(2, fmt);
                  cs.setString(3, arg1);
                  cs.setString(4, arg2);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param fmt
     * @param arg1
     * @param arg2
     * @param arg3
     */
      public static void print(String breakPoint, String fmt, String arg1, String arg2, String arg3)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?, ?, ?) }");

                  cs.setString(1, breakPoint);
                  cs.setString(2, fmt);
                  cs.setString(3, arg1);
                  cs.setString(4, arg2);
                  cs.setString(5, arg3);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param fmt
     * @param arg1
     * @param arg2
     * @param arg3
     * @param arg4
     */
      public static void print(String breakPoint, String fmt, String arg1, String arg2, String arg3, String arg4)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?, ?, ?, ?) }");

                  cs.setString(1, breakPoint);
                  cs.setString(2, fmt);
                  cs.setString(3, arg1);
                  cs.setString(4, arg2);
                  cs.setString(5, arg3);
                  cs.setString(6, arg4);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }

    /**
     * This method calls dbug.print
     *
     * @param breakPoint
     * @param fmt
     * @param arg1
     * @param arg2
     * @param arg3
     * @param arg4
     * @param arg5
     */
      public static void print(String breakPoint, String fmt, String arg1, String arg2, String arg3, String arg4, String arg5)
      {
          try 
              {
                  CallableStatement cs = _conn.prepareCall("{ call dbug.print(?, ?, ?, ?, ?, ?) }");

                  cs.setString(1, breakPoint);
                  cs.setString(2, fmt);
                  cs.setString(3, arg1);
                  cs.setString(4, arg2);
                  cs.setString(5, arg3);
                  cs.setString(6, arg4);
                  cs.setString(7, arg5);
                  cs.executeUpdate();
                  cs.close();
              }
          catch(java.sql.SQLException e)
              {
              }
      }
  }
