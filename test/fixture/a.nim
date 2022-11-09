type
  A*    = int
  B*          = int

proc my_foo( a: string,  b:string,c:int, ): string  =
  raise newException ( Exception ,
    "foo" )
  foo ( a , b , c )
  d [ a ]  =  3
  discard    "string to discard"

  break
  return   "string to return"
