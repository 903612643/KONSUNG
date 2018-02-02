//
//  AppDelegate.h
//  KONSUNG
//
//  Created by 羊德元 on 15/6/25.
//  Copyright (c) 2015年 KONSUNG. All rights reserved.
//



#import "UserObj.h"

static UserObj *userObj;

@interface UserObj()
{
    
}
@end

@implementation UserObj


+(UserObj*)getUserObj{
    
    if (!userObj) {
        userObj = [[UserObj alloc] init];
        [userObj receWithTimeou];
    }
    return userObj;
    
}


-(void)receWithTimeou{
    _user = [[NSDictionary alloc] init];
    _strUserName = nil;
}


@end
