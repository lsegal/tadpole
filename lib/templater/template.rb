require 'rubygems'

class Templater
  module Template
    module RenderMixin
      def erb(filename, locals = {})
        require 'erb'
        contents = template_contents(filename)
        p ERB.new(contents, nil, '<>').src
        ERB.new(contents, nil, '<>').result(locals_binding(locals))
      end

      def haml(filename, locals = {})
        require 'haml'
        contents = template_contents(filename)
        Haml::Engine.new(contents).render(self, locals)
      end

      def markaby()
      end
      
      def asset(filename)
        template_contents(filename)
      end

      def tpl(*section)
        if path.first == self
          section.shift
          Templater.create_template(*(path + section)).new.run(*args)
        else
          Templater.create_template(*path).new.run(*args)
        end
      end
      
      private
      
      def locals_binding(locals = {})
        instance_eval locals.map {|k,v| "#{k} = #{v.inspect}" }.join(";")
        binding
      end
    end
    
    module ClassMethods
      attr_accessor :path, :template_paths
      
      def run(*args)
        new(*args).run
      end
      
      def new
        obj = Object.new.extend(self)
        class << obj; extend ClassMethods end
        obj.instance_eval "def class; #{self} end"
        obj
      end
    end
    
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    attr_accessor :args

    include RenderMixin
    
    def template_paths; self.class.template_paths end
    def path; self.class.path end
    
    def sections(*sections)
      if sections.empty? 
        @sections 
      else
        @sections = [sections].flatten
      end
    end
    
    def init(*args) self.args = args end

    def run(*args)
      self.args = args
      init(*args)
      sections.map do |section|
        run_section(section)
      end.join
    rescue => e
      me = NoMethodError.new("In #{self.inspect}: #{e.message}")
      me.set_backtrace(e.backtrace)
      raise me
    end
    
    def run_section(section)
      #puts "#{self.inspect} Running section #{section} #{self.class.ancestors.inspect}"
      case section
      when String
        section
      when Symbol
        if respond_to? section
          send(section)
        else
          Templater.create_template(*(path + [section])).new.run(*args)
        end
      when Template
        section.run(*args)
      when Module
        section.new.run(*args)
      else
        raise ArgumentError, "invalid section #{section.inspect}"
      end
    end

    def inspect; "#<Template:0x#{object_id.to_s(16)} path='#{self.path.join('/')}' sections=#{sections.inspect}>" end
    
    private
    
    def find_template(filename)
      template_paths.each do |template_path|
        file = File.join(template_path, filename)
        return file if File.file? file
      end
      nil
    end
    
    def template_contents(filename)
      if file = find_template(filename)
        File.read(file)
      else
        raise ArgumentError, "missing template file `#{filename}' in #{self.inspect}"
      end
    end
  end
  
  module TemplatePath
    module ClassMethods
      def template_paths; @template_paths ||= [] end
      
      def inherits(*templates)
        if templates.first.is_a?(Symbol) || templates.first.is_a?(String)
          mod = Templater.create_template(*templates)
          include mod
          template_paths.push(*mod.template_paths)
        else
          include(*templates)
        end
      end
    end
    
    def self.included(klass)
      klass.extend ClassMethods
    end
  end

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
          end
        end
        list
      end
      
      Templater.caching ? const_set(name, mod) : mod
    end
    
    private
    
    def create_template_mod(full_path)
      name = template_mod_name(full_path)
      return const_get(name) if Templater.cache rescue NameError
      mod = Module.new
      mod.send(:include, TemplatePath)
      mod.template_paths.push(full_path)
      Templater.cache ? const_set(name, mod) : mod
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
