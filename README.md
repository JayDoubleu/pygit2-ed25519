# pygit2-ed25519
pygit2 container with ed25519 support

For some reason libgit2 does no longer like ssl with custom openssl. Use custom callback below if using https.
```
class NoCheckCertificate(pygit2.RemoteCallbacks):
     def __init__(self, credentials=None, certificate=None):
        super(self.__class__, self).__init__(credentials, certificate)
     def certificate_check(self, certificate, valid, host):
         return True

pygit2.clone_repository("https://github.com/user/sslrepo.git", "sslrepo.git", callbacks=NoCheckCertificate())
```
