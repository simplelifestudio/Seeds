//
//  SeedsVisitor.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-7.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFHppleElement+SeedVisitable.h"
#import "TFHppleElement.h"
#import "SeedBuilder.h"

@interface SeedsVisitor : NSObject

@property (nonatomic, strong) SeedBuilder* builder;

-(NSArray*) visitNodes:(NSArray*) elements;
-(void) visitTextNode:(TFHppleElement*) element;
-(void) visitImageNode:(TFHppleElement*) element;
-(void) visitAnchorNode:(TFHppleElement*) element;

@end