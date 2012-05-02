WISEPDF_PATH = File.dirname(__FILE__) + "/wisepdf/"

require WISEPDF_PATH + 'errors'
require WISEPDF_PATH + 'configuration'
require WISEPDF_PATH + 'parser'
require WISEPDF_PATH + 'writer'
require WISEPDF_PATH + 'helper'
require WISEPDF_PATH + 'render'
require WISEPDF_PATH + 'rails' if defined?(Rails)

module Wisepdf; end