#!/usr/bin/env ruby

# noinspection RubyResolve
class HomebrewProviders
  def load_providers
    current_dir = File.expand_path(File.dirname(__FILE__))

    require "#{current_dir}/../../../../includes/providers/brewcommon"
    require "#{current_dir}/../../../../includes/providers/brew"
    require "#{current_dir}/../../../../includes/providers/brewcask"
    require "#{current_dir}/../../../../includes/providers/brewlink"
    require "#{current_dir}/../../../../includes/providers/homebrew"
    require "#{current_dir}/../../../../includes/providers/tap"
  end
end

HomebrewProviders.new.load_providers