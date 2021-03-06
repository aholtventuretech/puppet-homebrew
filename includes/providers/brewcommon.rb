require 'puppet/provider/package'

Puppet::Type.type(:package).provide(:brewcommon,
                                    :parent => Puppet::Provider::Package) do
  desc 'Base class for brew package management'

  confine :operatingsystem => :darwin

  # N.B. feature :install_options is not inheritable
  has_feature :installable, :install_options
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable

  commands :brew => '/usr/local/bin/brew'
  commands :stat => '/usr/bin/stat'

  def self.execute(cmd, failonfail = false, combine = false)
    owner = stat('-nf', '%Uu', '/usr/local/bin/brew').to_i
    group = stat('-nf', '%Ug', '/usr/local/bin/brew').to_i
    home  = Etc.getpwuid(owner).dir

    warn('Homebrew will be dropping support for root-owned homebrew by November 2016. Though this module will not prevent you from running homebrew as root, you may run into unexpected issues. Please migrate your installation to a user account -- this module will enforce this once homebrew has officially dropped support for root-owned installations.') if owner == 0

    super(cmd, :uid => owner, :gid => group, :combine => combine,
          :custom_environment => {'HOME' => home }, :failonfail => failonfail)

    # tries = 20
    # success = false
    # count = 0
    # result = nil
    # err = nil
    # begin
    #   result = super(cmd, :uid => owner, :gid => group, :combine => combine,
    #                  :custom_environment => {'HOME' => home }, :failonfail => failonfail)
    #   success = true
    # rescue Puppet::ExecutionFailure => e
    #   $stderr.puts "Homebrew execution failed. Trying again...(#{count += 1}/#{tries})"
    #   err = e
    #   $stderr.puts 'Clearing Homebrew Caches before trying again...'
    #   `find #{home}/Library/Caches/Homebrew -type f -print0 | xargs -0 rm --`
    #   `find #{home}/Library/Caches/Homebrew/Cask -type f -print0 | xargs -0 rm --`
    #   retry while count < tries
    # end
    #
    # unless success || !failonfail
    #   raise err
    # end
    #
    # return result
  end

  def execute(*args)
    # This does not return exit codes in puppet <3.4.0
    # See https://projects.puppetlabs.com/issues/2538
    self.class.execute(*args)
  end

  def install
    raise Puppet::ExecutionFailure, 'Use brew provider.'
  end

  def install_name
    name = @resource[:name].downcase
    should = @resource[:ensure].downcase

    case should
    when true, false, Symbol
      name
      else
      $stderr.puts "Name is #{name}"
      name + "-#{should}"
    end
  end

  def install_options
    Array(resource[:install_options]).flatten.compact
  end

  def uninstall
    raise Puppet::ExecutionFailure, 'Use brew provider.'
  end

  def update
    raise Puppet::ExecutionFailure, 'Use brew provider.'
  end

  def query
    self.class.package_list(:justme => resource[:name].downcase)
  end

  def latest
    hash = self.class.package_list(:justme => resource[:name].downcase)
    hash[:ensure]
  end

  def self.package_list(options={})
    raise Puppet::ExecutionFailure, 'Use brew provider.'
  end

  def self.name_version_split(line)
    raise Puppet::ExecutionFailure, 'Use brew provider.'
  end

  def self.instances(justme = false)
    package_list.collect { |hash| new(hash) }
  end

  def fix_checksum(files)
    begin
      for file in files
        File.delete(file)
      end
    rescue Errno::ENOENT
      Puppet.warning "Could not remove mismatched checksum files #{files}"
    end
    raise Puppet::ExecutionFailure, "Checksum error for package #{name} in files #{files}"
  end
end
