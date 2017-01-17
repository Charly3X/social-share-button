module SocialShareButton
  class ShareController < SocialShareButton::ApplicationController

    def get_count
      my_logger ||= Logger.new("#{Rails.root}/log/shared.log")
      site = params[:site]
      current_url = URI.unescape(params[:current_url])
      res = 0
      if site =='facebook'
        #url = "https://api.facebook.com/method/links.getStats?urls=#{current_url}&format=json"
        url = "https://graph.facebook.com/v2.3/?id=#{current_url}&access_token=341496876182072|JZAGmuAc6ivwjCJ6Eq2_BCGkCRM"
        #my_logger.info("fb_prep: url: #{url}")
        buffer = open(url).read
        result = JSON.parse(buffer)
        #my_logger.info("fb_res: #{result}; url: #{url}")
        res = result.nil? ? 0 : result['share']['share_count']
      elsif site =='facebook_lcb'
        url = "https://graph.facebook.com/#{current_url}?fields=fan_count&access_token=341496876182072|JZAGmuAc6ivwjCJ6Eq2_BCGkCRM"
        buffer = open(url).read
        result = JSON.parse(buffer)
        res = result.nil? ? 0 : result['fan_count']
      elsif site =='twitter'
        'twitter'
      elsif site =='google_plus'
        url = "https://clients6.google.com/rpc?key=AIzaSyCKSbrvQasunBoV16zDH9R33D88CeLr9gQ"
        response = post(url, JSON.dump(pr(current_url)), {content_type: :json, accept: :json})
        res = JSON.parse(response)[0]['result']['metadata']['globalCounts']['count'].to_i
      elsif site =='delicious'
        md5 = Digest::MD5.hexdigest(current_url)
        url = "http://feeds.del.icio.us/v2/json/url/#{md5}"
        buffer = open(url).read
        res = JSON.parse(buffer).count
      elsif site == 'reddit'
        url = "http://www.reddit.com/api/info.json?url=#{current_url}"
        buffer = open(url).read
        result = JSON.parse(buffer)['data']['children']
        res = result.map{|c| c['data']['score']}.reduce(:+) || 0
      end
      save_to_db(res.to_i, site, current_url)
      render text: res
    rescue Exception => e
      my_logger.info "ERROR SHARE - #{e.message} - soc: #{site}; url: #{current_url}"
      res = 0
      render text: res
    end

    def save_to_db(count, type, url)
      if defined? ShareCount
        uri = url.gsub(/\?.*/, '')
        sh = ShareCount.where(url: uri).first_or_initialize
        if (sh.fb_count == 0 && count != 0) || (sh.fb_count != 0 && count != 0) || (sh.fb_count == 0 && count == 0)
          if type == 'facebook'
            sh.fb_count = count
          elsif type == 'google_plus'
            sh.google_count = count
          end
          sh.last_update = Time.now
          sh.save
        end
      end
    rescue
      true
    end

    def inc_trend
      if params[:share_object_class].present? && params[:share_object_id].present?
        object = params[:share_object_class].classify.safe_constantize.find(params[:share_object_id])
        object.news_trend.try(:add_current_frame_shares) if object.respond_to?(:news_trend)
      end
    rescue
      true
    end

    def reset_share_count
      if defined? ShareCount
        site = params[:site]
        current_url = URI.unescape(params[:current_url])
        if site == 'twitter'
          sh = ShareCount.where(url: current_url).first_or_initialize
          sh.twitter_count += 1
          sh.save
        else
          sh = ShareCount.where(url: current_url).first
          if sh
            sh.last_update = nil
            sh.save
          end
        end
        inc_trend
      end
      render nothing: true
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