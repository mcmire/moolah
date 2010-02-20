#gem 'mcmire-mocha'
#require 'mocha'
# This must be required before matchy since matchy patches
# the current test case's #run method, however mocha-protest-integration
# completely overrides it
#require 'mocha-protest-integration'