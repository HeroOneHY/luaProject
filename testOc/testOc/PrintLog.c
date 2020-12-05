//
//  PrintLog.c
//  testOc
//
//  Created by yanhe2 on 2020/12/3.
//

#include "PrintLog.h"


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
