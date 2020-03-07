# requires pyjwt (https://pyjwt.readthedocs.io/en/latest/)
# pip install pyjwt


import datetime
import jwt


secret = """-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg5KBPvisjPwfi+h4S
RRwo8m0/aL35Rq526qJncYeQ7begCgYIKoZIzj0DAQehRANCAATA90nuNcJV3GZK
AgXpOO/RFx5Mej398EMpjxutM5Z5JXSquufc7C6bmtbrmjef/j8Y6BuLmRvD1HeE
Z/tA+KhV
-----END PRIVATE KEY-----"""
keyId = "ZWTZ83FNQ6"
teamId = "PKK87S6JNY"
alg = 'ES256'

time_now = datetime.datetime.now()
time_expired = datetime.datetime.now() + datetime.timedelta(hours=12)

headers = {
    "alg": alg,
    "kid": keyId
}

payload = {
    "iss": teamId,
    "exp": int(time_expired.strftime("%s")),
    "iat": int(time_now.strftime("%s"))
}


if __name__ == "__main__":
    """Create an auth token"""
    token = jwt.encode(payload, secret, algorithm=alg, headers=headers)

    print "----TOKEN----"
    print token

    print "----CURL----"
    print "curl -v -H 'Authorization: Bearer %s' \"https://api.music.apple.com/v1/catalog/us/artists/36954\" " % (token)
