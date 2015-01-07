#
# Many props to this guy: https://gist.github.com/mattsears/1259080
#

require 'yaml'
require 'fileutils'

module Bixtodo
    
  class Item
    attr_accessor :text
    attr_accessor :tag

    def initialize(values)
      @tag  = values.scan(/@[A-Z0-9.-]+/i).last || "@today"
      @text = values.gsub(tag, "").strip
    end
  end
  
  class Todo
    FILE = "#{ENV['HOME']}/.bixsby/.todos.yml"
    
    attr_accessor :items

    def initialize(tag=nil)
      @items = []
      bootstrap
      load_items(tag)
    end

    def load_items(tag)
      YAML.load_file(file).each do |key, texts|
        texts.each do |text|
          if key.to_s == tag || tag.nil?
            @items << Item.new("#{text} #{key}") if key.to_s != '@done'
          end
        end
      end
      @items
    end

    def bootstrap
      return if File.exist?(file)
      
      # Create directory
      dirname = File.dirname(FILE)
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end

      # Create file
      save
    end

    def file
      @file ||= File.exist?(FILE) ? FILE : "#{ENV['HOME']}/.bixsby/.todos.yml"
    end

    def add(todo)
      @items << Item.new(todo)
      save
    end

    def list
      if @items.empty?
        puts "There are no todo items."
      else
        longest = @items.map(&:text).max_by(&:length) || 0
        @items.each_with_index do |todo, index|
          printf "%s: %-#{longest.size+5}s %s\n", index+1, todo.text, todo.tag
        end
      end
    end

    def done(index)
      item = @items[index.to_i-1]
      item.context = '@done'
      save
    end

    def delete(index)
      todo = @items.delete_at(index.to_i-1)
      save
    end

    def clear!
      @items.clear
      save
    end

    def to_hash
      @items.group_by(&:tag).inject({}) do |h,(k,v)|
        h[k.to_sym] = v.map(&:text); h
      end
    end

    def save
      File.open(file, "w") {|f| f.write(to_hash.to_yaml) }
    end
  end
end
