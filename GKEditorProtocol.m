//
//  NSObject+GKEditingProtocol.m
//  GHome
//
//  Created by Gaurav Khanna on 4/16/11.
//

#import "GKEditorProtocol.h"

NSString * const GKEditorStartEditingNotification = @"GKEditorStartEditingNotification";
NSString * const GKEditorEndEditingNotification = @"GKEditorEndEditingNotification";

@interface NSObject (GKEditorPrivate)
- (void)gk_editingNotification:(NSNotification *)notification;
@end

@implementation NSObject (GKEditor)

// Add self as observer to notifications, usually during init
- (void)adoptEditorProtocol {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gk_editingNotification:) name:GKEditorStartEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gk_editingNotification:) name:GKEditorEndEditingNotification object:nil];
}

// Process received notification, call super, call self
- (void)gk_editingNotification:(NSNotification *)notification {
    if ([NSStringFromClass([self class]) isEqualToString:@"NSObject"])
        return;

    BOOL editing = [notification.name isEqualToString:GKEditorStartEditingNotification];

    if (!class_respondsToSelector(class_getSuperclass([self class]), @selector(setEditing:animated:)))
        return;
    //TODO:
    // Finds super at runtime to avoid compiler issues with using super in a category for NSObject
    //NSObjectMessageSendSuper(self, @selector(setEditing:animated:), editing, [notification.object boolValue]);
    //struct objc_super super1;
    //super1.receiver = (__bridge_retained void*)self;
    //super1.super_class = class_getSuperclass([self class]);
    //objc_msgSendSuper(&(struct objc_super){(__bridge_retained void*)self, class_getSuperclass([self class])}, @selector(setEditing:animated:), editing, [notification.object boolValue]);

    //FIXME: Finds super at runtime to avoid compiler issues with using super in a category for NSObject
    //NSObjectMessageSendSuper( self, setEditing:animated:, editing, [notification.object boolValue]);

    if (![self conformsToProtocol:@protocol(GKEditorProtocol)])
        return;

    [(id<GKEditorProtocol>)self setEditing:editing animated:[notification.object boolValue]];
}

// Default implementation doesn't need anything
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

}

- (void)startEditingAnimated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:GKEditorStartEditingNotification object:[NSNumber numberWithBool:animated]];
}

- (void)endEditingAnimated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:GKEditorEndEditingNotification object:[NSNumber numberWithBool:animated]];
}

@end
