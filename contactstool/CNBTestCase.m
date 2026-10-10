struct CNBTestCase {
    id<CNBImplementation> _implementation; // +0x18
};

id +[CNBTestCase name](void)
{
    return nil;
}


CNBTestCase *-[CNBTestCase initWithImplementation:](id<CNBImplementation> a1)
{
    Class v1 = [self class];
    CNBTestCase *v4 = [super initWithName:[v1 name]];
    if (v4 != nil) {
        v4->_implementation = a1;
    }
    return v4;
}


id<CNBImplementation> -[CNBTestCase implementation](void)
{
    return self->_implementation;
}


void -[CNBTestCase .cxx_destruct](void)
{
    self->_implementation = nil;
}
