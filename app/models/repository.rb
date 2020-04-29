class Repository
  attr_accessor :id, :name, :has_fa_list
  alias_method :has_fa_list?, :has_fa_list
	def initialize(id, properties = {})
 		@id = id
 		@name = properties[:name]
                @has_fa_list = properties[:has_fa_list]
	end

	def self.find(id)
		props = REPOS[id]
		raise ActiveRecord::RecordNotFound(id) unless props
		Repository.new(id, props)
	end

	def self.all
		REPOS.map { |repo_id, props| Repository.new(repo_id, props) }
	end
end
