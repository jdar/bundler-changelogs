# frozen_string_literal: true
require 'stringio'
require 'pathname'
require 'fileutils'
require 'bundler/changelogs/version'
require 'open-uri'

module Bundler
  module Changelogs
    class Command
      Plugin::API.command('changelogs', self)
      attr_accessor :current_lockfile_parsed
      attr_accessor :previous_lockfile_parsed

      GIT_MANAGED_LOCK_FILE = '.changelogs_gems.locked'

      #  Justification for not using gems.locked
      #  need a callback in lifecycle to ensure non-git-managed-locks populate a git-managed file
      ::Bundler::Plugin.add_hook('after-install-all') do |dependencies|
        FileUtils.cp Bundler.default_lockfile, GIT_MANAGED_LOCK_FILE
      end

      def exec(_name, args)
        if args.any?
          Bundler.require(:default, *args.map!(&:to_sym))
        else
          Bundler.require
        end

        current_lockfile = GIT_MANAGED_LOCK_FILE
        previous_lockfile_content = `git show #{Bundler.settings[:changlog_commit] || "HEAD"}:#{current_lockfile}`

        self.current_lockfile_parsed = Bundler::LockfileParser.new(Bundler.read_file(current_lockfile))
        self.previous_lockfile_parsed = Bundler::LockfileParser.new(previous_lockfile_content)

        ARGV.clear
        specs = get_changelogs
        binding.pry
        if specs.empty?
          Bundler.ui.error("Up to date. Nothing to show. Or: you already commmited the bundle changes to git? You can specify a range of git commits like this: TODO")
          return
        end

        io = StringIO.new
        write_changelog_output!(specs,io)
        io.rewind

        changelog_output_path = Bundler.settings[:changelog_output_path] 
        if changelog_output_path 
          path = Pathname.new(changelog_output_path)
          path.open("w+"){|f| f.puts io.read }

          #TODO: how to get CWD, crossplatform? Then, remove this verbosity.
          #TODO: other than error...
          Bundler.ui.info("Changelogs written to: #{path}")
        else
          binding.pry
          Bundler.ui.info(io.read)
        end
      
      end

      private

      def materialized_specs_excluding_bundler_plugins
        lookup_current_spec = current_lockfile_parsed.specs.inject({}) {|acc,s| acc.merge(s.name=>s)}
        lookup_previous_spec = current_lockfile_parsed.specs.inject({}) {|acc,s| acc.merge(s.name=>s)}

        current_lockfile_parsed.dependencies.map do |token, dep|
          next unless lookup_previous_spec[token] 
          #^^ check spec instead of deps, since some gems are merely switches of wrappers.
          next if lookup_current_spec[token].version.to_s == lookup_previous_spec[token].version.to_s


          #TODO: next if dep is a plugin

          previous_spec = lookup_previous_spec[token]  #use the previous spec, since it has the version number
          spec.__materialize__
          spec
        end.compact
      end

      def attempt_to_filter_changelog(previous_spec)
        Bundler.ui.info("Getting #{previous_spec.name} changelog_uri")
        content = open(previous_spec.metadata['changelog_uri'])

        new_hotness,old_hotness = try_split(content,previous_spec)
        post_process(new_hotness)
      end

      #dumb strategy. seems to fit ruby conventions?
      def try_split(content,previous_spec)
        dumb_tokenizer_token = previous_spec.version.to_s
        first,*last = content.split(dumb_tokenizer_token)
        [first,last.join(dumb_tokenizer_token)]
      end
      #dumb cleaning. seems to fit ruby conventions?
      def post_process(content)
        content = content.dup
        content.gsub!(/^\s*changelog[^\w]+/)
        content
      end

      def get_changelogs
        specs = []
        for previous_spec in materialized_specs_excluding_bundler_plugins
          if previous_spec.metadata['changelog_uri']
            applicable_changelog_text = attempt_to_filter_changelog(previous_spec)
            if applicable_changelog_text.to_s.length > 0
              specs << previous_spec 
            end
          else
            Bundler.ui.error("Skipping #{previous_spec.name}. Found gem, but no changelog is formally specified. But you can poke around yourself: TODO, path to repo for #{previous_spec.name}.")
          end
        end
        specs 
      end

      def write_changelog_output!(specs,io)
        for spec_obj in specs
          io.puts(spec_obj.metadata[:changelog])
        end
        nil
      end

    end
  end
end
