//
//  NCAutocompleteTextView.h
//  Example
//
//  Created by Daniel Weber on 9/28/14.
//  Copyright (c) 2014 Null Creature. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol NCRAutocompleteTableViewDelegate <NSObject>
@optional
- (NSImage *)textView:(NSTextView *)textView imageForCompletion:(NSString *)word;
- (NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index;

// I added this for my syntax higlighter and line tally controller - Emily B.
- (void) textWillBeChecked;
@end

@interface NCRAutocompleteTextView : NSTextView <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate>

// I also renamed this so my text processors would work properly - Emily B.
@property (nonatomic, weak) id <NCRAutocompleteTableViewDelegate> ncrDelegate;

@end
