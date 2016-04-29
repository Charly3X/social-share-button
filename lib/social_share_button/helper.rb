# coding: utf-8
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
        html << "<a class='head_social_item_inner #{name_class}' href='#' data-site='#{name}' onclick='return SocialShareButton.share(this);' ><span class='amount_likes'> #{get_count(name, opts[:url])} </span> <span class='#{name_class} share_link'>share</span></a>"
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


    def social_share_button_left_tag(title = "", opts = {})
      html = []

      html << "<div class='likes_block'>
           <ul class='likes_list' data-url='#{opts[:url]}' data-popup='#{opts[:popup]}'>
              <li class='likes_item'>
                 <a class='likes_link mod_share' href='#' title='#'><span class='title_likes mod_share'>Share</span></a>
              </li>
              <li class='likes_item'>
                 <a class='likes_link mod_fb facebook' data-site='facebook' href='#' onclick='return SocialShareButton.share(this);' title='#'><span class='title_likes mod_fb facebook'>Like</span></a>
              </li>
              <li class='likes_item g-plusone-class'>
                <a class='likes_link mod_gl google' data-site='google_plus' onclick='return SocialShareButton.share(this);' href='#' title='#'><span class='google title_likes mod_gl'>+1</span></a>
              </li>
           </ul>
      </div>"
      raw html.join("\n")
    end

    private

    def get_count site, current_url
      if site =='facebook'
        url = "https://api.facebook.com/method/links.getStats?urls=#{current_url}&format=json"
        buffer = open(url).read
        result = JSON.parse(buffer)
        result[0].nil? ? 0 : result[0]['share_count']
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
      RestClient::Resource.new(url, timeout: 3, open_timeout: 3).post(params, headers)
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
