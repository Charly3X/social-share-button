module SocialShareButton
  class ShareController < SocialShareButton::ApplicationController

    def get_count
      site = params[:site]
      current_url = params[:current_url]
      res = 0
      if site =='facebook'
        #url = "https://api.facebook.com/method/links.getStats?urls=#{current_url}&format=json"
        url = "https://graph.facebook.com/?id=#{current_url}"
        buffer = open(url).read
        result = JSON.parse(buffer)
        res = result.nil? ? 0 : result['share']['share_count']
      elsif site =='twitter'
        'twitter'
      elsif site =='google_plus'
        url = "https://clients6.google.com/rpc?key=AIzaSyCKSbrvQasunBoV16zDH9R33D88CeLr9gQ"
        response = post(url, JSON.dump(pr(current_url)), {content_type: :json, accept: :json})
        res = JSON.parse(response)[0]['result']['metadata']['globalCounts']['count'].to_i
      elsif site =='delicious'
        md5 = Digest::MD5.hexdigest(current_url)
        url = "http://feeds.delicious.com/v2/json/url/#{md5}"
        buffer = open(url).read
        res = JSON.parse(buffer).count
      elsif site == 'reddit'
        url = "http://www.reddit.com/api/info.json?url=#{current_url}"
        buffer = open(url).read
        result = JSON.parse(buffer)['data']['children']
        res = result.map{|c| c['data']['score']}.reduce(:+) || 0
      end
      render text: res
    rescue Exception => e
      render text: 0
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