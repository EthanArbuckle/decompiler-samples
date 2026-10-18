struct UARPDeploymentRuleConfig {
    NSDate *_goLiveDate; // +0x8
    NSArray *_countryList; // +0x10
    NSNumber *_rampPeriod; // +0x18
    NSNumber *_deploymentLimit; // +0x20
};

NSDate *-[UARPDeploymentRuleConfig goLiveDate](void)
{
    return objc_getProperty(self, _cmd, 8, 1);
}


void -[UARPDeploymentRuleConfig setGoLiveDate:](NSDate *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 8);
}


NSArray *-[UARPDeploymentRuleConfig countryList](void)
{
    return objc_getProperty(self, _cmd, 16, 1);
}


void -[UARPDeploymentRuleConfig setCountryList:](NSArray *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 16);
}


NSNumber *-[UARPDeploymentRuleConfig rampPeriod](void)
{
    return objc_getProperty(self, _cmd, 24, 1);
}


void -[UARPDeploymentRuleConfig setRampPeriod:](NSNumber *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 24);
}


NSNumber *-[UARPDeploymentRuleConfig deploymentLimit](void)
{
    return objc_getProperty(self, _cmd, 32, 1);
}


void -[UARPDeploymentRuleConfig setDeploymentLimit:](NSNumber *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 32);
}


void -[UARPDeploymentRuleConfig .cxx_destruct](void)
{
    self->_deploymentLimit = nil;
    self->_rampPeriod = nil;
    self->_countryList = nil;
    self->_goLiveDate = nil;
}
