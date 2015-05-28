#!/usr/bin/env ruby
# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2015

This file is part of Smuxi hooks API for Ruby.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
=end

require 'god_object/smuxi_hooks'

class ChatLogger < GodObject::SmuxiHooks::Plugin

  LOG_FILE = Pathname.new('/tmp/smuxi_message_log')

  def message_received
    LOG_FILE.open('a') do |io|
      io.puts("#@sender: #@message (#@protocol_manager_network #@chat_name)")
    end
  end

  alias message_sent message_received

end

ChatLogger.execute(__FILE__) if __FILE__ == $PROGRAM_NAME
