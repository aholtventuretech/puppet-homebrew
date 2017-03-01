Puppet::Type.type(:package).provide(:brewlink,
                                    :parent => :brewcommon,
                                    :source => :brewcommon) do
  desc 'Brew Link management using HomeBrew on OS X'

  has_feature :install_options

  def install
    name = @resource[:name].downcase

    Puppet.debug "Linking #{name}"
    output = execute([command(:brew), :link, '-f', '--overwrite', name, *install_options])

    if output =~ /Error: No such keg/
      raise Puppet::Error, "Could not find keg #{name}"
    end
  end

  def uninstall
    name = @resource[:name].downcase

    Puppet.debug "Unlinking #{name}"
    execute([command(:brew), :unlink, name])
  end

  def update
    uninstall
    install
  end

  def query
    nil
  end

  def self.instances
    []
  end
end
