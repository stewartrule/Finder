Finder
---------------

### api ###


*	contains(substr)
*	pathContains(substr)
*	pathExcludes(substr)
*	lte(size, unit)
*	lt(size, unit)
*	gte(size, unit)
*	gt(size, unit)
*	in()
*	include()
*	exclude()
*	maxDepth(level)
*	filter(fn)
*	find(includeStats = false)
*	findStat(prop)
*	sizes(unit = 'bytes')
*	cTimes()
*	mTimes()


### example ###

```coffeescript
{Finder} = require './Finder'

finder = new Finder

search = finder.in([
    'Symfony'
]).maxDepth(2).include([
    'php'
])

files = search.find()

console.log files

###
[ 'Symfony/app/AppCache.php',
  'Symfony/app/AppKernel.php',
  'Symfony/app/autoload.php',
  'Symfony/app/check.php',
  'Symfony/vendor/symfony/vendors.php',
  'Symfony/web/app.php',
  'Symfony/web/app_dev.php',
  'Symfony/web/config.php' ]
###

sizes = search.sizes 'kb'

console.log sizes

###
{ 'Symfony/app/AppCache.php': 0.1376953125,
  'Symfony/app/AppKernel.php': 1.3798828125,
  'Symfony/app/autoload.php': 1.7978515625,
  'Symfony/app/check.php': 5.888671875,
  'Symfony/vendor/symfony/vendors.php': 1.40625,
  'Symfony/web/app.php': 0.3486328125,
  'Symfony/web/app_dev.php': 0.671875,
  'Symfony/web/config.php': 8.1748046875 }
###  
 
search.gte 1, 'kb'

res = search.sizes 'kb'

console.log res

###
{ 'Symfony/app/AppKernel.php': 1.3798828125,
  'Symfony/app/autoload.php': 1.7978515625,
  'Symfony/app/check.php': 5.888671875,
  'Symfony/vendor/symfony/vendors.php': 1.40625,
  'Symfony/web/config.php': 8.1748046875 }
###

search.pathContains 'vendor'

res = search.sizes 'kb'

console.log res

###
{ 'Symfony/vendor/symfony/vendors.php': 1.40625 }
###
```
