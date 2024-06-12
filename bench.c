// cc -O2 -shared helper.c -o libhelper.so

#include <lua.h>
#include <time.h>

int clock_ns(lua_State *L) {
	struct timespec tp;
	clock_gettime(CLOCK_MONOTONIC, &tp);
	lua_Integer nsec =
	    1000000000 * ((lua_Integer)tp.tv_sec) + ((lua_Integer)tp.tv_nsec);
	lua_pushinteger(L, nsec);
	return 1;
}
