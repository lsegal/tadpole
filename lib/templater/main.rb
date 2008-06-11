class Array
  def insert_before(a, b) self[index(a), 0] = b end
  def insert_after(a, b) self[index(a)+1, 0] = b end
end

module Templater
  class << self
    attr_accessor :caching
    
    def cache; @caching ||= true end
    
    def template_paths
      @@template_paths ||= []
    end
    
    def register_template_path(path)
      template_paths.push(path)
    end
    
    def create_template(*path)
      if path.size == 1 && path.first.is_a?(String)
        path = path.first.split('/')
      end
      name = template_class_name(*path)
      return const_get(name) if Templater.cache rescue NameError
      
      exists = find_matching_template_paths(*path)
      if exists.empty?
        raise ArgumentError, "no such template `#{path.join(File::SEPARATOR)}'"
      end
      
      mod = Module.new
      mod.send(:include, Template)
      mod.path = path
      
      path = path.flatten
      path.inject([]) do |list, el|
        list << el
        find_matching_template_paths(*list).each do |subpath|
          submod = load_setup_rb(subpath)
          mod.send :include, submod
          if list == path
            mod.template_paths = submod.template_paths
            #mod.sections = submod.sections
          end
        end
        list
      end
      
      Templater.caching ? const_set(name, mod) : mod
    end
    
    private
    
    def create_template_mod(full_path)
      name = template_mod_name(full_path)
      return const_get(name) if Templater.caching rescue NameError
      mod = Module.new
      mod.send(:include, TemplatePath)
      mod.template_paths.push(full_path)
      Templater.caching ? const_set(name, mod) : mod
    end
    
    def find_matching_template_paths(*path)
      path = path.flatten.join(File::SEPARATOR)
      template_paths.map do |template_path|
        full_path = File.join(template_path, path)
        File.directory?(full_path) ? full_path : nil
      end.compact
    end
    
    def load_setup_rb(full_path, mod = nil)
      mod = create_template_mod(full_path) unless mod 
      
      setup_file = File.join(full_path, 'setup.rb')
      if File.file? setup_file
        mod.module_eval File.read(setup_file).taint
      end
      mod
    end

    def template_mod_name(full_path)
      'Template_' + full_path.split(/\/+/).map {|p| p =~ /^\.{1,2}$/ ? '' : p }.compact.join('_')
    end
    
    def template_class_name(*path)
      'Template_' + path.join('_')
    end
  end
end

def T(*path) Templater.create_template(*path) end