module main

import vweb
import flag
import os
import log
import time
import term

const (
	// Log level (1:fatal, 2:error, 3:warn, 4:info, 5:debug) (default = 5:debug) | e.g. export V_LOG_LEVEL=3
	log_level = $env('V_LOG_LEVEL')
)

struct App {
	vweb.Context
}

fn logging(level log.Level, value string) {
	// get log level (default = 5:debug)
	log_level_local := if log_level.int() > 0 { log_level.int() } else { 5 }
	level_cli_text := match level {
		.fatal { term.red('FATAL') }
		.error { term.red('ERROR') }
		.warn { term.yellow('WARN ') }
		.info { term.white('INFO ') }
		.debug { term.blue('DEBUG') }
	}
	// print to stdout
	if int(level) <= log_level_local {
		println('${time.now().format_ss_micro()} [$level_cli_text] $value')
	}
	// print to stderr
	if int(level) <= int(log.Level.error) {
		eprintln('${time.now().format_ss_micro()} [$level_cli_text] $value')
	}
}

fn main() {
	// Handle arguments
	mut fp := flag.new_flag_parser(os.args)
	fp.description('
  Temp file registry by vlang.
  Log level is specified as Environment variable e.g. export V_LOG_LEVEL=3
  (1:fatal, 2:error, 3:warn, 4:info, 5:debug) (default = 5:debug)')
	args_port := fp.int('port', `p`, 8080, '[optional] port (default: 8080)')
	args_help := fp.bool('help', `h`, false, 'help')
	// args_file_expiration := fp.int('expiration', `e`, 10, '[optional] Default file expiration (minutes) (default: 10)')
	// args_max_file_size := fp.int('max-file-size', `m`, 1024, '[optional] Max file size (MB) (default: 1024)')
	
	// Valid required options.
	if args_help {
		println(fp.usage())
		return
	}
	
	// Start web application
	logging(log.Level.info, 'Start temp-file-registry-v')
	vweb.run(&App{}, args_port)
}

['/temp-file-registry-v/api/v1/upload'; post]
pub fn (mut app App) upload_endpoint() vweb.Result {
	logging(log.Level.info, app.req.str())
	key := app.form['key']
	file := app.files['file']
	logging(log.Level.info, 'key: ${key}')
	logging(log.Level.info, 'file: ${file.str()}')
	return app.ok("OK")
}
	
['/temp-file-registry-v/api/v1/download'; get]
pub fn (mut app App) download_endpoint() vweb.Result {
	logging(log.Level.info, app.req.str())
	key := app.query['key']
	delete := app.query['delete']
	logging(log.Level.info, 'key: ${key}')
	logging(log.Level.info, 'delete: ${delete}')
	return app.ok("OK")
}
