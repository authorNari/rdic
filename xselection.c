/*  xselection.c
 *    version 0.0.4
 *    by Dave Scotto
 */

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <locale.h>
#include <unistd.h>

#include "ruby.h"

static Display *display = 0;
static Window window;

static VALUE cXselection;

static VALUE xselection_open(VALUE self,VALUE display_name)
{
    int screen_num;
    char c[] = "";
    VALUE r_last_str;
    
    Check_Type(display_name, T_STRING);
    display = XOpenDisplay(RSTRING_PTR(display_name));
    
    if(!display)
        rb_raise(rb_eRuntimeError, "illegal DISPLAY");
    
    r_last_str = rb_str_new2(c);
    rb_iv_set(self, "@last_str", r_last_str);

    screen_num = DefaultScreen(display);
    window = XCreateSimpleWindow(display, RootWindow(display, screen_num),
                                 0, 0, BUFSIZ/4-1, 1, 1, 
                                 BlackPixel(display, screen_num),
                                 WhitePixel(display, screen_num));
    
    return self;
}

static void xselection_assert()
{
    if(!display)
        rb_raise(rb_eRuntimeError, "illegal DISPLAY");
    
    if (!setlocale(LC_ALL, ""))
        rb_raise(rb_eRuntimeError, "can not setlocale");
}

static int xselection_get_xtextproperty(XTextProperty* xtextproperty)
{
    static char* target_name[] = { "UTF8_STRING", "COMPOUND_TEXT", " TEXT", "STRING" };
/*
    static char* target_name[] = { "COMPOUND_TEXT", "STRING" };
*/
    static int target_size = sizeof(target_name) / sizeof(char*);
    Atom atom_target, atom_property;
    XEvent xevent;
    int i ,j;
    unsigned long left;
    
    atom_property = XInternAtom (display, "__COPY_TEXT", False);
    
    while(True == XCheckTypedEvent(display, SelectionNotify, &xevent));

    for (i = 0;i < target_size; i++){
        atom_target = XInternAtom (display,target_name[i], False);
        XConvertSelection(display, XA_PRIMARY, atom_target, atom_property, window, CurrentTime);
        j = 0; 
        while(False == XCheckTypedEvent(display, SelectionNotify, &xevent)){
            j ++;
            if(j > 10){
                return False;
            }
            usleep(100);
        }
        
        if (xevent.type == SelectionNotify){
            if (xevent.xselection.selection == XA_PRIMARY) {
                if (xevent.xselection.property == atom_property) {
                    if (xevent.xselection.target == atom_target) {

                        XGetWindowProperty(display, window,
                                           atom_property,
                                           0,
                                           BUFSIZ/4-1,   
                                           True,   
                                           atom_target,
                                           &xtextproperty->encoding,
                                           &xtextproperty->format,
                                           &xtextproperty->nitems,
                                           &left,
                                           &xtextproperty->value);
                        if(xtextproperty->nitems) {
                            return True;
                        }
                    }
                }
            }
        }
    }
    return False;
}

static VALUE xselection_get_string(XTextProperty* xtextproperty)
{
    char **list_of_string;
    int count_of_string;
    VALUE r_str;
    
    XmbTextPropertyToTextList(display,
                              xtextproperty,
                              &list_of_string,
                              &count_of_string);
    r_str = rb_str_new2(list_of_string[0]);
    if (list_of_string)
        XFreeStringList(list_of_string);
    return r_str;
}

static VALUE xselection_get(VALUE self)
{
    XTextProperty xtextproperty;
    VALUE r_str;
    
    xselection_assert();
    
    if (False == xselection_get_xtextproperty(&xtextproperty)){
        return Qnil;
    }
    
    r_str = xselection_get_string(&xtextproperty);
    XFree(xtextproperty.value); 
    return r_str;
}

static VALUE xselection_check(VALUE self)
{
    XTextProperty xtextproperty;
    VALUE str_last;
    int str_len_now, str_len_last;
    char* char_last;
    VALUE r_str;
    
    xselection_assert();
    if (False == xselection_get_xtextproperty(&xtextproperty)){
        return Qnil;
    }
    
    str_len_now = strlen(xtextproperty.value);
    str_last = rb_iv_get(self, "@last_str");
    str_len_last = RSTRING_LEN(str_last);
    char_last = StringValuePtr(str_last);
    
    if (str_len_now == str_len_last){
        if (strncmp(xtextproperty.value, char_last, str_len_now) == 0){
            XFree(xtextproperty.value);
            return Qnil;
        }
    }
    str_last = rb_str_new2(xtextproperty.value);
    rb_iv_set(self, "@last_str", str_last);

    r_str = xselection_get_string(&xtextproperty);
    XFree(xtextproperty.value); 

    return r_str;
}

static VALUE  xselection_close(VALUE self){
    if(display){
        XCloseDisplay(display);
        display = 0;
    }
    return Qnil;
}

void
Init_xselection()
{
    cXselection = rb_define_class("Xselection",rb_cObject);
    rb_define_method(cXselection, "initialize", xselection_open, 1);
    rb_define_method(cXselection, "get", xselection_get, 0);
    rb_define_method(cXselection, "check", xselection_check, 0);
    rb_define_method(cXselection, "close", xselection_close, 0);
}

