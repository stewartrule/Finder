# requires
fs = require 'fs'
path = require 'path'

class Finder
	constructor: () ->

		@filters = []
		@includes = []
		@excludes = []
		@maxDepthLevel = false
		@directories = []

		# only include files with these type of extensions
		@filter (file) ->
			return true unless @includes.length
			return true if @_hasAnyExtension file, @includes
			false

		# exclude files with these type of extensions
		@filter (file) ->
			return true unless @excludes.length
			return false if @_hasAnyExtension file, @excludes
			true

	# only include files that contain a particular substring in the basename
	contains: (substr) ->
		@filter (file) ->
			base = path.basename file
			if base.indexOf(substr) > -1
				return true
			false
		@

	# only include files that contain a particular substring in their path
	pathContains: (substr) ->
		@filter (file) ->
			folderPath = path.dirname file
			if folderPath.indexOf(substr) > -1
				return true
			false
		@
	
	pathExcludes: (substr) ->
		@filter (file) ->
			folderPath = path.dirname file
			if folderPath.indexOf(substr) > -1
				return false
			true
		@

	# return size in bytes, kb, mb or gb
	_getUnitSize: (size,unit='bytes') ->
		switch unit
			when 'gb'
				unitSize = size / 1024 / 1024 / 1024
			when 'mb'
				unitSize = size / 1024 / 1024
			when 'kb'
				unitSize = size / 1024
			else
				unitSize = size
		unitSize

	# check filesize against a comparator function
	_compareSize: (unit,comparator) ->
		@filter (file) ->
			stats = fs.statSync file
			unitSize = @_getUnitSize stats.size, unit
			comparator.apply comparator, [unitSize]

	# lower then or equals size
	lte: (size,unit) ->
		@_compareSize unit, (unitSize) -> unitSize <= size

	# lower then size
	lt: (size,unit) ->
		@_compareSize unit, (unitSize) -> unitSize < size

	# greater then or equals size
	gte: (size,unit) ->
		@_compareSize unit, (unitSize) -> unitSize >= size

	# greater then size
	gt: (size,unit) ->
		@_compareSize unit, (unitSize) -> unitSize > size

	# add directories to search in
	in: (directories...) ->
		@directories = @_flatten @directories, directories
		@

	# make sure there is exactly 1 dot before the extension
	_sanitizeExtensions: (extensions) ->
		for extension,key in extensions
			extension = '.' + extension.replace /\.+/g, ''
			extensions[key] = extension
		extensions

	# only include files with these type of extensions
	include: (extensions...) ->
		@includes = @_flatten @includes, extensions
		@includes = @_sanitizeExtensions @includes
		@

	# exclude files with these type of extensions
	exclude: (extensions...) ->
		@excludes = @_flatten @excludes, extensions
		@excludes = @_sanitizeExtensions @excludes
		@

	# only go this many levels deep within the folder structure
	maxDepth: (level) ->
		@maxDepthLevel = parseInt level, 10
		@

	# add custom filters
	filter: (fn) ->
		if typeof fn is 'function'
			@filters.push fn
		@

	# include stats in the resultset
	_includeStats: (files) ->
		statFiles = {}
		for file,key in files
			stats = fs.statSync file
			stats.file = file
			statFiles[file] = stats
		statFiles

	# find files with the current settings
	find: (includeStats=false) ->
		files = []
		for directory in @directories
			res = @_readDir directory, 0
			files = files.concat res
		files = @_filterFiles files
		if includeStats
			files = @_includeStats files
		files

	# flatten nested structures
	_flatten: (arr,args) ->
		for arg in args
			if Array.isArray arg
				@_flatten arr, arg
			else
				arr.push arg
		arr

	# perform multiple checks against a certain file
	_applyFilters: (file) ->
		for filter in @filters
			unless filter.apply @, [file]
				return false
		true

	# walk through all files and run filters against them
	_filterFiles: (unfiltered) ->
		filtered = []
		for file in unfiltered
			if @_applyFilters file
				filtered.push file
		filtered

	# check if a file has a particular extension
	_hasExtension: (fileName,expectedExtension) ->
		base = path.basename fileName
		extension = path.extname base
		extension is expectedExtension

	# check if a file has one of the specified extensions
	_hasAnyExtension: (fileName,extensions) ->
		for extension in extensions
			if @_hasExtension fileName, extension
				return true
		false

	# read files from a folder recursively
	_readDir: (dir,depth) ->
		nextDepth = depth + 1
		if path.existsSync dir
			files = fs.readdirSync dir
			results = []
			for file in files
				file = dir + '/' + file
				if path.existsSync file
					stats = fs.statSync file
					if stats 
						if stats.isDirectory()
							unless @maxDepthLevel and nextDepth > @maxDepthLevel
								res = @_readDir file, nextDepth
								results = results.concat res
						else if stats.isFile()
							results.push file
			return results
		else
			console.log "path '#{dir}' does not exist"
		[]

	findStat: (prop) ->
		statsFiles = @find(true)
		files = {}
		for file, stats of statsFiles
			files[file] = stats[prop]
		files

	sizes: (unit='bytes') ->
		files = @findStat 'size'
		for file, size of files
			files[file] = @_getUnitSize size, unit
		files

	cTimes: ->
		@findStat 'ctime'

	mTimes: ->
		@findStat 'mtime'

exports.Finder = Finder