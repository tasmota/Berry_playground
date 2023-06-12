import path
#load("zap.be")

path.mkdir('/testdir')
path.mkdir('/testdir/test')
var f = open('/testdir/test/test.txt', 'w')
print(f)
f.write('test test')
f.close()

#print(path.remove('/testdir/test/test.txt'))
#print(path.rmdir('/testdir/test'))
#print(path.rmdir('/testdir'))

print(path.listdir('/testdir/test'))

zap('/testdir/', 1)

print(path.listdir('/testdir/test'))
