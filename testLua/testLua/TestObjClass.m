//
//  TestObjClass.m
//  testLua
//
//  Created by B612 on 2019/1/22.
//  Copyright © 2019年 B612. All rights reserved.
//

#import "TestObjClass.h"

@implementation TestObjClass
- (NSString *)test
{
    printf("im oc\n");
    return @"Hello lua! Im oc";
}
+(NSString *)test2
{
     printf("im oc class method\n");
     return @"Hello lua! Im oc";
}
-(void)setName:(NSString *)name{
    _name = name;
    printf("设置name\n");
}
@end
