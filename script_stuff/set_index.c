#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<fcntl.h>
#include<unistd.h>
void run_ls(){
  int pid;
  pid = fork();
  if(pid < 0){
    printf("Fork error");
    exit(-1);
  }
  else if(pid == 0){
    char* file = "toc.txt";
    int file_descriptor = open(file, O_CREAT | O_WRONLY, 00700);
    if (file_descriptor < 0){
      printf("Error creating file");
      exit(-1);
    }
    if(dup2(file_descriptor, STDOUT_FILENO) < 0){
      printf("Error with dup2");
      exit(-1);
    }
    char* args_list[] = {"ls", "-t", NULL};
    execvp("ls", args_list);
  }
  else{
    wait(NULL);
  }
}
void write_file(char* dir){
  char* in_name = "toc.txt";
  char* out_name = "index.norg";
  FILE* file_in = fopen(in_name, "r");
  FILE* file_out = fopen(out_name, "w");
  char buf[50];
  while(fgets(buf, 50, file_in)){
    char* name = strtok(buf, ".");
    char* ext_t = strtok(NULL, ".");
    char* ext = strtok(ext_t, "\n");
    if(strcmp(ext, "tex") == 0 || (strcmp(ext, "norg")==0 && strcmp(name, "index") != 0)){
      fprintf(file_out, "{/ ");
      fprintf(file_out, "%s", name);
      fprintf(file_out, ".%s}[%s]\n", ext, name);
    }
  }
  fclose(file_in);
  fclose(file_out);
  if(remove("toc.txt") == 0){
    fprintf(stdout, "toc file removed correctly\n");
  }
  else{
    fprintf(stdout, "Error deleting file\n");
  }
}

int main(int argc, char* argv[]){
  const char* dirs[] = {"class", "class", "class", "class" };
  for(int i = 0; i < 4; i++){
    write(STDOUT_FILENO, "starting loop\n", strlen("starting loop\n"));
    if(chdir("/Users/ritroy/notes/") != 0){
      fprintf(stderr, "Directory change failed");
      exit(0);
    }
    if(chdir(dirs[i]) != 0){
      fprintf(stderr, "Directory change fail");
      exit(0);
    }
    run_ls();
    write_file(dirs[i]);
  }
  for(int i = 0; i < 3; i++){
    if(chdir("/Users/ritroy/homework/") != 0){
      fprintf(stderr, "Directory change failed");
      exit(0);
    }
    if(chdir(dirs[i]) != 0){
      fprintf(stderr, "Directory change fail");
      exit(0);
    }
    run_ls();
    write_file(dirs[i]);
  }
}
