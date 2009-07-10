class Array
  def place(a) Insertion.new(self, a) end
end

class Insertion
  def initialize(list, value) @list, @value = list, value end
  def before(val) insertion(val, 0) end
  def after(val, ignore_subsections = true) insertion(val, 1, ignore_subsections) end
  private
  def insertion(val, rel, ignore_subsections = true) 
    if index = @list.index(val)
      if ignore_subsections && rel == 1 && @list[index + 1].is_a?(Array)
        rel += 1
      end
      @list[index+rel,0] = @value 
    end
    @list
  end
end

module Tadpole
  class << self
    attr_accessor :caching
    
    def caching; @caching ||= true end
    
    def template_paths
      @@template_paths ||= []
    end
    
    def register_template_path(path)
      template_paths.push(path)
    end
    
    def template(*path)
      path = absolutize_path(*path)
      exists = find_matching_template_paths(path)
      raise ArgumentError, "no such template `#{path}'" if exists.empty?

      create_template(*path)
    end
    
    def create_template(*path)
      path = absolutize_path(*path)
      name = template_mod_name(path)

      remove_const(name) unless caching rescue NameError
      return const_get(name) rescue NameError

      mod = create_template_mod(path)
      const_set(name, mod) 
    end

    private

    def absolutize_path(*path)
      path = path.inject([]) do |p, s|
        s = s.to_s; s[0, 1] == '/' ? p = [s.gsub(/^\/+/, '')] : p << s
      end.join(File::SEPARATOR)
      File.expand_path(File.join(path))[(Dir.pwd.length+1)..-1]
    end
    
    def add_template_filters(mod)
      mod.before_run_filters = LocalTemplate.before_run_filters.dup
      mod.before_section_filters = LocalTemplate.before_section_filters.dup
    end
    
    def add_inherited_templates(mod, path)
      inherited = []
      path.split(File::SEPARATOR).inject([]) do |list, el|
        list << el
        total_list = File.join(list)
        find_matching_template_paths(total_list).each do |subpath|
          submod = create_local_template_mod(subpath, total_list)
          mod.send :include, submod
          mod.template_paths.unshift(*submod.template_paths)
          mod.before_run_filters.push(*submod.before_run_filters)
          mod.before_section_filters.push(*submod.before_section_filters)
          inherited.push(*submod.inherited_paths)
        end
        list
      end
      
      mod.template_paths.push(*inherited)
      mod.template_paths.uniq!
    end
    
    def create_template_mod(path)
      mod = Module.new
      mod.send(:include, Template)
      mod.path = path
      mod.template_paths = []

      add_template_filters(mod)
      add_inherited_templates(mod, path)

      mod
    end
    
    def create_local_template_mod(full_path, path)
      name = 'Local' + template_mod_name(full_path)
      
      remove_const(name) unless caching rescue NameError
      return const_get(name) rescue NameError 

      mod = Module.new
      mod.send(:include, LocalTemplate)
      mod.path = path
      mod.template_paths.unshift(full_path)
      load_setup_rb(full_path, mod)

      const_set(name, mod) 
    end
    
    def find_matching_template_paths(path)
      template_paths.map do |template_path|
        full_path = File.join(template_path, path)
        File.directory?(full_path) ? full_path : nil
      end.compact
    end
    
    def load_setup_rb(full_path, mod)
      setup_file = File.join(full_path, 'setup.rb')
      if File.file? setup_file
        mod.module_eval(File.read(setup_file).taint, setup_file)
      end
      mod
    end

    def template_mod_name(full_path)
      'Template_' + absolutize_path(full_path).gsub(File::SEPARATOR, '_')
    end
  end
end

def Tadpole(*path) Tadpole.template(*path) end
alias Template Tadpole