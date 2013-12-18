require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install do
  linkables = Dir.glob('*/**{.symlink}')

  skip_all = false
  overwrite_all = false
  backup_all = false

  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/').last.split('.symlink').last
    # Use dirname(__FILE), not `pwd` -- the former is where the rakefile
    # lives, the latter where it was invoked.
    fullfile = "#{File.dirname(__FILE__)}/#{linkable}"
    linkfile = "#{ENV["HOME"]}/.#{file}"

    if File.exists?(linkfile) 
      # FIXME: the targets_are_equal construction's one limitation is that
      # no backup is made of symlinks already pointing at the right
      # dotfiles/... item. So when `rake uninstall` removes stuff and
      # puts back backups, it might remove a symlink -- and not put back
      # its identical original, because it wasn't backed up at the time.

      targets_are_equal = false
      if File.symlink?(linkfile)
        target = `readlink #{linkfile}`.chomp
        targets_are_equal = (target == fullfile)
      end

      unless skip_all   || overwrite_all || 
             backup_all || targets_are_equal
        puts "File already exists: #{linkfile}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        when 's' then next
        end
      end
      if targets_are_equal
        puts ".#{file} already correct, skipping..."
        next
      end
      FileUtils.rm_rf(linkfile) if overwrite || overwrite_all
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    `ln -s "$PWD/#{linkable}" "#{linkfile}"`
  end
end

task :uninstall do

  Dir.glob('**/*.symlink').each do |linkable|

    file = linkable.split('/').last.split('.symlink').last
    linkfile = "#{ENV["HOME"]}/.#{file}"

    # Remove all symlinks created during installation
    if File.symlink?(linkfile)
      FileUtils.rm(linkfile)
    end
    
    # Replace any backups made during installation
    if File.exists?("#{ENV["HOME"]}/.#{file}.backup")
      `mv "$HOME/.#{file}.backup" "$HOME/.#{file}"` 
    end

  end
end

task :default => 'install'
