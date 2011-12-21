Finder
---------------


```javascript
finder = new Finder

filesToWatch = finder.in([
    directories.coffee,
    directories.stylus,
    directories.template
]).include([
    'coffee',
    'eco',
    'styl'
]).find()
```
