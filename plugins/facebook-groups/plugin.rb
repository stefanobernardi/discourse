# name: Gacebook Groups
# about: plugin that integrates Discourse with a Facebook Group
# version: 0.1
# authors: Stefano Bernardi

require 'koala'

group_id =  '163895500288173'
bot_access_token = 'CAACEdEose0cBAOjZA1HgPscQgZAz0jt4yUY8Nnzu4ANZC6BpRMgvVrvpLxiM7o0PzWaIZB06fXSZAdYYG3zLcjmGzvsfxd3ol11CVE4ZBYK0Ld6zhsZA9DCb9YqI0dCCxH8K3uYSjZBP2ShMCfuHi4W6kO1X6TOH7OCYp6gz4lC4JekG4wW56j3b3CinxEQZAPtZAmXuAfhN1JxAZDZD'

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
		graph = Koala::Facebook::GraphAPI.new(bot_access_token)
	end
		graph.put_object(group_id, "feed", :message => post.raw, :link => permalink, :image => 'https://s3-eu-west-1.amazonaws.com/italianstartupscene/iss-logo.png')
  end
end