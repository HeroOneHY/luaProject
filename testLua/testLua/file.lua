require "module" --引入module模块，注意不带.lua,文件搜索策略，和addsearch有关

print(module.constant)

print(package.path) --打印搜索路径
url = "https://vimfung.github.io/LuaScriptCore/";


function printUrl(url)

    print (url);
    print(log("hehe"))
    local obj = TestObjClass() --设置一个全局的对象
    obj.name = "yanhe" --给oc对象设置属性(会调用oc的set方法)
    print(obj.name)
    obj:test() --调用oc对象方法
    TestObjClass:test2() --调用oc类方法  难点：怎么调用系统的方法
end

function TestObjClass.prototype:destroy()
         print ("object destroy!"); --因为上面的对象obj是local类型的即局部变量，所以obj在函数执行完会销毁
end
