import json
import string

#load('/googleoath.be')

class google_drive
  var auth
  def init(auth)
    self.auth = auth
  end
  
  def readdir(folderid, query, fields, pageSize, pageToken)
    var cl = webclient()
    
    var url = 'https://www.googleapis.com/drive/v3/files?trashed=false'
    if folderid
      url = url .. "&q=%22" .. folderid .. "%22%20in%20parents"
      if query
        url = url .. "%20and%20(" .. query .. ")"
      end
    else
      if query
        url = url .. "&q=" .. query
      end
    end
    if fields
      url = url .. "&fields=" .. fields
    end
    # don't blow away our memory by asking for too many at a time
    if pageSize
      url = url .. "&pageSize=" .. pageSize
    else
      url = url .. "&pageSize=10"
    end
    if pageToken
      url = url .. "&pageToken=" .. pageToken
    end
    print(url)
    cl.begin(url)
    
    self.auth.add_access_key(cl)
    #print('begin readdir')
    var r = cl.GET()
    var s = cl.get_string()
    var m = json.load(s)
    if r != 200
      print('readdir failed ' .. r)
    end
    return m
  end
  
  def delete(fileid)
    var cl = webclient()
    var url = 'https://www.googleapis.com/drive/v3/files/' .. fileid 
    print(url)
    cl.begin(url)
    self.auth.add_access_key(cl)
    #print('begin delete')
    var r = cl.DELETE("")
    #print('called delete')
    var s = cl.get_string()
    #print('resp str ' .. s)
    var m = json.load(s)
    #print('resp map ' .. m)
    if r != 204 # note google returns 'No Content' if delete success, and body of resp is empty.
      print('delete failed ' .. r .. s)
      return true
    end
    return false
  end

  def mkdir(infolderid, name)
    # create a 'file' with mimeType 'application/vnd.google-apps.folder', and return it's id
    var cl = webclient()
    cl.begin('https://www.googleapis.com/drive/v3/files?uploadType=media')
    #print('begin file create')
    var body = '{"name":"' .. name .. '","parents":["' .. infolderid .. '"],"mimeType":"application/vnd.google-apps.folder"}'
    self.auth.add_access_key(cl)
    var r = cl.POST(body)
    if r == 200
      var s = cl.get_string();
      #print('folder created ' .. s)

      var id = json.load(s)['id']
      print('created ' .. name .. ' as ' .. id)
      return id
    else
      print('folder create failed' .. r .. resp)
      return nil
    end
  end

  
  def write(folderid, name, bytesdata)
    # first, create the file, and read it's id
    var cl = webclient()
    cl.begin('https://www.googleapis.com/drive/v3/files?uploadType=media')
    #print('begin file create')
    var body = '{"name":"' .. name .. '","parents":["' .. folderid .. '"]}'
    self.auth.add_access_key(cl)
    var r = cl.POST(body)
    var s = cl.get_string();
    if r == 200
      #print('file created ' .. s)

      var id = json.load(s)['id']
      #print('file id ' .. id)
      var clfile = webclient()
      var url = 'https://www.googleapis.com/upload/drive/v3/files/' ..id .. '?uploadType=media'
      #print(url)
      clfile.begin(url)
      #print('begin file upload')
      body = bytesdata
      self.auth.add_access_key(clfile)
      #print('posting')
      r = clfile.PATCH(body)
      #print('posted' .. r)
      var resp = clfile.get_string();
      if r == 200
        print('uploaded ' .. name)
      else
        print('upload of ' .. name .. ' failed ' .. r)
        print(resp)
      end
      return resp
    else
      print('file create failed' .. r .. s)
      return resp
    end
  end
  
  def getparents(fileid)
    var cl = webclient()
    var url = 'https://www.googleapis.com/drive/v2/files/' .. fileid .. '/parents'
    print(url)
    cl.begin(url)
    self.auth.add_access_key(cl)
    #print('begin getparents')
    var r = cl.GET()
    #print('called get')
    var s = cl.get_string()
    #print('resp str ' .. s)
    var m = json.load(s)
    #print('resp map ' .. m)
    if r != 200
      print('get parents failed ' .. r)
      print('resp map ' .. m)
    end
    return m
  end

  def getfiledetails(fileid)
    var cl = webclient()
    var url = 'https://www.googleapis.com/drive/v2/files/' .. fileid
    print(url)
    cl.begin(url)
    self.auth.add_access_key(cl)
    var r = cl.GET()
    var s = cl.get_string()
    var m = json.load(s)
    if r != 200
      print('get file failed ' .. r)
      print('resp map ' .. m)
    end
    return m
  end

  def readfileasstring(fileid)
    var cl = webclient()
    var url = 'https://www.googleapis.com/drive/v2/files/' .. fileid .. '?alt=media'
    print(url)
    cl.begin(url)
    self.auth.add_access_key(cl)
    var r = cl.GET()
    var s = nil
    try
      s = cl.get_string()
    except ..
      print('file too big?')
    end
    if r != 200
      print('get file failed ' .. r)
      var m = json.load(s)
      print('resp map ' .. m)
    end
    return s
  end
  
  # delete all files in the sevice root which are owned by the service account.
  # i.e. any which the user has 'deleted' from the folder
  ##### USE WITH CARE - DON'T USE IF YOU ARE NOT USING A SEVICE ACCOUNT
  def cleanservicefiles(confirm)
    # find all files which are owned by the service account, and in the root drive.
    # file in a user's folder are not in the root drive, unless deleted by the user.
    var resp = gdrive.readdir(nil, "%27me%27%20in%20owners%20and%20%27root%27%20in%20parents", "files(id,shared,name,kind,mimeType,parents,ownedByMe)")
    if resp.contains('files')
      var files = resp['files']
      var deleted = 0
      var total = 0
      for file:files
        print(file)
        if file['kind'] == 'drive#file'
          total = total + 1
          if !confirm
            print('would delete ' .. file['name'])
          else
            resp = gdrive.delete(file['id'])
            print('deleted ' .. file['name'])
            deleted = deleted + 1
          end
        else
          print(file['name'] .. ' not a file')
        end
      end
      print('deleted ' .. deleted .. 'files')
    else
      print('problem listing files')
    end
  end

end

# example
# var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
# var gdrive = google_drive(auth)
# var folder_id = "1evt2oAqN0xQ8mQOj8KYDUR4Om7QTrvna"
# var resp = gdrive.write(folder_id, 'mytestfile.txt', "text text or bytes")

