class CreateEmbeddingCache < ActiveRecord::Migration[7.0]
  def change
    create_table :embedding_cache do |t|
      t.string :doc_id
      t.string :model_identifier
      t.integer :value_hash
      t.json :embedding

      t.timestamps
    end
    add_index :embedding_cache, [:doc_id, :model_identifier], unique: true
    add_index :embedding_cache, [:doc_id, :model_identifier, :value_hash], unique: true, name: "index_embedding_caches_on_doc_model_value"
  end
end
