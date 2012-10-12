class Doubleshot::CLI::Commands::Gem < Doubleshot::CLI

  def self.summary
    <<-EOS.margin
      Package your project as a Rubygem, bundling any
      JAR dependencies and Java classes in with the distribution.
    EOS
  end

  def self.options
    Options.new do |options|
      options.banner = "Usage: doubleshot gem"
      options.separator ""
      options.separator "Options"

      options.test = true
      options.on "--no-test", "Disable testing as a build prerequisite." do
        options.test = false
      end

      options.separator ""
      options.separator "Summary: #{summary}"
    end
  end

  def self.start(args)
    options = self.options.parse!(args)
    doubleshot = Doubleshot::current

    Doubleshot::CLI::Commands::Build.start([])

    unless Pathname::glob(doubleshot.config.source.java + "**/*.java").empty?
      target = doubleshot.config.target

      jarfile = (target + "#{doubleshot.config.project}.jar")
      jarfile.delete if jarfile.exist?

      ant.jar jarfile: jarfile, basedir: target do
        doubleshot.lockfile.jars.each do |jar|
          puts jar.path.expand_path
          ant.zipfileset src: jar.path.expand_path, excludes: "META-INF/*.SF"
        end
      end
    end

    # WARN: This is version specific since in HEAD they've changed this to Gem::Package::build.
    ::Gem::Builder.new(doubleshot.config.gemspec).build

    return 0
  end
end