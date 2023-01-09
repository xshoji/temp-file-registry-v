module main

import vweb
import flag
import os
import log
import time
import term
import net.http

const (
	// Log level (1:fatal, 2:error, 3:warn, 4:info, 5:debug) (default = 5:debug) | e.g. export V_LOG_LEVEL=3
	log_level = $env('V_LOG_LEVEL')
)

struct WebApp {
	vweb.Context
	file_expiration_minutes shared int
	max_file_size_mb        shared int
mut:
	file_registry_map shared map[string]FileRegistry
}

struct FileRegistry {
	key                     string
	file_expiration_minutes int
	expired_at              time.Time
	http_file               http.FileData
}

fn (f FileRegistry) str() string {
	return 'key:${f.key}, expired_at:${f.expired_at.format_ss_milli()}, http_file.content_type:${f.http_file.content_type}, http_file.filename:${f.http_file.filename}, http_file.data.bytes:${f.http_file.data.str().bytes().len}'
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
		else { '' } // never come here
	}
	// print to stdout
	if int(level) <= log_level_local {
		println('${time.now().format_ss_micro()} [${level_cli_text}] ${value}')
	}
	// print to stderr
	if int(level) <= int(log.Level.error) {
		eprintln('${time.now().format_ss_micro()} [${level_cli_text}] ${value}')
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
	args_file_expiration_minutes := fp.int('expiration', `e`, 10, '[optional] Default file expiration (minutes) (default: 10)')
	args_max_file_size_mb := fp.int('max-size', `m`, 1024, '[optional] Max file size (MB) (default: 1024)')

	if args_help {
		println(fp.usage())
		return
	}

	app := WebApp{
		file_expiration_minutes: args_file_expiration_minutes
		max_file_size_mb: args_max_file_size_mb
	}
	// Clean expired file
	spawn clean_expired_file(&app)
	// Start web application
	logging(log.Level.info, 'Start temp-file-registry-v')
	vweb.run(&app, args_port)
}

['/temp-file-registry-v/api/v1/upload'; post]
pub fn (mut app WebApp) upload_endpoint() vweb.Result {
	// logging(log.Level.info, app.req.str())
	key := app.form['key'] or {
		app.set_status(400, 'Invalid request.')
		return app.json({
			'message': 'Invalid request. key is required.'
		})
	}
	file := app.files['file'][0] or {
		app.set_status(400, 'Invalid request.')
		return app.json({
			'message': 'Invalid request. file is required.'
		})
	}
	mut default_file_expiration_minutes := 0
	rlock app.file_expiration_minutes {
		// Cannot cast app.file_expiration_minutes int to str directly. ( e.g. app.file_expiration_minutes.str() becomes 'a' )
		default_file_expiration_minutes = app.file_expiration_minutes
	}
	file_expiration_minutes := app.form['expiration-minutes'] or {
		default_file_expiration_minutes.str()
	}.int()
	lock app.file_registry_map {
		app.file_registry_map[key] = FileRegistry{
			key: key
			file_expiration_minutes: file_expiration_minutes
			expired_at: time.now().add(file_expiration_minutes * time.minute)
			http_file: file
		}
		logging(log.Level.info, '${app.file_registry_map[key].str()}')
		return app.json({
			'message': app.file_registry_map[key].str()
		})
	}
	return app.ok('')
}

['/temp-file-registry-v/api/v1/download'; get]
pub fn (mut app WebApp) download_endpoint() vweb.Result {
	logging(log.Level.info, app.req.str())
	key := app.query['key'] or {
		app.set_status(400, 'Invalid request.')
		return app.json({
			'message': 'Invalid request. key is required.'
		})
	}
	delete := app.query['delete'] or { 'false' }
	logging(log.Level.info, 'key: ${key}, delete: ${delete}')
	lock app.file_registry_map {
		file_registry := app.file_registry_map[key] or { return app.not_found() }
		if time.now() > file_registry.expired_at {
			app.file_registry_map.delete(key)
			return vweb.not_found()
		}
		app.send_response_to_client('application/octet-stream', file_registry.http_file.data)
		if delete == 'true' {
			logging(log.Level.info, 'delete = ${app.file_registry_map[key].str()}')
			app.file_registry_map.delete(key)
		}
	}
	return app.ok('')
}

fn clean_expired_file(app &WebApp) {
	for {
		time.sleep(time.minute * 1)
		lock app.file_registry_map {
			for key, file_registry in app.file_registry_map {
				if time.now() > file_registry.expired_at {
					logging(log.Level.info, 'delete = ${app.file_registry_map[key].str()}')
					app.file_registry_map.delete(key)
				}
			}
		}
	}
}
