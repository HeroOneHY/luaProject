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
#include "lauxlib.h"
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
        /*
         *int lua_gettop (lua_State *L);
         *返回栈顶元素的索引，这个值就是栈中元素的数量，0代表空栈
         */
       // NSLog(@"%d",lua_gettop(self.state)) ; //此时栈顶会有初始化函数
        lua_pcall(self.state,0,0,0); //调用c-api栈中函数初始化
        /*
         *lua_pcall(lua_State *L,int nargs,int nresults,int errfunc)
         *功能 调用栈顶函数
         *nargs 参数个数
         *nresults 返回值个数
         *errFunc 错误处理函数，0表示无，表示错误处理函数在栈中的索引
         */
         if (0 != err) { //如果发生了错误，错误信息会放在栈顶
             luaL_error(self.state, "cannot run the lua file: %s",
             lua_tostring(self.state, -1));
             return;
         }
        NSLog(@"Lua_state initial success");
    }
 //   lua_pushvalue(self.state, -10002);
//    (lua_type(L, (n)) == LUA_TTABLE)
//    lua_istable(self.state,-1);
//  int type =  lua_type(self.state,-1);
//    if (type==LUA_TTABLE) {
//        NSLog(@"table");
//    }
    [self fromOcToLua];
 //   [self fromLuaToOc];
    // Do any additional setup after loading the view, typically from a nib.
}
int printHelloWorld (lua_State *state){
    
    NSLog(@"Hello World!");
    if (lua_gettop(state)>0) { //栈中有数据，说明有参数
        const char*name =lua_tostring(state,1); //取值操作会删除栈顶元素
        
        const char*name2 =lua_tostring(state,2);
        
        NSLog(@"Hello--%s--%s",name,name2); 
    }
    lua_pushstring(state, @"c返回值".UTF8String); //对应的lua函数的返回值，调用结束后会清空栈顶
    return 1; //代表有对应的lua函数个返回值
    
}
int cclosure(lua_State *L)
{
    double upval1, upval2;
    /*
     *lua_upvalueindex获取对应upvalue在栈中的索引，然后用lua_tonumber在对应索引位置取出其值
     *注意upvalue索引1,2是闭包依赖的，不会和其他的闭包中的索引冲突
    */
    upval1 = lua_tonumber(L, lua_upvalueindex(1));
    upval2 = lua_tonumber(L, lua_upvalueindex(2));
    upval1++; upval2++;upval2++;
    /*
     lua_replace为将栈顶元素放到指定位置，并清空栈顶元素
     */
    lua_pushnumber(L, upval1); lua_replace(L, lua_upvalueindex(1));/* 更新upvalue1 */
    lua_pushnumber(L, upval2); lua_replace(L, lua_upvalueindex(2));/* 更新upvalue2 */
    lua_pushnumber(L, upval1 + upval2);
    return 1;
}
static int text (lua_State *L){
    printf("hehea");
    return  0;
}
const struct luaL_Reg memberFunctions [] = {
    {"text", text},
    
    {NULL, NULL}
};

//lua调用oc
- (void)fromOcToLua{
 
    /*
    void *instanceRef = lua_newuserdata(self.state, sizeof(User *));
    
    instanceRef = (__bridge_retained void *)[[User alloc] init];
    
    print_stack(self.state);
    luaL_newmetatable(self.state, "lalala" ); //创建元表 其实就是创建在注册表里面的表
    lua_pushstring(self.state, "__index");//必须要的。
    lua_pushvalue(self.state, -2); // pushes the metatable
    lua_settable(self.state, -3); // metatable.__index = metatable
    const luaL_Reg *l = memberFunctions;
    for (; l->name; l++) {
      lua_pushcclosure(self.state, l->func, 0);
      lua_setfield(self.state, -(0+2), l->name);
    }
    
  
    print_stack(self.state);
    lua_setmetatable(self.state, -2);
    print_stack(self.state);
    lua_setglobal(self.state, "userdataVal");
    
    lua_getglobal(self.state, "test"); //lua的test函数入栈
    lua_call(self.state, 0, 0); //调用栈顶函数
     */
//    lua_getglobal(self.state, "aa"); //lua的test函数入栈
//    lua_pushinteger(self.state, 1024);
//    
//    print_stack(self.state);
//    int type =  lua_type(self.state,-1);
//        if (type==LUA_TTABLE) {
//            NSLog(@"table");
//        }
   // lua_call(self.state, 0, 0); //调用栈顶函数
    /*  变量传递
    lua_pushinteger(self.state, 1024);  //1024入c-api栈
     lua_getglobal(self.state, "test"); //lua的test函数入栈
     lua_call(self.state, 0, 0); //调用栈顶函数
   // lua_pushnumber(self.state, 80.08);
   // lua_pushboolean(self.state, YES);
   // lua_pushstring(self.state, @"Hello World".UTF8String);
       NSLog(@"%d",lua_gettop(self.state)) ;
    lua_setglobal(self.state, "intVal"); //把栈顶的数据变为lua变量，变量名为intVal;清除栈顶元素
    NSLog(@"%d",lua_gettop(self.state)) ; //lua_gettop返回栈中元素个数
    */
    /* 函数传递
    lua_pushcfunction(self.state, printHelloWorld);
    lua_setglobal(self.state, "funcVal");
     */
   /* 数组传递
    *void lua_createtable (lua_State *L, int narr, int nrec);  //创建一个空的table并压入栈中，并预分配narr个array元素的空间和预分配nrec个非array元素的空间
    *void lua_newtable (lua_State *L); // lua_createtable的特例版，相当于调用 lua_createtable(L, 0, 0)
    lua_newtable(self.state); //创建一个Table对象并放入栈顶
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger value = [obj integerValue];
        
        lua_pushinteger(self.state, value);//将数据推入栈顶
        
        lua_rawseti(self.state, 1, idx + 1); //将当前栈顶元素放入Table中，第二个参数代表Table在栈中的位置，第三个参数代表放入Table的位置
        
    }];
    lua_setglobal(self.state, "arrayVal"); //将Table对象设置为lua元素
    //lua中使用 print(arrayVal[2])即可使用
     */
    /* 字典传递
    lua_newtable(self.state); //创建一个Table对象并放入栈顶
    NSDictionary *dic =  @{@"a":@1,@"b":@3, @"c":@4,@"d":@5};
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        NSInteger value = [obj integerValue];

        lua_pushinteger(self.state, value);

        lua_setfield(self.state, -2, key.UTF8String); //lua_setfield与lua_rawseti功能类型，都是把一个元素放入Table中，只是一个用于指定整数索引，一个是指定字符串索引

    }];

    lua_setglobal(self.state, "dictVal");
     //lua中print(dictVal["a"])即可调用
     
     类似的还有lua_settable和lua_rawset，
     void lua_settable (lua_State *L, int index)，index是元表的索引，lua_settable在调用之前需要先压入你要设置的 key 和 value，例如你要设置table["foo"] = "bar"，先把 "foo" 压入栈中，再把 "bar" 压入栈中，然后再调用lua_settable，index取你要设置的table在栈中的索引；lua_rawset除了设置时不会触发元表操作外和lua_settable基本相同
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
    
    /* 闭包
     *lua的闭包（Closure）和Upvalue
     *function func(a) <== 这个函数返回值是一个函数
         return function ()
                    a = a + 1    <== 这里可以访问外部函数func的局部变量a，这个变量a就是upvalue
                    return a
                 end
     *end
     *func返回一个匿名函数，可用变量接取之。该匿名函数有一个upvalue a（有点像C函数的static变量），初值为首次调用func时的参数
     *闭包：一个匿名函数加上其可访问的upvalue
     *c = func(1) ==> c现在指向一个拥有upvalue a = 1的匿名函数，c也被称作一个闭包
      c()         ==> 返回2
      c()         ==> 返回3
      c2 = func(1)==> c2现在指向另外一个拥有upvalue a = 1的匿名函数，c2也被称作一个闭包
      c2()        ==> 返回2
     */
      /*
      lua_pushnumber(self.state, 3);          //    压入第一个upvalue
      lua_pushnumber(self.state, 3);          //   压入第二个upvalue
      lua_pushcclosure(self.state, cclosure, 2); // 压入闭包的同时也把upvalue置入该闭包的upvalue表
      lua_setglobal(self.state, "cclosure"); //关联lua
      */
    
    
    /* //使用usedata并且设置元表，并且填充方法列表
    void *instanceRef = lua_newuserdata(self.state, sizeof(User *));
    
    instanceRef = (__bridge_retained void *)[[User alloc] init];
    
    print_stack(self.state);
    luaL_newmetatable(self.state, "lalala" ); //创建元表 其实就是创建在注册表里面的表
    lua_pushstring(self.state, "__index");//必须要的。
    lua_pushvalue(self.state, -2); // pushes the metatable
    lua_settable(self.state, -3); // metatable.__index = metatable
    const luaL_Reg *l = memberFunctions;
    for (; l->name; l++) {
      lua_pushcclosure(self.state, l->func, 0);
      lua_setfield(self.state, -(0+2), l->name);
    }
    
  
    print_stack(self.state);
    lua_setmetatable(self.state, -2);
    print_stack(self.state);
    lua_setglobal(self.state, "userdataVal");
    
    lua_getglobal(self.state, "test"); //lua的test函数入栈
    lua_call(self.state, 0, 0); //调用栈顶函数
     */
}
- (void)fromLuaToOc{
    lua_getglobal(self.state, "aa"); //lua-->stack 得到全局表，位置-1
   
    //lua_getfield可以代替lua_pushxxx和lua_gettable两个函数
    lua_pushstring(self.state, "key1"); //c-->statck c推入key值，位置-2
    lua_gettable(self.state, -2); //lua-->statck -2代表table的位置，将栈顶元素弹出，得到value放到栈顶-1
    if (lua_isinteger(self.state, -1)){
        printf("integer_val : %lld\n", lua_tointeger(self.state, -1)); //lua_tointeger未执行pop
    }
    lua_pop(self.state, 1); //void lua_pop (lua_State *L, int n); pop n个值从栈中
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
    
    lua_rawgeti(self.state, -1, 2);//int lua_rawgeti (lua_State *L, int index, lua_Integer n); 推送到栈上t[n]值，t代表table
    
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

char* get_val(lua_State *L, int idx)
{
    static char sData[32];
    sData[0] = '\0';

    int type = lua_type(L, idx);
    switch (type)
    {
        case 0: //nil
            {
            snprintf(sData, sizeof(sData), "%s", "nil");
            break;
            }
        case 1://bool
            {
            int val = lua_toboolean(L, idx);
            snprintf(sData, sizeof(sData), "%s", val == 1 ? "true" : "false");
            break;
            }
        case 3://number
            {
            double val = lua_tonumber(L, idx);
            snprintf(sData, sizeof(sData), "%f", val);
            break;
            }
        case 4://string
            {
            const char* val = lua_tostring(L, idx);
            snprintf(sData, sizeof(sData), "%s", val);
            break;
            }
        case 2:
        case 5:
        case 6:
        case 7:
        case 8:
        default:
            {
            const void* val = lua_topointer(L, idx);
            snprintf(sData, sizeof(sData), "%p", val);
            break;
            }

    }

    return sData;
}

int print_stack(lua_State *L)
{
    int iNum = lua_gettop(L);
    printf("==========Total:%d==========\n",iNum);
    for (int i = iNum; i >= 1; i--)
    {
        int idx = i - iNum - 1;
        int type = lua_type(L, i);
        const char* type_name = lua_typename(L, type);
        printf("idx:%d type:%d type_name:%s value:%s\n",idx,type,type_name,get_val(L,i));
    }
    printf("===========================\n");
    return 0;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        NSLog(@"%d",lua_gettop(self.state)) ;
}

@end
