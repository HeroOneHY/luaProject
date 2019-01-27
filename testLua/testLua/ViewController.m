//
//  ViewController.m
//  testLua
//
//  Created by B612 on 2018/10/31.
//  Copyright © 2018年 B612. All rights reserved.
//

#import "ViewController.h"
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"
#import "LuaScriptCore.h"
#import "User.h"
@interface ViewController ()
    
@property (nonatomic) lua_State *state;
    
@end

@implementation ViewController
- (void)setUp{
    //Lua环境的维护需要一个叫lua_State的结构体来支持，其贯穿了整个执行过程。因此，要使用Lua则需要先初始化一个lua_State结构体。
    self.state = luaL_newstate();    //创建新的lua_State结构体
    luaL_openlibs(self.state);        //加载标准库
    lua_settop(self.state, 0);   //清空栈空间，栈有什么用？栈是oc和lua的桥梁用于临时存储数据
}
- (void)testLuacore{
    [self setUp];
    //    lua_pushinteger (self.state, 10);
    //    lua_setglobal(self.state, "hehe");
    //    const NSInteger value = lua_tointeger(self.state, -1);
    //    NSLog(@"%ld",value);
    //加载lua脚本
    NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:@"file" ofType:@"lua"];
    
    NSString *luaContent = [NSString stringWithContentsOfFile:luaFilePath
                            
                                                     encoding:NSUTF8StringEncoding
                            
                                                        error:nil];
    
    int err;
    if (luaContent == nil || [luaContent isEqualToString: @""]) { //判断脚本是否为空
        NSLog(@"Lua_State initial fail，lua file is nil");
    }else {
        err = luaL_loadstring(self.state, [luaContent cStringUsingEncoding: NSUTF8StringEncoding]); //加载lua字符串
        if (0 != err) { //如果发生了错误，错误信息会放在栈顶
            luaL_error(self.state, "cannot compile the lua file: %s",
                       lua_tostring(self.state, -1));
            return;
        }
        /*
         err = lua_pcall(self.state, 0, 0, 0); //表示调用lua函数。其中第二个参数为传入参数的数量，必须与压栈的参数数量一致；第三个参数为返回值的数量，表示调用后其放入栈中的返回值有多少个。
         if (0 != err) { //如果发生了错误，错误信息会放在栈顶
         luaL_error(self.state, "cannot run the lua file: %s",
         lua_tostring(self.state, -1));
         return;
         }
         */
        NSLog(@"Lua_state initial success");
    }
}
int printHelloWorld (lua_State*state){
    
    NSLog(@"hello");
    
    return 0;
    
}
- (void)testLua0{
    [self setUp];
    User *usr = [[User alloc]init];
    usr.name=@"hehe";
//    lua_pushlightuserdata(self.state, (__bridge void *)usr);
//    lua_setglobal(self.state, "userdataVal");
//
    void *instanceRef = lua_newuserdata(self.state, sizeof(usr)); //setglobal只是创建了一个lua对象，这个对象不是和oc关联的，它是和oc数据独立的
    instanceRef = (__bridge_retained void *)usr;
    lua_setglobal(self.state, "userdataVal");
   
    lua_register(self.state, "fuc", printHelloWorld); //注册c方法
    NSString *luaFilePath = [[NSBundle mainBundle] pathForResource:@"file0" ofType:@"lua"];
    
    NSString *luaContent = [NSString stringWithContentsOfFile:luaFilePath
                            
                                                     encoding:NSUTF8StringEncoding
                            
                                                        error:nil];
    int err;
    if (luaContent == nil || [luaContent isEqualToString: @""]) { //判断脚本是否为空
        NSLog(@"Lua_State initial fail，lua file is nil");
    }else {
        err = luaL_loadstring(self.state, [luaContent cStringUsingEncoding: NSUTF8StringEncoding]); //加载lua字符串
      
        if (0 != err) { //如果发生了错误，错误信息会放在栈顶
            luaL_error(self.state, "cannot compile the lua file: %s",
                       lua_tostring(self.state, -1));
            return;
        }
        err = lua_pcall(self.state, 0, 0, 0); //表示调用lua函数。其中第二个参数为传入参数的数量，必须与压栈的参数数量一致；第三个参数为返回值的数量，表示调用后其放入栈中的返回值有多少个。必须调用这个才能执行lua脚本
        if (0 != err) { //如果发生了错误，错误信息会放在栈顶
            luaL_error(self.state, "cannot run the lua file: %s",
                       lua_tostring(self.state, -1));
            return;
        }
        NSLog(@"Lua_state initial success");
    }
 
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self testLua0];
}
- (void)testLua1{
    LSCContext *context = [[LSCContext alloc] init];
    
//    NSString *sPath = [[NSBundle mainBundle]pathForResource:@"module" ofType:@"lua"];
//    [context addSearchPath:sPath];
    //解析lua字符串
    [context evalScriptFromString:@"print('Hello World');"];
    //解析lua文件
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"file" ofType:@"lua"];
    [context evalScriptFromFile:path];
    
    //获取lua变量
    LSCValue *urlValue = [context getGlobalForName:@"url"];
    NSLog(@"url = %@", [urlValue toString]);
    LSCValue *value = [LSCValue stringValue:@"http://www.baidu.com"];
    
    //提供供lua使用的oc方法
    [context registerMethodWithName:@"log" block:^LSCValue *(NSArray<LSCValue *> *arguments) {
        NSLog(@"%@", [arguments[0] toString]);
        return [LSCValue numberValue:@3];
    }];
    //ios调用lua方法
    [context callMethodWithName:@"printUrl" arguments:@[value]];
}


@end
