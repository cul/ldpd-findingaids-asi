class Repository
	attr_accessor :id, :finding_aids, :name
	def initialize(id, properties = {})
 		@id = id
 		@name = properties[:name]
 		@finding_aids = properties[:list_of_finding_aids] || []
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
