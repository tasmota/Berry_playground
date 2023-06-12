import path

def zap(folder, diag)
  if !folder || folder == '/'
    print('refusing to zap root')
    return false
  end  
  if folder == '/sd' || folder == '/sd/'
    print('refusing to zap sd root')
    return false
  end  
  if diag print('zap '+folder) end
  if folder[-1] == '/'
    if diag print('remove trailing slash '+folder) end
    folder = folder[0..-2]
  end
  if path.exists(folder)
    
    var files = path.listdir(folder)
    if !size(files)
      if diag print(folder..' is empty') end
    end
    
    for f:files
      if !path.remove(folder .. '/' .. f)
        zap(folder .. '/' .. f)
      else
        if diag print('deleted file '..folder .. '/' .. f) end
      end
    end
    if !path.rmdir(folder)
      if diag print('failed to remove '..folder) end
    else
      if diag print('removed '..folder) end
    end
  else
    if diag print('folder '..folder ..' does not exist') end
  end
end


