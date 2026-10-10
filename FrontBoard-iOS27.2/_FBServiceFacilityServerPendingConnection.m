struct _FBServiceFacilityServerPendingConnection {
    FBSServiceFacility *_facility; // +0x8
    id _completion; // +0x10
};

_FBServiceFacilityServerPendingConnection *+[_FBServiceFacilityServerPendingConnection pendingConnectionToFacility:completion:](id a1, id a2)
{
    return [[_FBServiceFacilityServerPendingConnection alloc] initWithFacility:a1 completion:a2];
}


_FBServiceFacilityServerPendingConnection *-[_FBServiceFacilityServerPendingConnection initWithFacility:completion:](FBSServiceFacility *a1, id a2)
{
    _FBServiceFacilityServerPendingConnection *v2 = [super init];
    if (v2 != nil) {
        v2->_facility = a1;
        v2->_completion = [a2 copy];
    }
    return v2;
}


FBSServiceFacility *-[_FBServiceFacilityServerPendingConnection facility](void)
{
    return self->_facility;
}


void -[_FBServiceFacilityServerPendingConnection setFacility:](FBSServiceFacility *a1)
{
    self->_facility = a1;
}


id -[_FBServiceFacilityServerPendingConnection completion](void)
{
    return self->_completion;
}


long -[_FBServiceFacilityServerPendingConnection setCompletion:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 16);
}


void -[_FBServiceFacilityServerPendingConnection .cxx_destruct](void)
{
    self->_completion = nil;
    self->_facility = nil;
}
