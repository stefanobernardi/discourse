class AddTokenToFacebookUserInfo < ActiveRecord::Migration
  def change
    add_column :facebook_user_infos, :token, :string
  end
end
