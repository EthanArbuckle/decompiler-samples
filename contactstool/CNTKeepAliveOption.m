NSString *+[CNTKeepAliveOption name](void)
{
    return @"keepAlive";
}


unsigned long +[CNTKeepAliveOption options](void)
{
    return 1;
}


NSString *+[CNTKeepAliveOption help](void)
{
    return @"When finished, keeps the process alive until manually interrupted";
}
