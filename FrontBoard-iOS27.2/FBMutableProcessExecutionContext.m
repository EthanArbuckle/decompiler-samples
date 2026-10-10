FBProcessExecutionContext *-[FBMutableProcessExecutionContext copyWithZone:](long a1)
{
    FBProcessExecutionContext *v0 = [FBProcessExecutionContext allocWithZone:a1];
    return [v0 _initWithExecutionContext:self];
}
