# How to make new releases

* Make sure `develop` branch reflects the desired `master`
* Increase the _version_ string in the .quark file
* Commit and push, open a code review
* Merge via the web interface or CLI:
  `git checkout master && git merge --no-ff develop`
  then: `git tag -a vX.X.X -m"Short message that explains the new version"`
  `git push origin master --tags`

You're done.
