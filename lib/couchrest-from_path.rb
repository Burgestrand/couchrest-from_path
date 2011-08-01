# coding: utf-8
require 'couchrest'
require 'find'
require 'pathname'
require 'couchrest-from_path/version'

module CouchRest
  module FromPath
    # Load a given path up as a CouchRest document.
    # 
    # @param [String] path
    # @yield [path, contents]
    # @yieldparam [Pathname] path
    # @yieldparam [String] contents
    # @yieldreturn [[Pathname, String]] basename and contents
    # @return CouchRest::Document or CouchRest::Design
    def from_path(path)
      doc  = {}
      root = Pathname.new(path)
      
      find_files(path).each do |file|
        path = Pathname.new(file).relative_path_from(root).cleanpath
        name = path.basename.to_path
        
        path.each_filename.inject(doc) do |memo, entry|
          if entry == name
            contents = File.read(file)
            entry, contents = yield path, contents if block_given?
            entry = entry.basename.to_path if entry.is_a? Pathname
            memo[entry] = contents
          end
          
          memo[entry] ||= {}
        end
      end
      
      klass = case doc['_id']
      when nil then raise "a valid “_id” does not exist in #{path}"
      when %r|\A_design/| then CouchRest::Design
      else CouchRest::Document
      end
      
      klass.new(doc)
    end
  
    private
      # Find all files in the given paths.
      # 
      # @param [Array<String>] *paths
      # @return [Array<String>]
      def find_files(*paths)
        Find.find(*paths).select do |path|
          File.file?(path)
        end
      end
  end
end
