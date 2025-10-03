class CreateEmbeddingCache < ActiveRecord::Migration[7.0]
  def change
    create_table :embedding_cache do |t|
      t.string :doc_id
      t.integer :value_hash
      t.json :bge_base_en_15_768
      t.json :bge_base_en_15_1024

      t.timestamps
    end
    add_index :embedding_cache, :doc_id, unique: true
    add_index :embedding_cache, :value_hash
  end
end
