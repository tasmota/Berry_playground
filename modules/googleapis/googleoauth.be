import crypto
import json
import string

class google_oauth
  # extracted from google json key
  var private_key_DER
  var client_email

  # token scope requested
  var scope

  # we keep the access_token, and refresh if needed
  var access_token
  var refresh_time

  # constructor  
  def init(jsonname, scope)
    self.scope = scope
    self.refresh_time = 0
    self.readjson(jsonname)
  end
  
  # JWT requires base64url and not raw base64
  # see https://base64.guru/standards/base64url
  # input: string or bytes
  def base64url(v)
    import string
    if type(v) == 'string'   v = bytes().fromstring(v) end
    var b64 = v.tob64()
    # remove trailing padding
    b64 = string.tr(b64, '=', '')
    b64 = string.tr(b64, '+', '-')
    b64 = string.tr(b64, '/', '_')
    return b64
  end

  # internal - read google json key and ge tthe two fields we need.
  def readjson(filename)
    # this is the key file downloaded from the google cloud console, assigned to a service account.
    # we need private_key and client_email
    var f = open(filename,"r")
    var json_data = f.read()
    f.close()
    var key_map = json.load(json_data)
    # extract private key as bytes
    # split key into lines
    var private_key = key_map['private_key']
    while (private_key[-1] == '\n') private_key = private_key[0..-2] end
    
    # we need these each time we need a new key
    self.private_key_DER = bytes().fromb64(string.split(private_key, '\n')[1..-2].concat())
    self.client_email = key_map['client_email']
    #print(self.private_key_DER)
    #print(self.client_email)
  end
  
  # internal - creates the JWT with which we may request an OAuth access_token
  def create_google_jwt(duration)
    var time = tasmota.rtc()

    var header = '{"alg":"RS256","typ":"JWT"}'
    var claim = '{"iss":"' .. self.client_email .. '",' ..
        '"scope":"' .. self.scope .. '",' ..
        '"aud":"https://oauth2.googleapis.com/token",' ..
        '"exp":' .. (time['utc']+duration) .. ',' ..
        '"iat":' .. time['utc'] .. '}' 

    var b64header=self.base64url(header)
    var b64claim=self.base64url(claim)
    # this is the first part of the JWT, xxx.yyy
    var body = b64header .. '.' .. b64claim

    # sign body
    var body_b64 = bytes().fromstring(body)
    var sign = crypto.RSA.rs256(self.private_key_DER, body_b64)
    var b64sign = self.base64url(sign)
    var jwt_token = body + '.' + b64sign
    #print('created jwt')
    return jwt_token
  end

  # internal - called if we NEED a new access_token
  def get_oath_token(duration)
    var jwt = self.create_google_jwt(duration)
    #print('got jwt')
    var cl = webclient();
    #print('got cl')
    
    cl.begin('https://oauth2.googleapis.com/token')
    var payload = 
      '{"grant_type":"urn:ietf:params:oauth:grant-type:jwt-bearer",' ..
      '"assertion":"' .. jwt .. '"}'
    var r = cl.POST(payload)
    if r == 200
      var s = cl.get_string()
      #print(s)
      var jmap = json.load(s)
      jmap.remove('id_token')
      #print(jmap)
      self.access_token = jmap['access_token']
      var time = tasmota.rtc()
      self.refresh_time = time['utc'] + jmap['expires_in'] - 10
      print('got new access_token')
    else
      print('failed to get new access_token')
    end
  end

  # call this to add the Authorization header to the webclient call - after cl.begin
  # automatically gets a new token if required
  def add_access_key(client)
    var time = tasmota.rtc()
    if time['utc'] > self.refresh_time
      self.get_oath_token(3600) # 1 hour
    end
    client.add_header('Authorization', 'Bearer ' .. self.access_token)
  end
end

# example
# var auth = google_oauth("/google.json", "https://www.googleapis.com/auth/drive");
# var cl = webclient()
# cl.begin('https://www.googleapis.com/drive/v3/files')
# auth.add_access_key(cl)
# cl.GET()
# print(cl.get_string) # this will show an error, but not an auth error.

