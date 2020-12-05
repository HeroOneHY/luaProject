local screenWidth, screenHeight = System:screenSize()
---_G.xpcall2(); ---自定义方法 -lbaselib.c
---print2("basgfj")  ---自定义方法 -lbaselib.c
print(_G._VERSION)
---print(_LOADED[_G])
-- Test Label 通过Label方法创建一个元表
local label = Label()
label:text(System:ios() and "iOS" or "Android")
label:textColor(0x000000)
label:frame(0, 0, screenWidth, screenHeight)
label:textAlign(TextAlign.CENTER)

-- Test Button
local btn = Button()

btn:frame(0, 0, 200, 200)

btn:text("Click Me2")

btn:backgroundColor(0xff0000)

btn:callback(
function()
   print("Hello World thl")
end)
