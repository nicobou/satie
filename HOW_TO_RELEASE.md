# How to make new releases

* Make sure `develop` branch reflects the desired `master`
* Increase the _version_ string in the .quark file
* Create a new entry in the NEWS.md file (top of the file) with version number, date and description of changes
* Commit and push, open a code review
* Merge via the web interface or CLI:
  `git checkout master && git merge --no-ff develop`
  then: `git tag -a vX.X.X -m"Short message that explains the new version"`
  `git push origin master --tags`

## Optional steps
If changes include changes to the OSC protocol, document your OSC messages in [SATIE OSC API](./SATIE-OSC-API.md). Make sure you have _pandoc_ installed:
`sudo apt install pandoc`

and run the following command from the root of the directory:
```pandoc -s --toc -c doc.css -f markdown -t html SATIE-OSC-API.md -o HelpSource/Examples/OSC-API.html```

You're done.
