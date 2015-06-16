# modules
winston = require 'winston'
# config
logging = require '../config/logging'


logger = new winston.Logger transports: [
  new winston.transports.Console
  new winston.transports.File filename: logging.path, json: false
]

# export
module.exports = logger