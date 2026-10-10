NSString *+[CNTCommand name](void)
{
    return @"";
}


id +[CNTCommand usage](void)
{
    objc_exception_throw(CNAbstractMethodException(self, _cmd));
}


id +[CNTCommand commandWithArguments:logger:error:](id a1, id a2, id *a3)
{
    objc_exception_throw(CNAbstractMethodException(self, _cmd));
}
