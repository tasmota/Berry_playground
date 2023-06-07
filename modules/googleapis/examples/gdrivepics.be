import string
import introspect

#load('/googleoath.be')
#load('/googledrive.be')

var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
var gdrive = google_drive(auth)

if !global.piccount
  global.piccount = 0
end

var shared_folder_id = "1evt2oAqN0xQ8mQOj8KYDUR4Om7QTrvna"
var picfoldername = 'pics2'
var howmany = 2

print('get picfolder ' .. picfoldername)
var picfolders = gdrive.readdir(shared_folder_id, "name%20=%20%27" .. picfoldername .. "%27", "files(id)")
print(picfolders)
var picfolderid = nil
if picfolders && picfolders['files']
  var files = picfolders['files']
  if size(files)
    picfolderid = files[0]['id']
    print('found picfolder ' .. picfolderid)
  end
end

if !picfolderid
  print('create picfolder ' .. picfoldername)
  picfolderid = gdrive.mkdir(shared_folder_id, picfoldername)
  print('created picfolder ' .. picfolderid)
end


def uploadPicNow(infolderid)
  var cmd = "wcgetpicstore 0"; # force a read into the first buffer, and return the buffer addr/len
  var resobj = tasmota.cmd(cmd);
  # res like {"WCGetpicstore":{"addr":123456,"len":20000,"buf":1}
  var addr = resobj['WCGetpicstore']['addr']
  var len = resobj['WCGetpicstore']['len']
  if len
    print('got picture')
    var p = introspect.toptr(addr) # p is now of type ptr:
    var b = bytes(p, len) # b is now an unmanaged bytes object:  b.ismapped() should return true
    print(b)
    gdrive.write(infolderid, 'frame' .. piccount .. '.jpeg', b)
    piccount = piccount + 1
  else 
    print('no picture')
  end
end

if picfolderid
  for i:0..(howmany-1)
    uploadPicNow(picfolderid)
  end
end