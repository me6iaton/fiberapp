gulp       = require 'gulp'
watch      = require 'gulp-watch'
plumber    = require 'gulp-plumber'
livereload = require 'gulp-livereload'

paths =
	scripts: './lib/**/*.coffee'

#gulp.task "scripts", ->
#	gulp.src paths.scripts
#	.pipe livereload()

# watch for changes
gulp.task "watch", ->
	server = livereload()
	gulp.watch(paths.scripts).on 'change', (file) ->
		server.changed(file.path)


# default task
gulp.task "default", ['watch']
