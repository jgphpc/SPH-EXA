#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
  int rank = 0, size = 1;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
 
  int duration = atoi(argv[1]);
  sleep(duration);
  time_t t = time(NULL);
  if (rank == 0) {
    printf("rank:%d/%d slept %d sec done at %s", rank, size, duration, ctime(&t));
  }

  MPI_Finalize();
  return 0;
}
