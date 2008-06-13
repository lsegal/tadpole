require 'ostruct'

class OpenHashStruct < OpenStruct
  def [](key)  send(key.to_s) end
  def []=(k,v) send(key.to_s+'=', v) end
  def to_hash; @table.dup end
end

module Tadpole
  module Template
    module ClassMethods
      attr_accessor :path, :template_paths, :sections
      
      def run(*args, &block)
        new(*args).run(&block)
      end
      
      def new(opts = {}, &block)
        obj = Object.new.extend(self)
        class << obj; extend ClassMethods end
        obj.instance_eval("def class; #{self} end", __FILE__, __LINE__)
        obj.send(:initialize, opts, &block)
        obj
      end
    end
    
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    attr_accessor :options
    attr_accessor :current_section, :subsections
    
    def options; @options ||= OpenHashStruct.new end
    
    def options=(hash) 
      if hash.is_a?(OpenStruct)
        @options = hash
      else
        @options = OpenHashStruct.new(hash) 
      end
    end
    
    def method_missing(meth, *args, &block)
      if options.respond_to?(meth)
        options[meth]
      elsif meth.to_s =~ /=$/ && options.has_key?(meth.to_s.gsub(/=$/, ''))
        options[meth] = *args
      else
        super
      end
    end

    def template_paths; self.class.template_paths end
    def path; self.class.path end

    def sections(*new_sections)
      new_sections.compact!
      if new_sections.empty? 
        @sections 
      elsif new_sections.size == 1 && new_sections.first.is_a?(Array)
        @sections = new_sections.first
      else
        @sections = new_sections
      end
    end
    
    def compile_sections(list = sections)
      return unless Array === list
      list.map do |section|
        case section
        when Array
          compile_sections(section)
        when String, Symbol
          if respond_to?(section)
            section
          else
            find_section_provider(section)
          end
        when Module
          section.new(options)
        else
          section
        end
      end
    end
    
    def initialize(opts = {}, &block)
      @options = opts
      @providers = {}
      #self.sections(*sections)
      
      init(&block)

      if Tadpole.caching
        @compiled_sections = compile_sections(sections) 
      end
    end
    
    def init; end

    def run(opts = {}, &block)
      old_opts = options
      self.options = options.to_hash.update(opts)
      out = run_sections(@compiled_sections || sections, &block)
      self.options = old_opts
      out
    rescue => e
      me = NoMethodError.new("In #{self.inspect}: #{e.message}")
      me.set_backtrace(e.backtrace)
      raise me
    end
    alias to_s run
    
    def run_sections(sects, break_first = false, &block)
      out = ''
      sects = sects.first if sects.first.is_a?(Array)
      sects.each_with_index do |section, i|
        (break_first ? break : next) if section.is_a?(Array)
        
        self.current_section = section

        if sects[i+1].is_a?(Array)
          out += run_subsections(section, sects[i+1], &block)
        else
          out += render(section, &block)
        end
        
        break if break_first
      end
      out
    end
    
    def run_subsections(section, subsections, &block)
      self.subsections = subsections.reject {|s| Array === s }
      list = subsections.dup

      render(section) do
        if list.empty?
          raise LocalJumpError, "Section `#{section}' yielded with no sub-section given."
        end
        
        data = run_sections(list, true, &block) 
        list.shift; list.shift if list.first.is_a?(Array)
        data
      end
    end
    
    def all_sections(&block)
      subsections.each do |s|
        yield(s) 
      end
    end
    
    def yieldall; subsections.map {|s| render(s) }.join end
    
    def render(section, locals = {}, &block)
      case section
      when String, Symbol
        if respond_to? section
          send(section, &block)
        else
          find_section_provider(section).render(locals, &block)
        end
      when Template
        section.run(locals, &block)
      when Module
        section.new(options).run(locals, &block)
      when SectionProviders::SectionProvider
        section.render(locals, &block)
      else
        raise ArgumentError, "invalid section #{section.inspect}"
      end
    end

    def inspect
      "#<Template:0x%s path='%s' sections=%s%s>" % [object_id.to_s(16), 
        path, sections.inspect, @compiled_sections ? ' (compiled)' : ''] 
    end
    
    private
    
    def find_section_provider(section)
      section = section.to_s
      @providers ||= {}
      return @providers[section] if @providers[section]
      
      filename, provider = nil, nil
      template_paths.each do |template_path|
        SectionProviders.providers.each do |prov|
          filename = prov.provides?(File.join(template_path, section))
          break provider = prov if filename
        end
        break if provider && filename
      end
      
      raise ArgumentError, "missing section `#{section}'" if !provider 
      @providers[section] = provider.new(filename, self)
    end
    
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
end
