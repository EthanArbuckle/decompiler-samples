struct objc_super {
    id receiver; // +0x0
    Class super_class; // +0x8
};

long +[FBProcessExecutableSlice sliceWithType:subtype:](long a1, long a2)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBProcessExecutableSlice;
    return objc_msgSendSuper2(&v0, @selector(sliceWithType:subtype:));
}
