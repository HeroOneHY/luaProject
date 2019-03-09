//
//  ViewController.m
//  Lua基础
//
//  Created by HeroOneHy on 2019/2/24.
//  Copyright © 2019年 HeroOneHy. All rights reserved.
//

#import "ViewController.h"
#import "LuaScriptCore.h"
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"
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

- (void)viewDidLoad {
    
    [super viewDidLoad];
      [self setUp];
   // [self fromOcToLua];
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
        
         err = lua_pcall(self.state, 0, 0, 0); //表示调用lua函数。其中第二个参数为传入参数的数量，必须与压栈的参数数量一致；第三个参数为返回值的数量，表示调用后其放入栈中的返回值有多少个。
         if (0 != err) { //如果发生了错误，错误信息会放在栈顶
         luaL_error(self.state, "cannot run the lua file: %s",
         lua_tostring(self.state, -1));
         return;
         }
        
        NSLog(@"Lua_state initial success");
    }
    [self fromLuaToOc];
    // Do any additional setup after loading the view, typically from a nib.
}
int printHelloWorld (lua_State *state){
    
    NSLog(@"Hello World!");
    if (lua_gettop(state)>0) { //栈中有数据，说明有参数
        const char*name =lua_tostring(state,1); //取值操作会删除栈顶元素
        
        const char*name2 =lua_tostring(state,2);
        
        NSLog(@"Hello--%s--%s",name,name2); 
    }
    lua_pushstring(state, @"c返回值".UTF8String); //返回值，调用结束后会清空栈顶
    return 1; //代表有1个返回值
    
}

//lua调用oc
- (void)fromOcToLua{
    /*  变量传递
    lua_pushinteger(self.state, 1024);  //1024入栈
   // lua_pushnumber(self.state, 80.08);
   // lua_pushboolean(self.state, YES);
   // lua_pushstring(self.state, @"Hello World".UTF8String);
       NSLog(@"%d",lua_gettop(self.state)) ;
    lua_setglobal(self.state, "intVal"); //把栈顶的数据变为lua变量，变量名为intVal;清除栈顶元素
    NSLog(@"%d",lua_gettop(self.state)) ;
    */
    /* 函数传递
    lua_pushcfunction(self.state, printHelloWorld);
    lua_setglobal(self.state, "funcVal");
     */
   /* 数组传递
    lua_newtable(self.state); //创建一个Table对象并放入栈顶
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger value = [obj integerValue];
        
        lua_pushinteger(self.state, value);
        
        lua_rawseti(self.state, 1, idx + 1); //将当前栈顶元素放入Table中，第二个参数代表Table在栈中的位置，第三个参数代表放入Table的位置
        
    }];
    lua_setglobal(self.state, "arrayVal");
     */
    /* 字典传递
    lua_newtable(self.state);
    NSDictionary *dic =  @{@"a":@1,@"b":@3, @"c":@4,@"d":@5};
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        NSInteger value = [obj integerValue];

        lua_pushinteger(self.state, value);

        lua_setfield(self.state, -2, key.UTF8String); //lua_setfield与lua_rawseti功能类型，都是把一个元素放入Table中，只是一个用于指定整数索引，一个是指定字符串索引

    }];

    lua_setglobal(self.state, "dictVal");
    */
    
    /* 自定义数据
    //强引用Userdata，由Lua的GC来负责该类型变量的生命周期。
    void *instanceRef = lua_newuserdata(self.state, sizeof(User *));
    
    instanceRef = (__bridge_retained void *)[[User alloc] init];
    
    lua_setglobal(self.state, "userdataVal");
    
    //如果你要传递的对象并不需要Lua来管理生命周期，那么就可以创建一个弱引用的Userdata
    User *user = [[User alloc] init];
    
    lua_pushlightuserdata(self.state, (__bridge void *)(user));
    
    lua_setglobal(self.state, "userdataVal");
    */
}
- (void)fromLuaToOc{
    /* 获取变量
    lua_getglobal(self.state, "aa"); //把lua中的变量放入栈中
    const char *value = lua_tostring(self.state, -1); //把栈中的变量取出
    lua_pop(self.state, 1); //清除栈顶
    NSLog(@"aa = %s",value);
    */
    /* 调用lua函数
    lua_getglobal(self.state, "toOc");
    lua_pushinteger(self.state, 1000);
    lua_pushinteger(self.state, 24);
    lua_pcall(self.state, 2, 1, 0);//其中第二个参数为传入参数的数量，必须与压栈的参数数量一致；第三个参数为返回值的数量，表示调用后其放入栈中的返回值有多少个。第四个参数是用于发生错误处理时的代码返回。
    NSInteger retVal = lua_tonumber(self.state, -1);
    lua_pop(self.state, 1);
    NSLog(@"retVal = %ld", retVal);
    */
    /* Table的获取和遍历 （key，value）
    lua_getglobal(self.state, "aa");
    lua_getfield(self.state, -1, "key2");
    NSInteger value = lua_tonumber(self.state, -1);
    NSLog(@"value = %ld", value);
    lua_pop(self.state, 1);
    */
    /* Table的获取和遍历 没有key
    lua_getglobal(self.state, "aa");
    
    lua_rawgeti(self.state, -1, 2);
    
    NSInteger value = lua_tonumber(self.state, -1);
    
    NSLog(@"value = %ld", value);
    
    lua_pop(self.state, 1);
    */
     /*       //Table进行遍历
    lua_getglobal(self.state, "aa");
    
    lua_pushnil(self.state);
    
    while (lua_next(self.state, -2)){
        
        NSInteger value = lua_tonumber(self.state, -1);
        
        if (lua_type(self.state, -2) == LUA_TSTRING) {
            
            const char *key = lua_tostring(self.state, -2);
            
            NSLog(@"key = %s, value = %ld", key, value);
            
        }
        
        else if (lua_type(self.state, -2) == LUA_TNUMBER) {
            
            NSInteger key = lua_tonumber(self.state, -2);
            
            NSLog(@"key = %ld, value = %ld", key, value);
            
        }
        
        lua_pop(self.state, 1);
        
        }
      */
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        NSLog(@"%d",lua_gettop(self.state)) ;
}

@end
