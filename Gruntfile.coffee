module.exports = (grunt) ->

    grunt.initConfig
        coffee:
            compile:
                files:
                    'puzzle.js': 'puzzle.coffee'

        concat:
              default:
                  options:
                      process: (src, filepath) ->
                          if filepath != 'src/head.coffee' and filepath != 'src/tail.coffee'
                              lines = []
                              src.split('\n').forEach (line) ->
                                  lines.push( (if line.length > 0 then '    ' else '') + line)
                              src = lines.join('\n')
                              src[src.length-1] = '\n'if src[src.length-1] != '\n'
                          return src
                  src: [
                      'src/head.coffee',
                      'src/util.coffee',
                      'src/base.coffee',
                      'src/positional.coffee',
                      'src/ticker.coffee',
                      'src/game.coffee',
                      'src/renderer.coffee',
                      'src/canvasRenderer.coffee',
                      'src/controller.coffee',
                      'src/board.coffee',
                      'src/block.coffee',
                      'src/tail.coffee',
                  ]
                  dest: 'puzzle.coffee'


        execute: 
        	default:
        		src: ['run.js']

    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-execute')
    grunt.loadNpmTasks('grunt-contrib-concat')

    grunt.registerTask 'default', ['concat', 'coffee']
