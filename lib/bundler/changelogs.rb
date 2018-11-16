# frozen_string_literal: true
require 'stringio'
require 'pathname'
require 'bundler/changelogs/version'

module Bundler
  module Changelogs
    class Command
      Plugin::API.command('changelogs', self)
      attr_accessor :current_lockfile_parsed
      attr_accessor :previous_lockfile_parsed

      def exec(_name, args)
        if args.any?
          Bundler.require(:default, *args.map!(&:to_sym))
        else
          Bundler.require
        end

        current_lockfile = '.changelogs_gems.locked'
        previous_lockfile_content = `git show #{Bundler.settings[:changlog_commit] || "HEAD"}:#{current_lockfile}`

        #  Justification for not using gems.locked
        #   
        #TODO: need a callback in lifecycle to ensure non-git-managed-locks populate a git-managed file
        #cp Gemfile.lock .changelogs_gems.locked

        self.current_lockfile_parsed = Bundler::LockfileParser.new(Bundler.read_file(current_lockfile))
        self.previous_lockfile_parsed = Bundler::LockfileParser.new(previous_lockfile_content)

        ARGV.clear
        gems = get_gems_with_changelogs
        if gems.empty?
          Bundler.ui.error("Up to date. Nothing to show. Or: you already commmited the bundle changes to git? You can specify a range of git commits like this: TODO")
          return
        end

        io = StringIO.new
        write_changelog_output!(gems,io)
        io.rewind

        changelog_output_path = Bundler.settings[:changelog_output_path] 
        if changelog_output_path 
          path = Pathname.new(changelog_output_path)
          path.open("w+"){|f| f.puts(io.read) }

          #TODO: how to get CWD, crossplatform? Then, remove this verbosity.
          #TODO: other than error...
          Bundler.ui.info("Changelogs written to: #{path}")
        else
          Bundler.ui.info(io.read)
        end
      
      end

      require 'pry'
      private

      def gems_excluding_bundler_plugins
        current_lockfile_parsed.dependencies.map do |token, dep|
          #TODO: next if dep is a plugin

          #don't bother showing changelogs unless it's a named gemfile AND it's an update (we shouldn't care about whole new named gems.)
          next unless previous_lockfile_parsed.dependencies[token]

          token
        end.compact
      end

      def get_gems_with_changelogs
        gems = []
        for name in gems_excluding_bundler_plugins
          require name
          gem_obj = get_constant(name)
          if gem_obj[:changelog]
            #TODO: filter changelog string.
            #applicable_changelog_text = ...
            #if applicable_changelog_text.to_s.length > 0
            gems << gem_obj
            #end
          else
            Bundler.ui.error("Skipping #{name}. Found gem, but no changelog is formally specified. But you can poke around yourself: TODO, path to repo for #{name}.")
          end
        end
        gems 
      rescue LoadError
        Bundler.ui.error("Skipping #{name}. Couldn't load gem and therefore could not find a changlog.")
      end

      def write_changelog_output!(gems,io)
        for gem_obj in gems
          #TODO: if gem_obj is a simpledelegate, just ask for the precomputed diff
          io.puts(gem[:changelog])
        end
        nil
      end


      def get_constant(name)
        Object.const_get(name)
      rescue NameError
        Bundler.ui.error("Could not find constant #{name}")
        exit 1
      end
    end
  end
end
