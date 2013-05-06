class Youtube_lib
  require 'net/http'
  require 'rexml/document'

  # コンストラクタ
  def initialize(uid,base="gdata.youtube.com",port=80)
    uid_path = uid.sub(/http:\/\/#{base}/,'')
    @url     = base
    @port    = port
    @base_path = "#{uid_path}"
  end

  
  # 各ユーザごとのXML情報の取得
  def get_user_xml(path=nil)
    xml = ""
    @add_path = path
    Net::HTTP.version_1_2

    if path.nil?
      Net::HTTP.start("#{@url}", "#{@port}") {|http|
        response = http.get("#{@base_path}")
        xml = response.body
      }
    else
      Net::HTTP.start("#{@url}", "#{@port}") {|http|
        response = http.get("#{@base_path}/#{@add_path}")
        xml = response.body
      }
    end

    return xml
  end




  # ユーザの各feedは"http://gdata.youtube.com/feeds/api/users/< user name >"で固定なので
  # @user_urlとして取得する
  def get_user_url
    xml = self.get_user_xml()
    doc = REXML::Document.new( xml )
    user_url = doc.elements["/entry/author/uri"].text
    return user_url
  end




  # get xml of subscription channel
  # http://gdata.youtube.com/feeds/api/users/UFzGR0ndWeWwMKjjy-k0Qw/subscriptions/yeLTGwdHQpt-GmYiUBtn2NXMfHqCAOrdw_Gipv6Yzy4
  def get_channnel_xml( url )
    path = url.sub(/http:\/\/gdata\.youtube\.com/,'')
    xml  = ""

    Net::HTTP.version_1_2
    Net::HTTP.start("#{@url}", "#{@port}") do |http|
      response = http.get("/#{path}")
      xml = response.body
    end

    return xml
  end






  #-------------------------------------------------------------------
  # 2013/04/14
  # ユーザフィード取得メソッド( 出来るだけコレ使う )
  def get_user_feed( path=nil )
    user_url  = get_user_url
    base_path = user_url.sub(/http:\/\/#{@url}/,'')
    xml       = ""
    Net::HTTP.version_1_2

    if path.nil?
      Net::HTTP.start("#{@url}", "#{@port}") {|http|
        response = http.get("#{@base_path}")
        xml = response.body
      }
    else
      Net::HTTP.start("#{@url}", "#{@port}") {|http|
        response = http.get("#{@base_path}/#{path}")
        xml = response.body
      }
    end
    
    return xml    
  end


  # This method get urls of subscription channel's upload movie feed
  def get_uploads_entry_url( subscription_url )
    upload_feed_urls = []

    # get xml of subscription channel
    xml = get_channnel_xml( subscription_url )
    channel_doc = REXML::Document.new( xml )
    upload_counts        = channel_doc.elements["/feed/openSearch:totalResults"].text
    upload_index         = channel_doc.elements["/feed/openSearch:startIndex"].text
    item_counts_per_page = channel_doc.elements["/feed/openSearch:itemsPerPage"].text

    channel_doc.elements.each("/feed/entry/id") do |upload_url_element|
      #raise upload_url_element.text
      # http://gdata.youtube.com/feeds/api/videos/fI3av1fRiYE
      upload_feed_urls << upload_url_element.text
    end

    return upload_counts.to_i,upload_index.to_i,item_counts_per_page.to_i,upload_feed_urls
  end


  def get_uploads( name,index_count )
    movie = {}
    url = "http://gdata.youtube.com/feeds/api/users/#{name}/uploads?start-index=#{index_count}"
    upload_counts,upload_index,item_counts_per_page,upload_feed_urls =
       get_uploads_entry_url( url )

    upload_feed_urls.each do |upload_feed_url|
      upload_feed_xml = get_channnel_xml( upload_feed_url ) 
      doc = REXML::Document.new( upload_feed_xml )
      # http://gdata.youtube.com/feeds/api/users/playyouhousejp/uploads/M8nu4gkOlbI
      id              = doc.elements["/entry/id"].text
      movie_title     = doc.elements["/entry/media:group/media:title/"].text
      movie_thumbnail = doc.elements["/entry/media:group/media:thumbnail/"].attributes['url']
      movie_play_url  = doc.elements["/entry/media:group/media:player/"].attributes['url']

      # 各movie情報をIDをキーにして値に情報群のハッシュを配列構造を持たせる
      movie_array = [
        "movie_title"     => movie_title,
        "movie_thumbnail" => movie_thumbnail,
        "movie_play_url"  => movie_play_url,
      ]
      movie["#{id}"] = movie_array
    end

    next_index = index_count.to_i + item_counts_per_page.to_i
    return movie,next_index
  end

  # get movie's infomation of subscription channnel.
  def get_uploads2( subscription_url )
    #raise ActiveSupport::Base64.decode64( subscription_url ).to_yaml
    movie = {}

    status        = "false"
    count         = ''
    upload_index  = ''
    upload_counts = ''
    upload_index  = "1"
    while status = "false"
      url = "#{subscription_url}?start-index=#{upload_index}"
      # uploadされている動画ごとのURLを配列で取得
      upload_counts,upload_index,item_counts_per_page,upload_feed_urls = 
          get_uploads_entry_url( url )

      count = upload_counts - upload_index

      if item_counts_per_page > count
        status = "true"
      else
        upload_feed_urls.each do |upload_feed_url|
          upload_feed_xml = get_channnel_xml( upload_feed_url ) 
          doc = REXML::Document.new( upload_feed_xml )
          # http://gdata.youtube.com/feeds/api/users/playyouhousejp/uploads/M8nu4gkOlbI
          id              = doc.elements["/entry/id"].text
          movie_title     = doc.elements["/entry/media:group/media:title/"].text
          movie_thumbnail = doc.elements["/entry/media:group/media:thumbnail/"].attributes['url']
          movie_play_url  = doc.elements["/entry/media:group/media:player/"].attributes['url']

          # 各movie情報をIDをキーにして値に情報群のハッシュを配列構造を持たせる
          movie_array = [
            "movie_title"     => movie_title,
            "movie_thumbnail" => movie_thumbnail,
            "movie_play_url"  => movie_play_url,
          ]
          movie["#{id}"] = movie_array
        end

      upload_index += 1
      end
    end

    return movie
  end


  def get_username
    xml      = self.get_user_xml()
    username = ''
    doc = REXML::Document.new(xml)
    doc.elements.each('/entry/yt:username') do |element|
      username = element.text
    end
    return username
  end






  # 各サブスクリプションごとのXML URLを取得(購読チャンネル数分)
  def get_subscription_url
    subscription_urls  = []

    # subscriptionのURLを直接取得するのは難しいので
    # uriを取得して末尾に"/subscriptions"を付加する
    xml = get_user_feed("subscriptions")

    doc = REXML::Document.new( xml )
    doc.elements.each('/feed/entry/id') do |subscription_entry|
      subscription_urls << subscription_entry.text
    end

    return subscription_urls
  end





  # 各サブスクリプションごとの情報をハッシュで格納
  def get_subscription( subscription_url=nil )
    subscription = {}
    channel_url  = ''
    channel_base = "http://www.youtube.com/channel/"

    if subscription_url.nil?
      subscription_urls = get_subscription_url

      subscription_urls.each do |subscription_url|
        # subscription_xml変数に購読チャンネルごとのXMLエレメントが入る
        subscription_xml = get_channnel_xml( subscription_url )

        doc = REXML::Document.new( subscription_xml )
        id            = doc.elements["/entry/id"].text
        name          = doc.elements["/entry/yt:username"].text
        channel_url   = channel_base + doc.elements["/entry/yt:channelId"].text
        thumbnail     = doc.elements["/entry/media:thumbnail"].attributes['url']
        upload_counts =  doc.elements["/entry/gd:feedLink"].attributes['countHint']
        uploads_url   =  doc.elements["/entry/gd:feedLink"].attributes['href']

        # サブスクリプション情報をIDをキーにして値に情報群のハッシュの配列構造を持たせる
        subscription_array = {
          "name"          => name,
          "channel_url"   => channel_url,
          "thumbnail"     => thumbnail,
          "upload_counts" => upload_counts,
          "uploads_url"   => uploads_url, 
        }

        subscription["#{id}"] = subscription_array
      end

    else
      subscription_xml = get_channnel_xml( subscription_url )

      doc = REXML::Document.new( subscription_xml )
      id            = doc.elements["/entry/id"].text
      name          = doc.elements["/entry/yt:username"].text
      channel_url   = channel_base + doc.elements["/entry/yt:channelId"].text
      thumbnail     = doc.elements["/entry/media:thumbnail"].attributes['url']
      upload_counts = doc.elements["/entry/gd:feedLink"].attributes['countHint']
      uploads_url   = doc.elements["/entry/gd:feedLink"].attributes['href']
      upload_count  = doc.elements["/entry/gd:feedLink"].attributes['countHint']

      # サブスクリプション情報をIDをキーにして値に情報群のハッシュの配列構造を持たせる
      subscription_array = {
        "name"          => name,
        "channel_url"   => channel_url,
        "thumbnail"     => thumbnail,
        "upload_counts" => upload_counts,
        "uploads_url"   => uploads_url,
      }

      subscription["#{id}"] = subscription_array
    end

    return subscription
  end

  def get_subscription_names
    subscription_names = []
    path               = "subscriptions"
    subscriptions_xml  = self.get_user_xml(path)
    doc = REXML::Document.new(subscriptions_xml)
    doc.elements.each('/feed/entry/yt:username') do |subscription_name_element|
      subscription_names << element.text
    end
    return subscription_names
  end

end

# debug
# http://gdata.youtube.com/feeds/api/users/UFzGR0ndWeWwMKjjy-k0Qw
youtube_obj = Youtube_lib.new("http://gdata.youtube.com/feeds/api/users/UFzGR0ndWeWwMKjjy-k0Qw")
puts youtube_obj.get_subscription


#youtube_obj.get_uploads( http://gdata.youtube.com/feeds/api/users/UFzGR0ndWeWwMKjjy-k0Qw/subscriptions/yeLTGwdHQpt-GmYiUBtn2NXMfHqCAOrdw_Gipv6Yzy4 )


#subscriptions_data = youtube_obj.get_subscription( "http://gdata.youtube.com/feeds/api/users/UFzGR0ndWeWwMKjjy-k0Qw/subscriptions/yeLTGwdHQpt-GmYiUBtn2NXMfHqCAOrdw_Gipv6Yzy4" )


#subscriptions_data.each do |subscription_id,subscription_data|
#    uploads_movie = youtube_obj.get_uploads( subscription_data["uploads_url"] )
#    uploads_movie.each do |id,data|
#      puts data["movie_title"]
#    end
#end
