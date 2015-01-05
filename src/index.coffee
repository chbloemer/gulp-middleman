{spawn} = require "child_process"
which = require("which").sync
gutil = require "gulp-util"
path = require "path"

PLUGIN_NAME = "gulp-middleman"

class Middleman
  constructor: (options) ->
    @options = options

  getCommand: ->
    if @options.useBundler then "bundle" else "middleman"

  getArguments: (subcommand) ->
    args = if @options.useBundler then ["exec", "middleman"] else []
    args.push subcommand
    args.push "--verbose" if @options.verbose
    args.concat if subcommand == "server" then @getServerOptions() else @getOptions()
    args

  getServerOptions: ->
    opts = []
    opts.push "--environment=#{@options.environment}" if @options.environment
    opts.push "--host=#{@options.host}" if @options.host
    opts.push "--port=#{@options.port}" if @options.port
    opts

  getOptions: ->
    opts = []
    opts.push "--clean" if @options.clean
    opts.push "--glob=#{@options.glob}" if @options.glob
    opts

module.exports =
  server: (options = {}) ->
    middleman = new Middleman options
    cmd = middleman.getCommand();
    pathSeparatorRe = /[\\\/]/g;
    try
      if (!pathSeparatorRe.test(cmd))
#         Only use which if cmd has no path component.
        cmd = which(cmd);
      else
      cmd = cmd.replace(pathSeparatorRe, path.sep);
    catch err
      console.log(err)

    console.log(cmd, middleman.getArguments("server"))
    child = spawn cmd, middleman.getArguments("server")
    child.stdout.pipe process.stdout
    child.stderr.pipe process.stderr
    process.stdin.on "end", ->
      child.stdin.end()
    child.stdout.on "end", ->
      process.stdin.end()

  build: (options = {}) ->
    middleman = new Middleman options
    cmd = middleman.getCommand();
    pathSeparatorRe = /[\\\/]/g;
    try
      if (!pathSeparatorRe.test(cmd))
#         Only use which if cmd has no path component.
        cmd = which(cmd);
      else
      cmd = cmd.replace(pathSeparatorRe, path.sep);
    catch err
      console.log(err)

    console.log(cmd, middleman.getArguments("build"))
    child = spawn cmd, middleman.getArguments("build")
    child.stdout.pipe process.stdout
    child.stderr.pipe process.stderr
    process.stdin.on "end", ->
      child.stdin.end()
    child.stdout.on "end", ->
      process.stdin.end()
