module GitChanged

  def changed?(*arguments)
    options = arguments.last.is_a?(Hash) ? arguments.pop : {}
    files   = Array(arguments).flatten

    application   = options[:application].to_sym
    revision      = options[:rev] || node.applications[application][:previous_revision] || 'HEAD^'
    changed_files = changed_files(revision, application)

    Chef::Log.debug("Running `changed?` for files #{files.inspect} with options: #{options.inspect}")
    Chef::Log.debug("Files changed in revision #{revision}: " + changed_files.inspect)

    files.select { |f| changed_files.any? { |a| a.to_s =~ Regexp.new(Regexp.escape(f)) }  }.size > 0
  end

  def current_revision_sha(application)
    application = application.to_sym
    `git --git-dir=#{node.applications[:dir]}/#{node.applications[application][:name]}/.git rev-parse HEAD`.strip
  end

  def changed_files(revision, application)
    `cd #{node.applications[:dir]}/#{node.applications[application][:name]}/ && git diff --name-only #{revision}`.split
  end
end
