class Array
  def place(a) Insertion.new(self, a) end
end

class Insertion
  def initialize(list, value) @list, @value = list, value end
  def before(val) insertion(val, 0) end
  def after(val) insertion(val, 1) end
  private
  def insertion(val, rel) 
    if index = @list.index(val)
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
      name = template_mod_name(path)

      remove_const(name) unless caching rescue NameError
      return const_get(name) rescue NameError
      
      exists = find_matching_template_paths(path)
      if exists.empty?
        raise ArgumentError, "no such template `#{path}'"
      end
      
      mod = create_template(path)
      const_set(name, mod) 
    end
    
    private

    def absolutize_path(*path)
      path = path.inject([]) do |p, s|
        s = s.to_s; s[0, 1] == '/' ? p = [s.gsub(/^\/+/, '')] : p << s
      end.join(File::SEPARATOR)
      File.expand_path(File.join(path))[(Dir.pwd.length+1)..-1]
    end
    
    def create_template(path)
      mod = Module.new
      mod.send(:include, Template)
      mod.path = path
      mod.template_paths = []
      
      path.split(File::SEPARATOR).inject([]) do |list, el|
        list << el
        total_list = File.join(list)
        find_matching_template_paths(total_list).each do |subpath|
          submod = create_template_mod(subpath, total_list)
          mod.send :include, submod
          #if total_list == path
            mod.template_paths.unshift(*submod.template_paths)
            #mod.sections = submod.sections
          #end
        end
        list
      end
      
      mod.template_paths.uniq!
      mod
    end
    
    def create_template_mod(full_path, path)
      name = 'Local'+template_mod_name(full_path)
      
      remove_const(name) unless caching rescue NameError
      return const_get(name) rescue NameError 

      mod = Module.new
      mod.send(:include, TemplatePath)
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
        mod.module_eval(File.read(setup_file).taint, __FILE__, __LINE__)
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