module Templater
  module Template
    module ClassMethods
      attr_accessor :path, :template_paths, :sections
      
      def run(*args, &block)
        new(*args).run(&block)
      end
      
      def new(opts = {}, &block)
        obj = Object.new.extend(self)
        class << obj; extend ClassMethods end
        obj.instance_eval "def class; #{self} end"
        obj.options = opts
        #obj.sections(*sections)
        obj.init(&block)
        obj
      end
    end
    
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    attr_accessor :options
    
    def options; @options ||= {} end
    
    def options=(hash)
      hash.each do |k, v|
        options[k.to_sym] = v
      end
    end
    
    def method_missing(meth, *args, &block)
      if options.has_key?(meth)
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
    
    def init(&block); end

    def run(opts = {}, &block)
      old_opts = options.dup
      self.options.update(opts)
      out = run_sections(sections, &block)
      options.replace(old_opts)
      out
    rescue => e
      me = NoMethodError.new("In #{self.inspect}: #{e.message}")
      me.set_backtrace(e.backtrace)
      raise me
    end
    alias to_s run
    
    attr_accessor :current_section, :subsections
    def run_sections(sects, break_first = false, &block)
      out = ''
      sects = sects.first if sects.first.is_a?(Array)
      sects.each_with_index do |section, i|
        (break_first ? break : next) if section.is_a?(Array)
        
        if sects[i+1].is_a?(Array)
          self.subsections = sects[i+1].reject {|s| Array === s }
          list = sects[i+1].dup
          out += render(section) do
            if list.empty?
              raise LocalJumpError, "Section `#{section}' yielded with no sub-section given."
            end
            
            data = run_sections(list, true, &block) 
            list.shift; list.shift if list.first.is_a?(Array)
            data
          end
        else
          self.current_section = section
          out += render(section, &block)
        end
        
        break if break_first
      end
      out
    end
    
    def all_sections(&block)
      subsections.each do |s|
        yield(s) 
      end
    end
    
    def render(section, &block)
      case section
      when String
        find_section_provider(section).render(&block)
      when Symbol
        if respond_to? section
          send(section, &block)
        else
          Templater.create_template(*(path + [section])).new(options).run(&block)
        end
      when Template
        section.run(&block)
      when Module
        section.new(*args).run(&block)
      else
        raise ArgumentError, "invalid section #{section.inspect}"
      end
    end

    def inspect; "#<Template:0x#{object_id.to_s(16)} path='#{self.path.join('/')}' sections=#{sections.inspect}>" end
    
    private
    
    def find_section_provider(section)
      @providers ||= {}
      return @providers[section] if @providers[section]
      
      filename, provider = section, nil
      if find_template(section)
        provider = SectionProviders.default_provider
      else
        SectionProviders.providers.each do |ext, prov|
          filename = "#{section}.#{ext}"
          if find_template(filename)
            break provider = prov
          end
        end
      end
      
      raise ArgumentError, "missing section `#{section}'" if !provider
      @providers[section] = provider.new(template_contents(filename), self)
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
