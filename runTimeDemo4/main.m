//
//  main.m
//  runTimeDemo4
//
//  Created by yangL on 16/3/25.
//  Copyright © 2016年 LY. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import "AppDelegate.h"

//int main(int argc, char * argv[]) {
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//    }
//}

#import <objc/runtime.h>
#import <objc/message.h>
#import <stdio.h>

extern int MyUIApplicationMain(int argc, char *argv[], void *principalClassName, void *delegateClassName);

struct MyRect {
    float x;
    float y;
    float width;
    float height;
};
typedef struct MyRect MyRect;

void *navController;
static int numberOfRows = 100;

int tableView_numberOfRowInSection(void *receiver, struct objc_selector *selector, void *tblView, int section) {
    return numberOfRows;
}

void *tableView_cellForRowAtIndexPath(void *receiver, struct objc_selector *selector, void *tblView, void *indexPath) {
    Class TableViewCell = (Class)objc_getClass("UITableViewCell");
    void *cell = class_createInstance(TableViewCell, 0);
    objc_msgSend(cell, sel_registerName("init"));
    char buffer[7];
    
    int row = (int)objc_msgSend(indexPath, sel_registerName("row"));
    sprintf(buffer, "Row %d", row);
    void *label = objc_msgSend(objc_getClass("NSString"), sel_registerName("stringWithUTF8String:"), buffer);
    objc_msgSend(cell, sel_registerName("setText:"), label);
    
    return cell;
}

void tableView_didSelectRowAtIndexPath(void *receiver, struct objc_selector *seletor, void *tblView, void *indexPath) {
    Class ViewController = (Class)objc_getClass("UIViewController");
    void *vc = class_createInstance(ViewController, 0);
    objc_msgSend(vc, sel_registerName("init"));
    char buffer[8];
    int row = (int)objc_msgSend(indexPath, sel_registerName("row"));
    sprintf(buffer, "Item %d", row);
    void *label = objc_msgSend(objc_getClass("NSString"), sel_registerName("stringWithUTF8String"), buffer);
    objc_msgSend(vc, sel_registerName("setTitle"), label);
    
    objc_msgSend(navController, sel_registerName("pushViewController:animated:"), vc, 1);
}

void *createDataSource() {
    Class superclass = (Class)objc_getClass("NSObject");
    Class DataSource = objc_allocateClassPair(superclass, "DataSource", 0);
    class_addMethod(DataSource, sel_registerName("tableView:numberOfRowsInSection:"), (void (*))tableView_numberOfRowInSection, nil);
    class_addMethod(DataSource, sel_registerName("tableView:cellForRowAtIndexPath:"), (void (*))tableView_cellForRowAtIndexPath, nil);
    
    objc_registerClassPair(DataSource);
    return class_createInstance(DataSource, 0);
}

void *createDelegate() {
    Class superClass = (Class)object_getClass(@"NSObject");
    Class DataSource = objc_allocateClassPair(superClass, "Delegate", 0);
    class_addMethod(DataSource, sel_registerName("tableView:didSelectRowAtIndexPath:"), (void (*))tableView_didSelectRowAtIndexPath, nil);
    
    objc_registerClassPair(DataSource);
    return class_createInstance(DataSource, 0);
}

//自定义主函数
void applicationdidFinishLaunching(void *receiver, struct objc_selector *selector, void *application) {
    Class windowClass = (Class)object_getClass(@"UIWindow");
    void *windowInstance = class_createInstance(windowClass, 0);
    
    objc_msgSend(windowClass, sel_registerName("initWithFrame:"), (MyRect){0, 0, 320, 480});
    
    //make key and visiable
    objc_msgSend(windowInstance, sel_registerName("makeKeyAndVisible"));
    
    //创建表
    Class TableViewController = (Class)object_getClass(@"UITableViewController");
    void *tableViewController = class_createInstance(TableViewController, 0);
    objc_msgSend(TableViewController, sel_registerName("init"));
    void *tableView = objc_msgSend(TableViewController, sel_registerName("tableView"));
    objc_msgSend(tableView, sel_registerName("setDataSource"), createDataSource());
    objc_msgSend(tableView, sel_registerName("setDelegate"), createDelegate());
    
    Class NavController = (Class)object_getClass(@"UINavigationController");
    navController = class_createInstance(NavController, 0);
    objc_msgSend(navController, sel_registerName("initWithRootViewCOntroller:"), tableViewController);
    void *view = objc_msgSend(navController, sel_registerName("view"));
    
    //add TableView to window
    objc_msgSend(windowInstance, sel_registerName("addSubview:"), view);
    
}

//create an class named "AppDelegate", and return its name as an instance of class NSString
void *createAppDelegate() {
    Class mySubclass = objc_allocateClassPair((Class)object_getClass(@"NSObject"), "AppDelegate", 0);
    SEL selName = sel_registerName("application:didFinishLaunchingWithOptions:");
    class_addMethod(mySubclass, selName, (void (*))applicationdidFinishLaunching, nil);
    objc_registerClassPair(mySubclass);
    return objc_msgSend(object_getClass(@"NNString"), sel_registerName("stringWithUTF8String:"), "AppDelegate");
}

int main(int argc, char *argv[]) {
    return MyUIApplicationMain(argc, argv, 0, createAppDelegate());
}
