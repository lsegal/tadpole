require 'ostruct'

class OpenHashStruct < OpenStruct
  def [](key)  send(key.to_s) end
  def []=(k,v) send(key.to_s+'=', v) end
  def to_hash; @table.dup end
  alias has_key? respond_to?
end

if RUBY_VERSION < "1.9"
  class Hash
    def key(value)
      each {|k, v| return k if v == value }
    end
  end
end

module Tadpole
  module Template
    class MissingSectionError < Exception; end
    
    module ClassMethods
      attr_accessor :path, :template_paths, :sections
      attr_accessor :before_run_filters, :before_section_filters
      
      def run(*args, &block)
        new(*args).run(&block)
      end
      
      def new(opts = {}, &block)
        obj = Object.new.extend(self)
        class << obj; 
          extend ClassMethods 
          include Filters::InstanceMethods
        end
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
      self.options = opts
      @providers = {}
      
      if Tadpole.caching
        @compiled_sections = compile_sections(sections) 
      end
    end
    
    def init; end

    def run(opts = {}, &block)
      return '' if run_before_run.is_a?(FalseClass)

      with_options(opts) do
        init
        run_sections(@compiled_sections || sections, &block)
      end
    rescue => e
      begin
        provider = find_section_provider(current_section)
      rescue ArgumentError
        raise e
      end
      
      line = provider.full_path
      line += " (template)" if provider.is_a?(SectionProviders::TemplateProvider)
      line += ":1:in#{@compiled_sections ? ' compiled' : ''} section `#{current_section}'"
      me = NoMethodError.new(e.message)
      me.set_backtrace([line] + e.backtrace)
      raise me
    end
    alias to_s run
    
    def run_sections(sects, break_first = false, locals = {}, &block)
      with_options(locals) do
        out = ''
        raise ArgumentError, "Template(#{path}) is missing sections" unless sects
        sects = sects.first if sects.first.is_a?(Array)
        sects.each_with_index do |section, i|
          (break_first ? break : next) if section.is_a?(Array)
      
          self.current_section = section_name(section)
      
          next if run_before_sections.is_a?(FalseClass)

          if sects[i+1].is_a?(Array)
            old, self.subsections = subsections, sects[i+1]
            out += run_subsections(section, sects[i+1], &block)
            self.subsections = old
          else
            out += render(section, {}, true, &block)
          end
      
          break if break_first
        end
        out
      end
    end
    
    def run_subsections(section, subsections, locals = {}, &block)
      list = subsections.dup

      render(section, locals, true) do |*args|
        if list.empty?
          raise LocalJumpError, "Section `#{section}' yielded with no sub-section given."
        end
        
        ysection, locals = *parse_yield_args(*args)
        if ysection
          render(ysection, locals, true)
        else
          data = run_sections(list, true, locals, &block) 
          list.shift; list.shift if list.first.is_a?(Array)
          list = subsections.dup if list.empty? 
          data
        end
      end
    end
    
    def all_sections(&block)
      subsections.each do |s|
        next if Array === s
        yield section_name(s)
      end
    end
    
    def yieldall(locals = {}, &block)
      run_sections(subsections, false, locals, &block) 
    end
    
    def render(section, locals = {}, call_method = false, &block)
      with_options(locals) do
        case section
        when String, Symbol
          if call_method && respond_to?(section) 
            send(section, &block)
          else
            find_section_provider(section).render(options, &block)
          end
        when Template
          section.run(options, &block)
        when Module
          section.new(options).run(&block)
        when SectionProviders::SectionProvider
          section.render(options, &block)
        else
          raise MissingSectionError, "missing section #{section.inspect}"
        end
      end
    end

    def inspect
      "#<Template:0x%s path='%s' sections=%s%s>" % [object_id.to_s(16), 
        path, sections.inspect, @compiled_sections ? ' (compiled)' : ''] 
    end
    
    private
    
    def section_name(section)
      case section
      when SectionProviders::SectionProvider
        @providers.key(section) || section
      else
        section.respond_to?(:path) ? section.path : section
      end.to_s
    end
    
    def parse_yield_args(*args)
      sym = args.shift
      if Hash === sym
        [nil, sym]
      elsif sym
        [sym, args.first || {}]
      else
        [nil, {}]
      end
    end
    
    def with_options(locals = {}, &block)
      old_options = options
      self.options = options.to_hash.merge(locals)
      result = yield
      self.options = old_options
      result
    end

    def find_section_provider(section)
      section = section.to_s
      @providers ||= {}
      return @providers[section] if @providers[section]
      
      filename, provider = nil, nil
      template_paths.each do |template_path|
        SectionProviders.providers.each do |prov|
          filename = prov.provides?(self, File.join(template_path, section))
          break provider = prov if filename
        end
        break if provider && filename
      end
      
      raise ArgumentError, "Template(#{path}) is missing section `#{section}'" if !provider 
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
        raise ArgumentError, "Template(#{path}) is missing template file `#{filename}'"
      end
    end
  end
end
