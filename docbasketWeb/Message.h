//
//  Message.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/24/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//
//{
//    basket =         {
//        address = "50-9 Chungmuro 2(i)-ga, Jung-gu, Seoul, South Korea";
//        "begin_at" = "<null>";
//        description = "\Ud14c\Uc2a4\Ud2b8 \Ud14c\Uc2a4\Ud2b8";
//        "end_at" = "<null>";
//        id = "c68df8e8-80d2-4aa1-93b5-df3f44a3ab84";
//        "is_public" = 1;
//        latitude = "37.5620001424006";
//        longitude = "126.989399045706";
//        permission =             (
//        );
//        "poi_id" = "<null>";
//        "poi_title" = "<null>";
//        range = "<null>";
//        telephone = "<null>";
//        title = "\Uc774\Ubbf8\Uc9c0 \Ud14c\Uc2a4\Ud2b8";
//        "user_id" = "bb5774c9-2c4e-41d0-b792-530e295e1ca6";
//    };
//    "created_at" = "2014-07-24T09:06:45.033Z";
//    description = "Jaecheol Kim checked in \Uc774\Ubbf8\Uc9c0 \Ud14c\Uc2a4\Ud2b8.";
//    id = "11bdffb2-06f3-46f0-8d72-a3bc64986f64";
//    user =         {
//        id = "bb5774c9-2c4e-41d0-b792-530e295e1ca6";
//        image = "http://graph.facebook.com/330572667096940/picture";
//        name = "Jaecheol Kim";
//    };
//    verb = "checked in";
//}

#import <Foundation/Foundation.h>
#import "Docbasket.h"

@interface Message : NSObject
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) Docbasket *basket;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;


@end
