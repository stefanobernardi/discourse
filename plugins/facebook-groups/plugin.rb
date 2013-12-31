# name: Gacebook Groups
# about: plugin that integrates Discourse with a Facebook Group
# version: 0.1
# authors: Stefano Bernardi

require 'koala'

group_id = GlobalSetting.fb_group_id
bot_access_token = GlobalSetting.fb_bot_access_token

class PostAlertObserver
	def after_create_post(post)
    	if post.topic.private_message?
      		# If it's a private message, notify the topic_allowed_users
      		post.topic.all_allowed_users.reject{ |a| a.id == post.user_id }.each do |a|
        		create_notification(a, Notification.types[:private_message], post)
      		end
    	elsif post.post_type != Post.types[:moderator_action]
      		# If it's not a private message and it's not an automatic post caused by a moderator action, notify the users
      		notify_post_users(post)
      		if post.post_number == 1 && post.topic
      			post_to_fb_group(topic)
      		end
    	end
  end

  protected

  def post_to_fb_group(topic)

  	permalink = "http://startupscene.org/t/" + topic.slug

  	if post.user.facebook_user_info.token #then we'll post on his behalf
		graph = Koala::Facebook::GraphAPI.new(post.user.facebook_user_info.token)
	else #we'll post with our bot
		graph = Koala::Facebook::GraphAPI.new(BOT_ACCESS_TOKEN)
	end
		graph.put_object(GROUP_ID, "feed", :message => post.raw, :link => permalink, :image => 'https://s3-eu-west-1.amazonaws.com/italianstartupscene/iss-logo.png')
  end
end