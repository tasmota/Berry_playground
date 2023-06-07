#load('/googleoath.be')
#load('/googledrive.be')

# load this file, then manually use 
# gtest.start()
# gtest.next()


# !!!!change to the folder id of a folder you shared with your service account...!!!!
# (or try one which has public write access??? maybe)
my_folder_id = "1evt2oAqN0xQ8mQOj8KYDUR4Om7QTrvna"


# routine to exercise gdrive features
class gdrivetest
  var foldermap
  var teststep

  def init()
    # only create a new gdrive class if we don't have one
    if !global.gdrive
      var driveauth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
      global.gdrive = google_drive(auth)
      print('created new gdrive class')
    else
      print('use existing gdrive class')
    end
    self.foldermap = {}
    self.teststep = 0
  end

  # recursively find a path through first parent
  # listfolders() should have been called to get the folders the service can see...
  def getpath(parents, s)
    if !parents || !size(parents)
      return ''
    end
    if !s
      s = ''
    end
    if self.foldermap.contains(parents[0])
      s = self.foldermap[parents[0]]['name'] .. '/' .. s
      if (self.foldermap[parents[0]]['parents'])
        s = self.getpath(self.foldermap[parents[0]]['parents'], s)
      end
    end
    return s
  end
  
  def listall()
    # list everything the service account can see.
    # this will include ALL files and folders
    var maxcount = 15
    print('listing first ' .. maxcount .. ' "files" that service can see')
    var count = 0
    var pageToken = nil
    var pageSize = 4
    while count < maxcount
      var resp = gdrive.readdir(nil, nil, "files(id,shared,name,kind,mimeType,parents,ownedByMe)", pageSize, pageToken)
      var files = resp['files']
      if !size(files)
        break
      end
      for file:files
        print(file)
        maxcount = maxcount - 1
        count = count + 1
        if file.contains('parents') && size(file['parents']) && file['mimeType'] != 'application/vnd.google-apps.folder'
          var path = self.getpath(file['parents'])
          print('file resolves to ' .. path .. file['name'])
        end
      end
      if resp.contains('nextPageToken')
        pageToken = resp['nextPageToken']
      else
        pageToken = nil
        break;
      end
    end
    print('' .. count .. ' files in service')
    if (pageToken)
      print('there are more files to see')
    end
  end

  def listfolders()
    # list folders the service account can see.
    var maxcount = 25
    print('listing first ' .. maxcount .. ' "folders" that service can see')
    var count = 0
    var pageToken = nil
    var pageSize = 4
    self.foldermap = {}
    while count < maxcount
      var resp = gdrive.readdir(nil, "mimeType%20=%20%27application/vnd.google-apps.folder%27", "files(id,shared,name,kind,mimeType,parents,ownedByMe)", pageSize, pageToken)
      var files = resp['files']
      if !size(files)
        break
      end
      for file:files
        print(file)
        var parents = nil
        if file.contains('parents')
          parents = file['parents']
        end
        self.foldermap[file['id']] = {'name':file['name'], 'parents':parents}
        maxcount = maxcount - 1
        count = count + 1
      end
      if resp.contains('nextPageToken')
        pageToken = resp['nextPageToken']
      else
        pageToken = nil
        break;
      end
    end
    print('' .. count .. ' folders in service')
    if (pageToken)
      print('there are more folders to see')
    end
    print('foldermap ' .. self.foldermap)
  end

  def mkdirtest(name)
    var newfolderid = gdrive.mkdir(my_folder_id, name)
    if newfolderid
      print('mkdir ' .. name .. ' success')
    end
  end
  
  def finddirtest(name)
    print('find folder id for ' .. name)
    var folders = gdrive.readdir(shared_folder_id, "name%20=%20%27" .. name .. "%27", "files(id)")
    print(folders)
    var id = nil
    if folders && folders['files']
      var files = folders['files']
      if size(files)
        id = files[0]['id']
        print('found folder ' .. name .. ' as ' .. id)
      end
    end
    return id
  end
    
  def start(n)
    if !n
      n = 0
    end
    self.teststep = n
    self.next()
  end
  
  def next()
    if self.teststep == 0
      self.mkdirtest('testfolder')
      print('you should now see testfolder in your google drive')
      print('note MORE THAN ONE CAN EXIST AT A TIME')
      self.teststep = 1
      return
    end
    if self.teststep == 1
      self.listfolders()
      self.teststep = 2
      return
    end
    if self.teststep == 2
      self.listall()
      self.teststep = 3
      return
    end
    if self.teststep == 3
      print('search for folder testfolder')
      var id = self.finddirtest('testfolder')
      if id
        print('write testfolder/mytestfile.txt')
        var resp = gdrive.write(id, 'mytestfile.txt', "text or bytes")
        print(resp)
        print('read folder testfolder')
        resp = gdrive.readdir(id)
        print(resp)
      end
      print('check your google drive for the new file testfolder/mytestfile.txt')
      self.teststep = 4
      return
    end
    if self.teststep == 4
      print('please delete the file testfolder/mytestfile.txt\nAnd then type gtest.clean()')
      self.teststep = 5
      return
    end

    self.teststep = 0
  end

  def clean(confirm)
    gdrive.cleanservicefiles(confirm)
    if !confirm
      print('if the files to be deleted look correct, use gtest.clean(true) to delete them')
      print('THIS WILL DELETE ALL UNUSED SERVICE OWNED FILES\n - YOU MAY WISH TO REVIEW THE CODE FIRST\n ONLY USE FOR SERVICE ACCOUNTS DEDICATED TO TASMOTA PURPOSE')
    end
  end
  
  
  # example
  #var resp = gdrive.write(folder_id, 'mytestfile.txt', "text text or bytes")
  #print(resp)

  #resp = gdrive.readdir(folder_id)

  #query terms and fields examples. NOT: it's not explicit, but you MUST use files() or files. for file fields
  #ref: https://developers.google.com/drive/api/guides/ref-search-terms#file_properties
  #resp = gdrive.readdir(nil, "sharedWithMe", "files(id,shared,name,kind,mimeType,parents,ownedByMe)")
  # query should be url encoded.
  #resp = gdrive.readdir(nil, "mimeType%20=%20%27application/vnd.google-apps.folder%27", "files(id,shared,name,kind,mimeType,parents,ownedByMe,owners)")
  #resp = gdrive.readdir(nil, "visibility='limited'", "files(id,shared,name,kind,mimeType,parents,ownedByMe)")
  #name = 'hello' is encoded as name+%3d+%27hello%27
  #works, but all except one file are mine anyway.
  #resp = gdrive.readdir(nil, "%27me%27%20in%20owners%20and%20%27root%27%20in%20parents", "files(id,shared,name,kind,mimeType,parents,ownedByMe,trashed)")
end

gtest = gdrivetest()

print('manually use\ngtest.start(), then gtest.next()\n or gtest.start(n) to run test n')
