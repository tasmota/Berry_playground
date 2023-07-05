# Virtual Members


"Virtual Member" is a powerful feature of Berry.

Here it should be shown:

- how to use virtual members ?
- how can you use them in practice?


## In a nutshell

Let us define a simple class named Test

```vb
# our test class
class Test
   var name
end

```
and do some assignments.

```vb
var test=Test()
test.name='mike'

test.age=55 # !! this will cause an exception, because the member is unkown

```

Now we do the same with DynClass. This class uses the 'virtual members'. 
Check also the [Berry Documentation](https://berry.readthedocs.io/en/latest/source/en/Chapter-8.html#module-undefined).

```vb
var test=DynClass()
test.name='mike'
test.age=55
test.description='a tired man'
```

As we can see, the members are added at runtime. No error is rised.

## What can this be used for

We use now function 'toJson() and get a the json-representation of the object instance.

```vb
var ss = test.toJson() # '{"age":55,"description":"a tired man","name":"mike"}'
print(ss)
```

But it works also vice versa. 

Let us add the new member 'carCount' in the json-string and let us load this in a new DynClass instance.

```vb

var test2=DynClass()
var ss = '{"age":55,"description":"a tired man","name":"mike", "carCount":3}'
test2.loadJson(ss)

print ("carcount:",str(test2.carCount))
print ("age:",str(test2.age))
print ("name:",test2.name)
print ("description:",test2.description)

```

All members of the json-string exists also as member in the DynClass-instance 'test2'.

***The result: Dynclass can be used as a JSON object mapper.***



[return](../README.md)

[download all tutorials and code blocks](../../tutorial-code-blocks)




