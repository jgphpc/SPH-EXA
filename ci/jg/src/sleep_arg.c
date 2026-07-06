#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  int duration = atoi(argv[1]);
  sleep(duration);
  time_t t = time(NULL);
  printf("%d done at %s", duration, ctime(&t));
  return 0;
}
