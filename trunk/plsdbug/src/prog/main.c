#include <stdio.h>
#include "epc.h"
#include "plsdbug.h"
#include "dbug.h"

int main( int argc, char **argv )
{
  return epc__main( argc, argv, &ifc_plsdbug );
}
