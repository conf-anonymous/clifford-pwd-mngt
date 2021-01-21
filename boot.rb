require 'prime'
require 'openssl'

Dir[Dir.pwd + "/initializers/*.rb"].each {|file| require file }
Dir[Dir.pwd + "/exceptions/*.rb"].each {|file| require file }

require Dir.pwd + "/app/tools"
require Dir.pwd + "/app/multivector3Dmod"
require Dir.pwd + "/app/password"
