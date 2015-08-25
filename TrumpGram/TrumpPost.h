//
//  TrumpPost.h
//  TrumpGram
//
//  Created by Joffrey Mann on 8/7/15.
//  Copyright (c) 2015 Nutech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TrumpPost : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) UIImage *trumpImage;

-(id)initWithPost:(NSString *)username andCaption:(NSString *)caption andImage:(UIImage *)image;

@end
