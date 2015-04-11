module.exports = (grunt) ->

    grunt.initConfig
        coffee:
            compile:
                files:
                    'main.js': 'src/*.coffee'

        execute: 
        	default:
        		src: ['run.js']


    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-execute')

    grunt.registerTask 'default', ['coffee', 'execute']
