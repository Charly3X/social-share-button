# coding: utf-8
#ToDo: Need refactoring
module SocialShareButton
  module Helper
    def social_share_button_tag(title = "", opts = {})
      extra_data = {}
      rel = opts[:rel]
      html = []
      html << "<ul class='head_social_list adpt_swp_list social-share-button' data-title='#{h title}' data-img='#{opts[:image]}' "
      #html << "<div class='social-share-button!!!' data-title='#{h title}' data-img='#{opts[:image]}'"
      html << "data-url='#{opts[:url]}' data-desc='#{opts[:desc]}' data-popup='#{opts[:popup]}' data-via='#{opts[:via]}'>"

      SocialShareButton.config.allow_sites.each do |name|
        extra_data = opts.select { |k, _| k.to_s.start_with?('data') } if name.eql?('tumblr')
        special_data = opts.select { |k, _| k.to_s.start_with?('data-' + name) }

        name_class = name
	      if name == 'google_plus'
          name_class = 'google'
        end
        if name == 'delicious'
          name_class = 'stuff1'
        end
        if name == 'reddit'
          name_class = 'stuff2'
        end
        link_title = t "social_share_button.share_to", :name => t("social_share_button.#{name.downcase}")
        html << "<li class='head_social_item adpt_swp_item'>"
        html << "<a class='head_social_item_inner #{name_class}' href='#' data-site='#{name}' onclick='return SocialShareButton.share(this);' >
                 <span class='amount_likes #{'dyn_socical' unless name == 'twitter' }' data-type='#{name}' data-url='#{opts[:url]}'>#{'twitter' if name == 'twitter' }</span> <span class='#{name_class} share_link'>share</span></a>"

        #<span class='amount_likes' data-type='facebook' data-url='#{opts[:url]}'> #{get_count(name, opts[:url])} </span> <span class='#{name_class} share_link'>share</span></a>"

        #html << link_to("","#", {:rel => ["nofollow", rel],
        #                          "data-site" => name,
        #                          :class => "social-share-button-#{name}",
        #                          :onclick => "return SocialShareButton.share(this);",
        #                          :title => h(link_title)}.merge(extra_data).merge(special_data))
        html << "</li>"
      end
      #html << "</div>"
      html << "</ul>"
      raw html.join("\n")
    end


    def social_share_button_window_tag(title = "", opts = {})
      html = []
      html << "<ul class='ov_share_list social-share-button' data-title='#{h title}' data-img='#{opts[:image]}' data-url='#{opts[:url]}' data-desc='#{opts[:desc]}' data-popup='#{opts[:popup]}' data-via='#{opts[:via]}'>"

      SocialShareButton.config.allow_sites.each do |name|
        name_class = name
        name_social = name
        shares = 'shares'
        if name == 'twitter'
          shares = nil
        end
        if name == 'google_plus'
          name_class = 'google'
          name_social = 'Google+'
        end

        html << "<li class='ov_share_item'>"
        html << "<a class='ov_share_link #{name_class}_mod' href='#' data-site='#{name}' onclick='return SocialShareButton.share(this);' >
                   <dl class='ov_share_dl'>
                     <dt class='ov_share_dt'>#{name_social.capitalize}</dt>
                     <dd class='ov_share_dd facebook_share_id'>#{get_count(name, opts[:url])} #{shares}</dd>
                     <dd class='ov_share_dd visual_mod'>"
        if name == 'facebook'
          html <<  "<span class='fb_mod mod_0 ov_share_visual'></span>"
        end
        if name == 'twitter'
          html <<  "<span class='tw_mod mod_0 ov_share_visual'></span>"
        end
        if name == 'google_plus'
          html <<  "<span class='gl_mod mod_0 ov_share_visual'></span>"
        end
        if name == 'delicious'
          html <<  "<img class='share_img' src='#{image_path('delicious_logo.jpg')}'>"
        end
        if name == 'reddit'
          html <<  "<img class='share_img' src='#{image_path('reddit_logo.png')}'>"
        end
        html << "</dd></dl></a>"
        html << "</li>"
      end
      html << "</ul>"
      raw html.join("\n")
    end

    def social_share_button_left_tag(title = "", opts = {})
      html = []

      html << "<div class='likes_block'>
           <ul class='likes_list' data-url='#{opts[:url]}' data-popup='#{opts[:popup]}'>
              <li class='likes_item'>
                 <a class='likes_link mod_share js_ov_butt_share'><span class='title_likes mod_share'>Share</span></a>
              </li>
              <li class='likes_item'>
                 <a class='likes_link mod_fb facebook' data-site='facebook' onclick='return SocialShareButton.share(this);'>
                    <span class='num_likes dyn_socical' data-type='facebook' data-url='#{opts[:url]}'></span>
                    <span class='title_likes mod_fb facebook'>Share</span>
                 </a>
              </li>
              <li class='likes_item g-plusone-class'>
                <a class='likes_link mod_gl google' data-site='google_plus' onclick='return SocialShareButton.share(this);'>
                  <span class='num_likes dyn_socical' data-type='google_plus' data-url='#{opts[:url]}'></span>
                  <span class='google title_likes mod_gl'>+1</span>
                </a>
              </li>
           </ul>
      </div>"
      raw html.join("\n")
    end

    def social_share_button_shop(title = "", opts = {})
      html = []
      html << "<a href='#' data-site='facebook' data-popup='#{opts[:popup]}' data-url='#{opts[:url]}' data-site='facebook' onclick='return SocialShareButton.share(this);'><img src='#{image_path('fb_rect.png')}' alt='Facebook'></a>
               <a href='#' data-site='twitter' data-popup='#{opts[:popup]}' data-url='#{opts[:url]}' data-type='twitter' onclick='return SocialShareButton.share(this);'><img src='#{image_path('tw_rect.png')}' alt='Twitter'></a>
               <a href='#' data-site='google_plus' data-popup='#{opts[:popup]}' data-url='#{opts[:url]}' data-type='google_plus' onclick='return SocialShareButton.share(this);'><img src='#{image_path('gp_rect.png')}' alt='Google+'></a>"
      raw html.join("\n")
    end

    private

    def get_count site, current_url
      if site =='facebook'
        url = "https://graph.facebook.com/?id=#{current_url}"
        buffer = open(url).read
        result = JSON.parse(buffer)
        res = result.nil? ? 0 : result['share']['share_count']
      elsif site =='twitter'
        'twitter'
      elsif site =='google_plus'
        url = "https://clients6.google.com/rpc?key=AIzaSyCKSbrvQasunBoV16zDH9R33D88CeLr9gQ"
        response = post(url, JSON.dump(pr(current_url)), {content_type: :json, accept: :json})
        JSON.parse(response)[0]['result']['metadata']['globalCounts']['count'].to_i
      elsif site =='delicious'
        md5 = Digest::MD5.hexdigest(current_url)
        url = "http://feeds.delicious.com/v2/json/url/#{md5}"
        buffer = open(url).read
        JSON.parse(buffer).count
      elsif site == 'reddit'
        url = "http://www.reddit.com/api/info.json?url=#{current_url}"
        buffer = open(url).read
        result = JSON.parse(buffer)['data']['children']
        result.map{|c| c['data']['score']}.reduce(:+) || 0
      else
        0
      end
    rescue Exception => e
      0
    end

    def post(url, params, headers = {})
      RestClient::Resource.new(url, timeout: 5, open_timeout: 5).post(params, headers)
    end

    def pr checked_url
      [{
           'method' => 'pos.plusones.get',
           'id' => 'p',
           'jsonrpc' => '2.0',
           'key' => 'p',
           'apiVersion' => 'v1',
           'params' => {
               'nolog' => true,
               'id' => checked_url,
               'source' => 'widget',
               'userId' => '@viewer',
               'groupId' => '@self'
           }
       }]
    end

  end
end
