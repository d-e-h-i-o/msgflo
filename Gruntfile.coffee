module.exports = ->
  pkg = @file.readJSON 'package.json'
  # Project configuration
  @initConfig
    pkg: pkg

    # CoffeeScript compilation
    coffee:
      library:
        options:
          bare: true
        expand: true
        cwd: 'src'
        src: ['**.coffee']
        dest: 'lib'
        ext: '.js'
      utils:
        options:
          bare: true
        expand: true
        cwd: 'src/utils'
        src: ['**.coffee']
        dest: 'lib/utils'
        ext: '.js'

    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          grep: process.env.TESTS

    # Protocol tests
    shell:
      msgflo:
        command: 'node bin/msgflo'
        options:
          async: true
      fbp_test:
        command: 'fbp-test --colors'

    # Building the website
    jekyll:
      options:
        src: 'site/'
        dest: 'dist/'
        bundleExec: true
      dist:
        options:
          dest: 'dist/'
      serve:
        options:
          dest: 'dist/'
          serve: true
          watch: true
          host: process.env.HOSTNAME or 'localhost'
          port: process.env.PORT or 4000
    # Deploying the website
    'gh-pages':
      options:
        base: 'dist/',
        clone: 'gh-pages'
        message: "Release #{pkg.name} #{process.env.TRAVIS_TAG}"
        repo: 'https://' + process.env.GH_TOKEN + '@github.com/msgflo/msgflo.git'
        silent: true # Must be set to true when using GH_TOKEN
      src: '**/*'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-jekyll'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-shell-spawn'

  # For deploying
  @loadNpmTasks 'grunt-gh-pages'

  # Our local tasks
  @registerTask 'fbp-test', [
    'shell:msgflo'
    'shell:fbp_test'
    'shell:msgflo:kill'
  ]

  @registerTask 'test', 'Build and run automated tests', (target = 'all') =>
    @task.run 'coffee'
    @task.run 'mochaTest'
#    @task.run 'fbp-test'

  @registerTask 'default', ['test']

  @registerTask 'sitedeploy', [
    'jekyll:dist'
    'gh-pages'
  ]
