#!/usr/bin/env ruby
require 'optparse'

class Runner
  def initialize
    init_defaults
    parse_cli
    execute

  rescue ArgumentError
    puts $!
  rescue RuntimeError
    notify_fail
  end

  private

  def init_defaults
    @options = { notify: true, verbose: false, dry_run: false }
  end

  def execute
    notify_start
    run_command
    notify_end
  end

  def run_command
    command = build_command
    puts("Dry-run. Would run: \"#{command}\"") || return if @options[:dry_run]
    puts("Running: $ #{command}") if @options[:verbose]
    exec build_command
  end

  def build_command
    drop_output = ' > /dev/null 2>&1'
    verbose_expr = @options[:verbose] ? '' : "#{drop_output}"

    command = "bash -cil '#{escape_quotes!(@command)}'#{verbose_expr}"
    command = "sudo -su #{@options[:user]} #{escape_quotes!(command)}" if @options[:user]
    command = "ssh #{@options[:host]} $\"#{command}\"" if @options[:host]
    command
  end

  def notify_start
    notify "Command:#{@command} started running ..."
  end

  def notify_end
    notify "Command:#{@command} finished successfully ..."
  end

  def notify_fail
    notify "Command:#{@command} fail to run successfully ..."
  end

  def notify body
    return unless @options[:notify]

    title = 'Runner'
    apple_script = %Q{'display notification "#{body}" with title "#{title}"'}
    notify_command = "osascript -e #{apple_script}"
    exec(notify_command)
  end

  def parse_cli
    option_parser = OptionParser.new do |op|
      op.banner = "Usage: runner <cmd> [options]"
      op.separator ""
      op.separator "Options:"

      op.on('-h', '--host [HOST]', 'Host to run the command on (via ssh). [default: localhost]') { |h| @options[:host] = h }
      op.on('-u', '--as-user [USER]', 'Run command as specified user') { |u| @options[:user] = u }
      op.on('-n', '--[no-]notify', 'Send a native OS X notification') { |n| @options[:notify] = n }
      op.on('-v', '--[no-]verbose', 'Run verbosely') { |v| @options[:verbose] = v }
      op.on('-d', '--dry-run', 'Output the command but not execute it') { |d| @options[:dry_run] = d }
    end

    option_parser.parse!
    command_words = option_parser.order!
    raise ArgumentError.new(option_parser) if command_words.empty?
    @command = command_words.join(' ')
  end

  def exec cmd
    status = system(cmd)
    raise RuntimeError unless status
  end

  def escape_quotes! string
    string.gsub!(/['|"]/, /\\'/.source) || string
  end

end

Runner.new
