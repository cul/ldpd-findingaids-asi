class ChangeValueHashToBigintInEmbeddingCache < ActiveRecord::Migration[7.0]
  def change
    change_column :embedding_cache, :value_hash, :bigint
  end
end
