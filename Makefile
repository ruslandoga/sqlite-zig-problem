.PHONY: compile-mac compile-c-mac compile-zig-mac

compile-mac:
	make compile-c-mac
	make compile-zig-mac

compile-c-mac:
	gcc -fPIC -dynamiclib -I src src/ext.c -o dist/extc.dylib

# zig build-lib -O ReleaseSafe -fPIC -Isrc -dynamic src/ext.zig
compile-zig-mac:
	zig build-lib -fPIC -Isrc -dynamic src/ext.zig
	mv libext.dylib dist/extzig.dylib
