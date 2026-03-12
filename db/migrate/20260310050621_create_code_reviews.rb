class CreateCodeReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :code_reviews do |t|
      t.string :repo_url
      t.string :base_branch
      t.string :compare_branch
      t.string :status

      t.timestamps
    end
  end
end
